//
//  HKimporter.swift
//  HealthKitImporter
//
//  Created by boaz saragossi on 11/7/17.
//  Copyright © 2017 boaz saragossi. All rights reserved.
//

import UIKit
import HealthKit
import os.log
import ExceptionCatcher

extension CustomStringConvertible {
    var description: String {
        var description: String = "\(type(of: self))\n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
}

class HealthRecord: CustomStringConvertible {
    var type: String = String()
    var value: Double = 0
    var unit: String?
    var startDate: Date = Date()
    var endDate: Date = Date()
    var creationDate: Date = Date()

    // Source identity
    var sourceName: String = ""
    var sourceVersion: String?
    var deviceString: String?

    // Workout data
    var activityType: HKWorkoutActivityType? = HKWorkoutActivityType(rawValue: 0)
    var totalEnergyBurned: Double = 0
    var totalDistance: Double = 0
    var totalEnergyBurnedUnit: String = String()
    var totalDistanceUnit: String = String()

    var metadata: [String: Any]?

    /// Set when the XML element could not be parsed into a usable record.
    var parseFailure: SkipReason?
}

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension NumberFormatter {
    convenience init(locale: Locale, numberStyle: NumberFormatter.Style) {
        self.init()
        self.locale = locale
        self.numberStyle = numberStyle
    }
}

// MARK: - Import reporting and duplicate matching (Foundation only)

/// Why a record from export.xml was not written to Health.
enum SkipReason: String, CaseIterable {
    case malformedRecord = "Malformed record (missing required attributes)"
    case unsupportedSleepValue = "Unrecognized sleep analysis value"
    case durationTooLong = "Longer than HealthKit's 4-day sample limit"
    case zeroDurationHeadphoneExposure = "Zero-duration headphone exposure"
    case emptyAudioExposureEvent = "Empty audio exposure event"
    case invalidUnit = "Unit could not be parsed"
    case unsupportedType = "Type not supported by this importer"
    case notAuthorized = "Not authorized for writing (or read-only in HealthKit)"
    case outsideDateRange = "Outside the selected date range"
    case duplicate = "Already in Health (matching type, dates and value)"
}

/// Counters collected during one import (or preview) run.
struct ImportSummary {
    var recordsRead = 0
    var samplesPrepared = 0
    var samplesSaved = 0
    var samplesFailedToSave = 0
    var dryRun = false
    /// True when the duplicate check ran. HealthKit returns no samples for types whose read
    /// access was denied, so in that case existing data is invisible to the check.
    var duplicateCheckRan = false
    /// reason -> HealthKit type identifier -> count
    private(set) var skipped: [SkipReason: [String: Int]] = [:]

    mutating func skip(_ reason: SkipReason, type: String) {
        skipped[reason, default: [:]][type.isEmpty ? "(unknown)" : type, default: 0] += 1
    }

    func skippedCount(for reason: SkipReason) -> Int {
        skipped[reason]?.values.reduce(0, +) ?? 0
    }

    var totalSkipped: Int {
        SkipReason.allCases.reduce(0) { $0 + skippedCount(for: $1) }
    }

    func report(topTypesPerReason: Int = 5) -> String {
        var lines: [String] = []
        lines.append(dryRun ? "Preview only. Nothing was written to Health." : "Import finished.")
        lines.append("Records read: \(recordsRead)")
        lines.append(dryRun ? "Would write: \(samplesPrepared)" : "Written: \(samplesSaved) of \(samplesPrepared)")
        if samplesFailedToSave > 0 {
            lines.append("Failed to save: \(samplesFailedToSave)")
        }
        lines.append("Skipped: \(totalSkipped)")
        if duplicateCheckRan {
            lines.append("Duplicate check compares type, source, dates and value. It cannot see types where Health read access was denied.")
        }
        for reason in SkipReason.allCases {
            guard let byType = skipped[reason], !byType.isEmpty else { continue }
            lines.append("  \(reason.rawValue): \(skippedCount(for: reason))")
            let top = byType.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            for (type, count) in top.prefix(topTypesPerReason) {
                lines.append("    \(type): \(count)")
            }
            if top.count > topTypesPerReason {
                lines.append("    ... and \(top.count - topTypesPerReason) more types")
            }
        }
        return lines.joined(separator: "\n")
    }
}

/// Identifies a sample by type, source, start, end and value so that records in
/// export.xml can be matched against samples already in Health. Dates are compared to
/// the millisecond and values to four decimal places. The source is part of the key so a
/// record from one device is never dropped because another device recorded the same
/// numbers at the same time.
struct SampleKey: Hashable {
    let type: String
    let source: String
    let startMillis: Int64
    let endMillis: Int64
    let value: Int64

