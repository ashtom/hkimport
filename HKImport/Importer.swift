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
    var sourceName: String = String()
    var sourceVersion: String = String()
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

class Importer: NSObject, XMLParserDelegate {
    var healthStore: HKHealthStore?

    var cutDate: Date?
    var allSamples: [HKSample] = []
    var authorizedTypes: [HKSampleType: Bool] = [:]
    var readCount = 0
    var currentRecord: HealthRecord = HealthRecord.init()
    var readCounterLabel: UILabel?
    var writeCounterLabel: UILabel?
    var numberFormatter: NumberFormatter?
    var dateFormatter: DateFormatter?

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

        self.numberFormatter = NumberFormatter.init()
        numberFormatter?.locale = Locale.current
        numberFormatter?.numberStyle = .decimal

        self.dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        // Uncomment if you only want to import the last 6 months
        // self.cutDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        if elementName == "Record" {
            parseRecordFromAttributes(attributeDict)
        } else if elementName == "MetadataEntry" {
            parseMetaDataFromAttributes(attributeDict)
        } else if elementName == "Workout" {
            parseWorkoutFromAttributes(attributeDict)
        } else {
            return
        }
    }

    fileprivate func parseRecordFromAttributes(_ attributeDict: [String: String]) {
        currentRecord.type = attributeDict["type"]!
        currentRecord.sourceName = attributeDict["sourceName"] ??  ""
        currentRecord.sourceVersion = attributeDict["sourceVersion"] ??  ""
        currentRecord.value = Double(attributeDict["value"] ?? "0") ?? 0
        currentRecord.unit = attributeDict["unit"] ?? ""
        if let date = dateFormatter?.date(from: attributeDict["startDate"]!) {
            currentRecord.startDate = date
        }
        if let date = dateFormatter?.date(from: attributeDict["endDate"]!) {
            currentRecord.endDate = date
        }
        if currentRecord.startDate >  currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = dateFormatter?.date(from: attributeDict["creationDate"]!) {
            currentRecord.creationDate = date
        }
    }

    fileprivate func parseMetaDataFromAttributes(_ attributeDict: [String: String]) {
        var key: String?
        var value: Any?
        for (attributeKey, attributeValue) in attributeDict {
            if attributeKey == "key" {
                key = attributeValue
            }
            if attributeKey == "value" {
                if let intValue = Int(attributeValue) {
                    value = intValue
                } else {
                    value = attributeValue
                }
                if attributeValue.hasSuffix("%") {
                    let components = attributeValue.split(separator: " ")
                    value = HKQuantity.init(unit: .percent(), doubleValue: (numberFormatter?.number(from: String(components.first!))!.doubleValue)!)
                }
            }
        }

        currentRecord.metadata = [String: Any]()
        if let key = key, let value = value, key != "HKMetadataKeySyncIdentifier" {
            currentRecord.metadata?[key] = value
        }
    }

    fileprivate func parseWorkoutFromAttributes(_ attributeDict: [String: String]) {
        currentRecord.type = HKObjectType.workoutType().identifier
        currentRecord.activityType = HKWorkoutActivityType.activityTypeFromString(attributeDict["workoutActivityType"] ?? "")
        currentRecord.sourceName = attributeDict["sourceName"] ??  ""
        currentRecord.sourceVersion = attributeDict["sourceVersion"] ??  ""
        currentRecord.value = Double(attributeDict["duration"] ?? "0") ?? 0
        currentRecord.unit = attributeDict["durationUnit"] ?? ""
        currentRecord.totalDistance = Double(attributeDict["totalDistance"] ?? "0") ?? 0
        currentRecord.totalDistanceUnit = attributeDict["totalDistanceUnit"] ??  ""
        currentRecord.totalEnergyBurned = Double(attributeDict["totalEnergyBurned"] ?? "0") ?? 0
        currentRecord.totalEnergyBurnedUnit = attributeDict["totalEnergyBurnedUnit"] ??  ""
        if let date = dateFormatter?.date(from: attributeDict["startDate"]!) {
            currentRecord.startDate = date
        }
        if let date = dateFormatter?.date(from: attributeDict["endDate"]!) {
            currentRecord.endDate = date
        }
        if currentRecord.startDate > currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = dateFormatter?.date(from: attributeDict["creationDate"]!) {
            currentRecord.creationDate = date
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
        if duration > 345600 {
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
            hkSample = HKWorkout.init(
                activityType: item.activityType ?? HKWorkoutActivityType(rawValue: 0)!,
                start: item.startDate,
                end: item.endDate,
                duration: HKQuantity(unit: HKUnit.init(from: item.unit!), doubleValue: item.value).doubleValue(for: HKUnit.second()),
                totalEnergyBurned: HKQuantity(unit: HKUnit.init(from: item.totalEnergyBurnedUnit), doubleValue: item.totalEnergyBurned),
                totalDistance: HKQuantity(unit: HKUnit.init(from: item.totalDistanceUnit), doubleValue: item.totalDistance),
                device: nil,
                metadata: item.metadata
            )
        } else if Constants.loggingEnabled {
            os_log("Didn't catch this item: %@", item.description)
        }
        if let hkSample = hkSample,
            (authorizedTypes[hkSample.sampleType] ?? false || (self.healthStore?.authorizationStatus(for: hkSample.sampleType) == HKAuthorizationStatus.sharingAuthorized)) {
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
