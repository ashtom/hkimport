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

    // Workout data
    var activityType: HKWorkoutActivityType? = HKWorkoutActivityType(rawValue: 0)
    var totalEnergyBurned: Double = 0
    var totalDistance: Double = 0
    var totalEnergyBurnedUnit: String = String()
    var totalDistanceUnit: String = String()

    var metadata: [String: Any]?
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

class Importer: NSObject, XMLParserDelegate {
    var healthStore: HKHealthStore?

    var cutDate: Date?
    var allSamples: [HKSample] = []
    var authorizedTypes: [HKSampleType: Bool] = [:]
    var readCount = 0
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
        if elementName == "Record" {
            parseRecordFromAttributes(attributeDict)
        } else if elementName == "MetadataEntry" {
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
        currentRecord.type = attributeDict["type"]!
        currentRecord.value = Double(attributeDict["value"] ?? "0") ?? 0
        currentRecord.unit = attributeDict["unit"] ?? ""
        if let date = dateFormatter.date(from: attributeDict["startDate"]!) {
            currentRecord.startDate = date
        }
        if let date = dateFormatter.date(from: attributeDict["endDate"]!) {
            currentRecord.endDate = date
        }
        if currentRecord.startDate >  currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = dateFormatter.date(from: attributeDict["creationDate"]!) {
            currentRecord.creationDate = date
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
        if elementName == "Record" || elementName == "Workout" {
            readCount += 1
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
            }
            currentRecord = HealthRecord.init()
        }
    }

    func saveRecord(item: HealthRecord, withSuccess successBlock: @escaping () -> Void, failure failureBlock: @escaping () -> Void) {
        // HealthKit raises an exception if time between end and start date is > 345600
        let duration = item.endDate.timeIntervalSince(item.startDate)
        if duration > 345600 ||
            (item.type == "HKQuantityTypeIdentifierHeadphoneAudioExposure" && duration < 0.001) ||
            (item.type == "HKCategoryTypeIdentifierAudioExposureEvent" && Int(item.value) == 0) {
            failureBlock()
            return
        }

        let unit = HKUnit.init(from: item.unit!)
        let quantity = HKQuantity(unit: unit, doubleValue: item.value)
        var hkSample: HKSample?
        if let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: item.type)) {
            hkSample = HKQuantitySample.init(
                type: type,
                quantity: quantity,
                start: item.startDate,
                end: item.endDate,
                metadata: item.metadata
            )
        } else if let type = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: item.type)) {
            hkSample = HKCategorySample.init(
                type: type,
                value: Int(item.value),
                start: item.startDate,
                end: item.endDate,
                metadata: item.metadata
            )
        } else if item.type == HKObjectType.workoutType().identifier {
            let totalEnergyBurned = item.totalEnergyBurnedUnit == "" ? nil : HKQuantity(unit: HKUnit.init(from: item.totalEnergyBurnedUnit), doubleValue: item.totalEnergyBurned)
            let totalDistance = item.totalDistanceUnit == "" ? nil : HKQuantity(unit: HKUnit.init(from: item.totalDistanceUnit), doubleValue: item.totalDistance)

            hkSample = HKWorkout.init(
                activityType: item.activityType ?? HKWorkoutActivityType(rawValue: 0)!,
                start: item.startDate,
                end: item.endDate,
                duration: HKQuantity(unit: HKUnit.init(from: item.unit!), doubleValue: item.value).doubleValue(for: HKUnit.second()),
                totalEnergyBurned: totalEnergyBurned,
                totalDistance: totalDistance,
                device: nil,
                metadata: item.metadata
            )
        } else if Constants.loggingEnabled {
            os_log("Didn't catch this item: %@", item.description)
        }
        if let hkSample = hkSample,
            authorizedTypes[hkSample.sampleType] ?? false || (self.healthStore?.authorizationStatus(for: hkSample.sampleType) == HKAuthorizationStatus.sharingAuthorized) {
            authorizedTypes[hkSample.sampleType] = true
            allSamples.append(hkSample)
            successBlock()
        } else {
            failureBlock()
        }
    }

    func saveAllSamples() {
        saveSamples(samples: self.allSamples, withSuccess: {}, failure: {})
    }

    func saveSamples(samples: [HKSample], withSuccess successBlock: @escaping () -> Void, failure failureBlock: @escaping () -> Void) {
        self.healthStore?.save(samples, withCompletion: { (success, error) in
            if !success {
                if Constants.loggingEnabled {
                    os_log("An error occured saving the sample. The error was: %@.", error.debugDescription)
                }
                failureBlock()
            }
            DispatchQueue.main.async {
                self.writeCounterLabel?.text = "\(Int((self.writeCounterLabel?.text)!)! + samples.count)"
            }
            successBlock()
        })
    }

}