    init(type: String, source: String, start: Date, end: Date, value: Double) {
        self.type = type
        self.source = source
        self.startMillis = Int64((start.timeIntervalSince1970 * 1000).rounded())
        self.endMillis = Int64((end.timeIntervalSince1970 * 1000).rounded())
        // Values that are not finite or too large to scale never match anything.
        if value.isFinite, abs(value) < 1e14 {
            self.value = Int64((value * 10000).rounded())
        } else {
            self.value = Int64.min
        }
    }
}

class Importer: NSObject, XMLParserDelegate {
    var healthStore: HKHealthStore?

    var cutDate: Date?
    var allSamples: [HKSample] = []
    var authorizedTypes: [HKSampleType: Bool] = [:]
    var readCount = 0
    /// When true, parse and check for duplicates but do not write anything to Health.
    var dryRun = false
    /// When true, samples that already exist in Health (same type, dates and value) are skipped.
    var skipExistingSamples = true
    var summary = ImportSummary()
    /// Called on the main queue when saveAllSamples() is done.
    var onFinish: ((ImportSummary) -> Void)?
    private var sampleKeys: [UUID: SampleKey] = [:]
    private var unitsByType: [String: HKUnit] = [:]
    var insideCorrelation = false
    var currentRecord: HealthRecord = HealthRecord.init()
    var readCounterLabel: UILabel?
    var writeCounterLabel: UILabel?
    var numberFormatter = NumberFormatter(locale: .current, numberStyle: .decimal)
    var dateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss Z")

    convenience init(completion: @escaping () -> Void) {
        self.init()

        self.healthStore = HKHealthStore.init()
        self.healthStore?.requestAuthorization(toShare: Constants.allSampleTypes, read: Constants.allSampleTypes, completion: { _, error in
            if let error = error, Constants.loggingEnabled {
                os_log("Error: %@", error.localizedDescription)
            } else {
                completion()
            }
        })

        // Uncomment if you only want to import the last 1 month
        // If your export.xml is large, you likely need to enable this as
        // otherwise the saveSamples method will fail
        // self.cutDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        if elementName == "Correlation" {
            insideCorrelation = true
            return
        }
        if elementName == "Record" {
            guard !insideCorrelation else { return }
            parseRecordFromAttributes(attributeDict)
        } else if elementName == "MetadataEntry" {
            guard !insideCorrelation else { return }
            parseMetaDataFromAttributes(attributeDict)
        } else if elementName == "Workout" {
            parseWorkoutFromAttributes(attributeDict)
        } else if elementName == "WorkoutStatistics" {
            parseWorkoutStatisticsFromAttributes(attributeDict)
        } else {
            return
        }
    }

    fileprivate func parseRecordFromAttributes(_ attributeDict: [String: String]) {
        guard let type = attributeDict["type"],
              let startString = attributeDict["startDate"],
              let endString = attributeDict["endDate"],
              let startDate = dateFormatter.date(from: startString),
              let endDate = dateFormatter.date(from: endString) else {
            currentRecord.type = attributeDict["type"] ?? ""
            currentRecord.parseFailure = .malformedRecord
            return
        }
        currentRecord.type = type
        currentRecord.value = Importer.parseRecordValue(attributeDict["value"], type: type)
        currentRecord.unit = attributeDict["unit"] ?? ""
        currentRecord.sourceName = attributeDict["sourceName"] ?? ""
        currentRecord.sourceVersion = attributeDict["sourceVersion"]
        currentRecord.deviceString = attributeDict["device"]
        currentRecord.startDate = startDate
        currentRecord.endDate = endDate
        if currentRecord.startDate > currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = dateFormatter.date(from: attributeDict["creationDate"] ?? "") {
            currentRecord.creationDate = date
        }
    }

