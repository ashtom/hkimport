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

    var allRecords: [HealthRecord] = []
    var allSamples: [HKSample] = []
    var eName: String = String()
    var currentRecord: HealthRecord = HealthRecord.init()
    var readCounterLabel: UILabel?
    var writeCounterLabel: UILabel?
    var formatter: NumberFormatter?

    // swiftlint:disable:next function_body_length
    convenience init(completion: @escaping () -> Void) {
        self.init()

        self.healthStore = HKHealthStore.init()
        let shareReadObjectTypes: Set<HKSampleType>? = [
            // Body Measurements
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!,
            // Nutrient
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            // Fitness
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKWorkoutType.workoutType(),
            // Category
            HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            // Heart rate
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!,
            // Measurements
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.leanBodyMass)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!,
            // Nutrients
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatPolyunsaturated)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatMonounsaturated)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatSaturated)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFiber)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminA)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminB6)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminB12)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminC)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminD)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminE)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminK)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCalcium)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryIron)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryThiamin)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryRiboflavin)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryNiacin)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFolate)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryBiotin)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryPantothenicAcid)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryPhosphorus)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryIodine)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryMagnesium)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryZinc)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySelenium)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCopper)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryManganese)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryChromium)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryMolybdenum)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryChloride)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryPotassium)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.uvExposure)!,
            // Fitness
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
            // Results
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalBodyTemperature)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodAlcoholContent)!
        ]
        self.healthStore?.requestAuthorization(toShare: shareReadObjectTypes, read: shareReadObjectTypes, completion: { _, error in
            if let error = error {
                os_log("Error: %@", error.localizedDescription)
            } else {
                completion()
            }
        })

        self.formatter = NumberFormatter.init()
        formatter?.locale = Locale.current
        formatter?.numberStyle = .decimal
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        eName = elementName
        if elementName == "Record" {
            parseRecordFromAttributes(attributeDict)
        } else if elementName == "MetadataEntry" {
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
                        value = HKQuantity.init(unit: .percent(), doubleValue: (formatter?.number(from: String(components.first!))!.doubleValue)!)
                    }
                }
            }

            currentRecord.metadata = [String: Any]()
            if let key = key, let value = value, key != "HKMetadataKeySyncIdentifier" {
                currentRecord.metadata?[key] = value
                print(currentRecord.metadata!)
            }
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        if let date = formatter.date(from: attributeDict["startDate"]!) {
            currentRecord.startDate = date
        }
        if let date = formatter.date(from: attributeDict["endDate"]!) {
            currentRecord.endDate = date
        }
        if currentRecord.startDate >  currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = formatter.date(from: attributeDict["creationDate"]!) {
            currentRecord.creationDate = date
        }
    }

    fileprivate func parseWorkoutFromAttributes(_ attributeDict: [String: String]) {
        currentRecord.type = HKObjectType.workoutType().identifier
        currentRecord.activityType = HKWorkoutActivityType.activityTypeForExportedString(attributeDict["workoutActivityType"] ?? "")
        currentRecord.sourceName = attributeDict["sourceName"] ??  ""
        currentRecord.sourceVersion = attributeDict["sourceVersion"] ??  ""
        currentRecord.value = Double(attributeDict["duration"] ?? "0") ?? 0
        currentRecord.unit = attributeDict["durationUnit"] ?? ""
        currentRecord.totalDistance = Double(attributeDict["totalDistance"] ?? "0") ?? 0
        currentRecord.totalDistanceUnit = attributeDict["totalDistanceUnit"] ??  ""
        currentRecord.totalEnergyBurned = Double(attributeDict["totalEnergyBurned"] ?? "0") ?? 0
        currentRecord.totalEnergyBurnedUnit = attributeDict["totalEnergyBurnedUnit"] ??  ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        if let date = formatter.date(from: attributeDict["startDate"]!) {
            currentRecord.startDate = date
        }
        if let date = formatter.date(from: attributeDict["endDate"]!) {
            currentRecord.endDate = date
        }
        if currentRecord.startDate >  currentRecord.endDate {
            currentRecord.startDate = currentRecord.endDate
        }
        if let date = formatter.date(from: attributeDict["creationDate"]!) {
            currentRecord.creationDate = date
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Record" || elementName == "Workout" {

            allRecords.append(currentRecord)
            os_log("Record: %@", currentRecord.description)
            DispatchQueue.main.async {
                self.readCounterLabel?.text = "\(self.allRecords.count)"
            }
            saveRecord(item: currentRecord, withSuccess: {
            }, failure: {
                os_log("fail to process record")
            })
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
        } else {
            os_log("Didn't catch this item: %@", item.description)
        }
        if let hkSample = hkSample, (self.healthStore?.authorizationStatus(for: hkSample.sampleType) == HKAuthorizationStatus.sharingAuthorized) {
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
                os_log("An error occured saving the sample. The error was: %@.", error.debugDescription)
                failureBlock()
            }
            DispatchQueue.main.async {
                self.writeCounterLabel?.text = "\(Int((self.writeCounterLabel?.text)!)! + samples.count)"
            }
            successBlock()
        })
    }

}

extension HKWorkoutActivityType {
    static func activityTypeForExportedString(_ string: String) -> HKWorkoutActivityType {
        var result = HKWorkoutActivityType(rawValue: 0)
        switch string {
        case "HKWorkoutActivityTypeSwimming":
            result = HKWorkoutActivityType.swimming
        case "HKWorkoutActivityTypeWalking":
            result = HKWorkoutActivityType.walking
        case "HKWorkoutActivityTypeRunning":
            result = HKWorkoutActivityType.running
        case "HKWorkoutActivityTypeCycling":
            result = HKWorkoutActivityType.cycling
        case "HKWorkoutActivityTypeYoga":
            result = HKWorkoutActivityType.yoga
        case "HKWorkoutActivityTypeFunctionalStrengthTraining":
            result = HKWorkoutActivityType.functionalStrengthTraining
        case "HKWorkoutActivityTypeTraditionalStrengthTraining":
            result = HKWorkoutActivityType.traditionalStrengthTraining
        case "HKWorkoutActivityTypeDance":
            result = HKWorkoutActivityType.dance
        default:
            os_log("No support for activity: %@", string)
        }
        return result!
    }
}