    private static func parseRecordValue(_ raw: String?, type: String?) -> Double {
        guard let raw = raw else { return 0 }
        if type == HKCategoryTypeIdentifier.sleepAnalysis.rawValue {
            if let mapped = sleepAnalysisValue(for: raw) { return Double(mapped) }
            if let value = Double(raw) { return value }
            if Constants.loggingEnabled { os_log("Skipping unsupported sleep analysis value: %@", raw) }
            return .nan
        }
        return Double(raw) ?? 0
    }
    private static func sleepAnalysisValue(for raw: String) -> Int? {
        switch raw {
        case "HKCategoryValueSleepAnalysisInBed":
            return HKCategoryValueSleepAnalysis.inBed.rawValue
        case "HKCategoryValueSleepAnalysisAsleep",
             "HKCategoryValueSleepAnalysisAsleepUnspecified":
            return 1
        case "HKCategoryValueSleepAnalysisAwake":
            return HKCategoryValueSleepAnalysis.awake.rawValue
        case "HKCategoryValueSleepAnalysisAsleepCore":
            return 3
        case "HKCategoryValueSleepAnalysisAsleepDeep":
            return 4
        case "HKCategoryValueSleepAnalysisAsleepREM":
            return 5
        default:
            return nil
        }
    }

    fileprivate func parseMetaDataFromAttributes(_ attributeDict: [String: String]) {
        guard let key = attributeDict["key"] else { return }
        guard let attributeValue = attributeDict["value"] else { return }

        if key == HKMetadataKeySyncIdentifier || key == HKMetadataKeySyncVersion { return }

        var value: Any?
        let valueParts = attributeValue.components(separatedBy: " ")
        if valueParts.count == 2,
           let num = numberFormatter.number(from: valueParts.first!),
           let unit = try? ExceptionCatcher.catch(callback: { HKUnit(from: valueParts.last!) }) {
            value = HKQuantity(unit: unit, doubleValue: num.doubleValue)
        } else if let date = dateFormatter.date(from: attributeValue) {
            value = date
        } else if let number = numberFormatter.number(from: attributeValue) {
            value = number.intValue == Int(number.doubleValue) ? number.intValue : number.doubleValue
        } else {
            value = attributeValue
        }

        if currentRecord.metadata == nil {
            currentRecord.metadata = [String: Any]()
        }

        if value != nil {
            currentRecord.metadata?[key] = value!
        }
    }

    fileprivate func parseWorkoutFromAttributes(_ attributeDict: [String: String]) {
        currentRecord.type = HKObjectType.workoutType().identifier
        currentRecord.activityType = HKWorkoutActivityType.activityTypeFromString(attributeDict["workoutActivityType"] ?? "")
        currentRecord.value = Double(attributeDict["duration"] ?? "0") ?? 0
        currentRecord.unit = attributeDict["durationUnit"] ?? ""
        currentRecord.sourceName = attributeDict["sourceName"] ?? ""
        currentRecord.sourceVersion = attributeDict["sourceVersion"]
        currentRecord.deviceString = attributeDict["device"]
        currentRecord.totalDistance = Double(attributeDict["totalDistance"] ?? "0") ?? 0
        currentRecord.totalDistanceUnit = attributeDict["totalDistanceUnit"] ??  ""
        currentRecord.totalEnergyBurned = Double(attributeDict["totalEnergyBurned"] ?? "0") ?? 0
        currentRecord.totalEnergyBurnedUnit = attributeDict["totalEnergyBurnedUnit"] ?? ""
        if let date = dateFormatter.date(from: attributeDict["startDate"] ?? "") {
            currentRecord.startDate = date
        }
        if let date = dateFormatter.date(from: attributeDict["endDate"] ?? "") {
            currentRecord.endDate = date
        }
        if currentRecord.startDate > currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = dateFormatter.date(from: attributeDict["creationDate"] ?? "") {
            currentRecord.creationDate = date
        }
    }

    fileprivate func parseWorkoutStatisticsFromAttributes(_ attributeDict: [String: String]) {
        let value = Double(attributeDict["sum"] ?? "0") ?? 0
        guard let unit = attributeDict["unit"] else { return }

        switch attributeDict["type"] {
        case "HKQuantityTypeIdentifierActiveEnergyBurned":
            self.currentRecord.totalEnergyBurned = value
            self.currentRecord.totalEnergyBurnedUnit = unit
        case "HKQuantityTypeIdentifierDistanceWalkingRunning":
            self.currentRecord.totalDistance = value
            self.currentRecord.totalDistanceUnit = unit
        default:
            return
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Correlation" {
            insideCorrelation = false
            return
        }
        if insideCorrelation { return }
        if elementName == "Record" || elementName == "Workout" {
            readCount += 1
            summary.recordsRead = readCount
            if let failure = currentRecord.parseFailure {
                summary.skip(failure, type: currentRecord.type)
                currentRecord = HealthRecord.init()
                return
            }
            if Constants.loggingEnabled {
                os_log("Record: %@", currentRecord.description)
            }
            DispatchQueue.main.async {
                self.readCounterLabel?.text = "\(self.readCount)"
            }
            if self.cutDate == nil || currentRecord.startDate > cutDate! {
                saveRecord(item: currentRecord, withSuccess: {}, failure: {
                    if Constants.loggingEnabled {
                        os_log("fail to process record")
                    }
                })
            } else {
                summary.skip(.outsideDateRange, type: currentRecord.type)
            }
            currentRecord = HealthRecord.init()
        }
    }

    func saveRecord(item: HealthRecord, withSuccess successBlock: @escaping () -> Void, failure failureBlock: @escaping () -> Void) {
        // HealthKit raises an exception if time between end and start date is > 345600
        let duration = item.endDate.timeIntervalSince(item.startDate)
        let skipReason: SkipReason?
        if item.value.isNaN {
            skipReason = item.type == HKCategoryTypeIdentifier.sleepAnalysis.rawValue ? .unsupportedSleepValue : .malformedRecord
        } else if duration > 345600 {
            skipReason = .durationTooLong
        } else if item.type == "HKQuantityTypeIdentifierHeadphoneAudioExposure" && duration < 0.001 {
            skipReason = .zeroDurationHeadphoneExposure
        } else if item.type == "HKCategoryTypeIdentifierAudioExposureEvent" && Int(item.value) == 0 {
            skipReason = .emptyAudioExposureEvent
        } else {
            skipReason = nil
        }
        if let skipReason = skipReason {
            summary.skip(skipReason, type: item.type)
            failureBlock()
            return
        }

        let parsed = item.deviceString.flatMap { DeviceStringParser.parse($0) }
        let device: HKDevice? = parsed.map { parsed in
            HKDevice(
                name: parsed.name ?? item.sourceName,
                manufacturer: parsed.manufacturer,
                model: parsed.model,
                hardwareVersion: parsed.hardwareVersion,
                firmwareVersion: nil,
                softwareVersion: parsed.softwareVersion,
                localIdentifier: nil,
                udiDeviceIdentifier: nil
            )
        }

        var metadata = item.metadata
        if !item.sourceName.isEmpty {
            metadata = metadata ?? [String: Any]()
            metadata?["HKImportOriginalSourceName"] = item.sourceName
        }
        if let sourceVersion = item.sourceVersion {
            metadata = metadata ?? [String: Any]()
            metadata?["HKImportOriginalSourceVersion"] = sourceVersion
        }
        if let deviceString = item.deviceString {
            metadata = metadata ?? [String: Any]()
            metadata?["HKImportOriginalDeviceString"] = deviceString
        }

        guard let unit = Importer.makeUnit(item.unit ?? "") else {
            summary.skip(.invalidUnit, type: item.type)
            failureBlock()
            return
        }
        let quantity = HKQuantity(unit: unit, doubleValue: item.value)
        var hkSample: HKSample?
        if let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: item.type)) {
            hkSample = HKQuantitySample.init(
                type: type,
                quantity: quantity,
                start: item.startDate,
                end: item.endDate,
                device: device,
                metadata: metadata
            )
        } else if let type = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: item.type)) {
            hkSample = HKCategorySample.init(
                type: type,
                value: Int(item.value),
                start: item.startDate,
                end: item.endDate,
                device: device,
                metadata: metadata
            )
        } else if item.type == HKObjectType.workoutType().identifier {
            var totalEnergyBurned: HKQuantity?
            if item.totalEnergyBurnedUnit != "" {
                guard let energyUnit = Importer.makeUnit(item.totalEnergyBurnedUnit) else {
                    summary.skip(.invalidUnit, type: item.type)
                    failureBlock()
                    return
                }
                totalEnergyBurned = HKQuantity(unit: energyUnit, doubleValue: item.totalEnergyBurned)
            }
            var totalDistance: HKQuantity?
            if item.totalDistanceUnit != "" {
                guard let distanceUnit = Importer.makeUnit(item.totalDistanceUnit) else {
                    summary.skip(.invalidUnit, type: item.type)
                    failureBlock()
                    return
                }
                totalDistance = HKQuantity(unit: distanceUnit, doubleValue: item.totalDistance)
            }

            hkSample = HKWorkout.init(
                activityType: item.activityType ?? HKWorkoutActivityType(rawValue: 0)!,
                start: item.startDate,
                end: item.endDate,
                duration: HKQuantity(unit: unit, doubleValue: item.value).doubleValue(for: HKUnit.second()),
                totalEnergyBurned: totalEnergyBurned,
                totalDistance: totalDistance,
                device: device,
                metadata: metadata
            )
        } else if Constants.loggingEnabled {
            os_log("Didn't catch this item: %@", item.description)
        }
        if let hkSample = hkSample,
            authorizedTypes[hkSample.sampleType] ?? false || (self.healthStore?.authorizationStatus(for: hkSample.sampleType) == HKAuthorizationStatus.sharingAuthorized) {
            authorizedTypes[hkSample.sampleType] = true
            allSamples.append(hkSample)
            summary.samplesPrepared += 1
            if unitsByType[item.type] == nil, hkSample is HKQuantitySample {
                unitsByType[item.type] = unit
            }
            let keyValue: Double
            if hkSample is HKWorkout {
                keyValue = quantity.doubleValue(for: HKUnit.second())
            } else if hkSample is HKQuantitySample, let typeUnit = unitsByType[item.type], quantity.is(compatibleWith: typeUnit) {
                keyValue = quantity.doubleValue(for: typeUnit)
            } else {
                keyValue = item.value
            }
            sampleKeys[hkSample.uuid] = SampleKey(type: item.type, source: item.sourceName, start: item.startDate, end: item.endDate, value: keyValue)
            successBlock()
        } else {
            summary.skip(hkSample == nil ? .unsupportedType : .notAuthorized, type: item.type)
            failureBlock()
        }
    }

    func saveAllSamples() {
        summary.dryRun = dryRun
        summary.duplicateCheckRan = skipExistingSamples && healthStore != nil
        filterExistingSamples(allSamples) { samples in
            guard !self.dryRun else {
                self.allSamples = samples
                self.finish()
                return
            }
            // Chunk the samples and save in batches
            let chunkSize = 1000
            let chunks = stride(from: 0, to: samples.count, by: chunkSize).map {
                Array(samples[$0..<min($0 + chunkSize, samples.count)])
            }
            self.allSamples = samples
            self.saveSamplesInChunks(chunks: chunks, index: 0)
        }
    }

    private func finish() {
        // The preview count is whatever is left after duplicate filtering.
        if dryRun {
            summary.samplesPrepared = allSamples.count
        }
        DispatchQueue.main.async {
            self.onFinish?(self.summary)
        }
    }

    /// Removes samples that already exist in Health with the same type, start, end and value.
    /// This relies on read access: if read access to a type was denied, HealthKit returns no
    /// samples for it and nothing can be detected as a duplicate.
    func filterExistingSamples(_ samples: [HKSample], completion: @escaping ([HKSample]) -> Void) {
        guard skipExistingSamples, healthStore != nil, !samples.isEmpty else {
            completion(samples)
            return
        }
        let byType = Dictionary(grouping: samples, by: { $0.sampleType })
        var remaining = Array(byType.keys)
        var duplicateUUIDs = Set<UUID>()

        func next() {
            guard let sampleType = remaining.popLast() else {
                let kept = samples.filter { sample in
                    if duplicateUUIDs.contains(sample.uuid) {
                        self.summary.skip(.duplicate, type: sample.sampleType.identifier)
                        return false
                    }
                    return true
                }
                completion(kept)
                return
            }
            let pending = byType[sampleType] ?? []
            guard let start = pending.map({ $0.startDate }).min(),
                  let end = pending.map({ $0.endDate }).max() else {
                next()
                return
            }
            self.fetchExistingSamples(of: sampleType, start: start, end: end) { results in
                // Count existing samples per key so that N identical records in the file are only
                // treated as duplicates of N identical samples already in Health.
                var existing: [SampleKey: Int] = [:]
                for result in results {
                    existing[self.key(for: result, fallbackUnit: self.unitsByType[sampleType.identifier]), default: 0] += 1
                }
                for sample in pending {
                    if let key = self.sampleKeys[sample.uuid], let count = existing[key], count > 0 {
                        existing[key] = count - 1
                        duplicateUUIDs.insert(sample.uuid)
                    }
                }
                next()
            }
        }
        next()
    }

    /// Returns the samples of one type that overlap the given dates and are already in Health.
    /// Separate from the matching logic so tests can supply a fake list of existing samples.
    func fetchExistingSamples(of sampleType: HKSampleType, start: Date, end: Date, completion: @escaping ([HKSample]) -> Void) {
        guard let healthStore = healthStore else {
            completion([])
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            if let error = error, Constants.loggingEnabled {
                os_log("Duplicate check failed for %@: %@", sampleType.identifier, error.localizedDescription)
            }
            completion(results ?? [])
        }
        healthStore.execute(query)
    }

    private func key(for sample: HKSample, fallbackUnit: HKUnit?) -> SampleKey {
        let value: Double
        if let quantitySample = sample as? HKQuantitySample {
            if let unit = fallbackUnit, quantitySample.quantity.is(compatibleWith: unit) {
                value = quantitySample.quantity.doubleValue(for: unit)
            } else {
                value = .nan
            }
        } else if let categorySample = sample as? HKCategorySample {
            value = Double(categorySample.value)
        } else if let workout = sample as? HKWorkout {
            value = workout.duration
        } else {
            value = .nan
        }
        // Samples written by this importer carry the original source name in metadata.
        let source = (sample.metadata?["HKImportOriginalSourceName"] as? String) ?? sample.sourceRevision.source.name
        return SampleKey(type: sample.sampleType.identifier, source: source, start: sample.startDate, end: sample.endDate, value: value)
    }

    static func makeUnit(_ string: String) -> HKUnit? {
        try? ExceptionCatcher.catch(callback: { HKUnit(from: string) })
    }

    private func saveSamplesInChunks(chunks: [[HKSample]], index: Int) {
        // Base case: if all chunks are processed, stop
        if index >= chunks.count {
            os_log("All samples have been processed.")
            finish()
            return
        }

        // Save the current chunk and proceed to the next one
        saveSamples(samples: chunks[index], withSuccess: {
            os_log("Successfully saved chunk %d of %d", index + 1, chunks.count)
            self.saveSamplesInChunks(chunks: chunks, index: index + 1)
        }, failure: {
            os_log("Failed to save chunk %d of %d. Proceeding with the next chunk.", index + 1, chunks.count)
            self.summary.samplesFailedToSave += chunks[index].count
            self.saveSamplesInChunks(chunks: chunks, index: index + 1)
        })
    }

    func saveSamples(samples: [HKSample], withSuccess successBlock: @escaping () -> Void, failure failureBlock: @escaping () -> Void) {
        healthStore?.save(samples) { success, error in
            if !success {
                if Constants.loggingEnabled {
                    if let error = error {
                        os_log("An error occurred saving the samples. Error: %@", error.localizedDescription)
                    } else {
                        os_log("An unknown error occurred saving the samples.")
                    }
                }
                failureBlock()
                return
            }

            // Update UI and call the success block
            self.summary.samplesSaved += samples.count
            DispatchQueue.main.async {
                self.writeCounterLabel?.text = "\(self.summary.samplesSaved)"
            }
            successBlock()
        }
    }

}
