//
//  HKimporter.swift
//  HealthKitImporter
//
//  Created by boaz saragossi on 11/7/17.
//  Copyright © 2017 boaz saragossi. All rights reserved.
//

import UIKit
import HealthKit

extension CustomStringConvertible {
    var description : String {
        var description: String = ""
        //if self is AnyObject {
        //    description = "***** \(type(of: self)) - <\(unsafeAddressOf((self as AnyObject)))>***** \n"
        //} else {
        description = "***** \(type(of: self)) *****\n"
        //}
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
}

class HKRecord: CustomStringConvertible {
    var type: String = String()
    var value: Double = 0
    var unit: String?
    var sourceName: String = String()
    var sourceVersion: String = String()
    var startDate: Date = Date()
    var endDate: Date = Date()
    var creationDate: Date = Date()
    
    //for workouts
    var activityType: HKWorkoutActivityType? = HKWorkoutActivityType(rawValue: 0)
    var totalEnergyBurned: Double = 0
    var totalDistance: Double = 0
    var totalEnergyBurnedUnit: String = String()
    var totalDistanceUnit: String = String()

    var metadata: [String:String]?
}

class HKimporter : NSObject, XMLParserDelegate {

    var healthStore:HKHealthStore?
    
    var allHKRecords: [HKRecord] = []
    var allHKSampels: [HKSample] = []
    
    var eName: String = String()
    var currRecord: HKRecord = HKRecord.init()
    
    var readCounterLabel: UILabel? = nil
    var writeCounterLabel: UILabel? = nil
    
    
    convenience init(completion:@escaping ()->Void) {

        self.init()

        self.healthStore = HKHealthStore.init()
        
        let shareReadObjectTypes:Set<HKSampleType>? = [
            HKQuantityType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!,
            HKQuantityType.quantityType(forIdentifier:HKQuantityTypeIdentifier.flightsClimbed)!,
            // Body Measurements
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!,
            // Nutrient
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!,
            //                        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatSaturated)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!,
            //                        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            // Fitness
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKWorkoutType.workoutType(),
            // Category
            HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            
            //Heart rate
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
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodAlcoholContent)!]

        self.healthStore?.requestAuthorization(toShare: shareReadObjectTypes, read: shareReadObjectTypes, completion: { (res, error) in
            if let error = error {
                print(error)
            } else {
                completion()
            }
        })
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        if elementName == "Record" {
            currRecord.type = attributeDict["type"]!
            currRecord.sourceName = attributeDict["sourceName"] ??  ""
            currRecord.sourceVersion = attributeDict["sourceVersion"] ??  ""
            currRecord.value = Double(attributeDict["value"] ?? "0") ?? 0
            currRecord.unit = attributeDict["unit"] ?? ""
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
            if let date = formatter.date(from: attributeDict["startDate"]!) {
                currRecord.startDate = date
            }
            if let date = formatter.date(from: attributeDict["endDate"]!){
                currRecord.endDate = date
            }
            
            if currRecord.startDate >  currRecord.endDate {
                currRecord.startDate = currRecord.endDate
            }
            
            if let date = formatter.date(from: attributeDict["creationDate"]!){
                currRecord.creationDate = date
            }
        } else if elementName == "MetadataEntry" {
            currRecord.metadata = attributeDict
        } else if elementName == "Workout" {
            print(attributeDict)
            currRecord.type = HKObjectType.workoutType().identifier
            currRecord.activityType = activityByName(activityName: attributeDict["workoutActivityType"] ?? "")
            currRecord.sourceName = attributeDict["sourceName"] ??  ""
            currRecord.sourceVersion = attributeDict["sourceVersion"] ??  ""
            currRecord.value = Double(attributeDict["duration"] ?? "0") ?? 0
            currRecord.unit = attributeDict["durationUnit"] ?? ""
            currRecord.totalDistance = Double(attributeDict["totalDistance"] ?? "0") ?? 0
            currRecord.totalDistanceUnit = attributeDict["totalDistanceUnit"] ??  ""
            currRecord.totalEnergyBurned = Double(attributeDict["totalEnergyBurned"] ?? "0") ?? 0
            currRecord.totalEnergyBurnedUnit = attributeDict["totalEnergyBurnedUnit"] ??  ""
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
            if let date = formatter.date(from: attributeDict["startDate"]!) {
                currRecord.startDate = date
            }
            if let date = formatter.date(from: attributeDict["endDate"]!){
                currRecord.endDate = date
            }
            
            if currRecord.startDate >  currRecord.endDate {
                currRecord.startDate = currRecord.endDate
            }
            
            if let date = formatter.date(from: attributeDict["creationDate"]!){
                currRecord.creationDate = date
            }
        } else if elementName == "Correlation" {
            return
        } else {
            return
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Record" || elementName == "Workout" {

            allHKRecords.append(currRecord)
            print(currRecord.description)
            DispatchQueue.main.async {
                self.readCounterLabel?.text = "\(self.allHKRecords.count)"
            }
            saveHKRecord(item: currRecord, withSuccess: {
                // success
                //print("record added to array")
            }, failure: {
                // fail
                print("fail to process record")
            })
        }
    }
    
    func saveHKRecord(item:HKRecord, withSuccess successBlock: @escaping () -> Void, failure failiureBlock: @escaping () -> Void) {
      
        let unit = HKUnit.init(from: item.unit!)
        let quantity = HKQuantity(unit: unit, doubleValue: item.value)
        
        var hkSample: HKSample? = nil
        if let type = HKQuantityType.quantityType(forIdentifier:  HKQuantityTypeIdentifier(rawValue: item.type)) {
            hkSample = HKQuantitySample.init(type: type, quantity: quantity, start: item.startDate, end: item.endDate, metadata: item.metadata)
        } else if let type = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: item.type)) {
            hkSample = HKCategorySample.init(type: type, value: Int(item.value), start: item.startDate, end: item.endDate, metadata: item.metadata)
        } else if item.type == HKObjectType.workoutType().identifier {
            hkSample = HKWorkout.init(activityType: HKWorkoutActivityType(rawValue: 0)!, start: item.startDate, end: item.endDate, duration: item.value, totalEnergyBurned: HKQuantity(unit: HKUnit.init(from: item.totalEnergyBurnedUnit), doubleValue: item.totalEnergyBurned), totalDistance: HKQuantity(unit: HKUnit.init(from: item.totalDistanceUnit), doubleValue: item.totalDistance), device: nil, metadata: item.metadata)
        } else {
            print("didnt catch this item - \(item)")
        }
        
        if let hkSample = hkSample, (self.healthStore?.authorizationStatus(for: hkSample.sampleType) == HKAuthorizationStatus.sharingAuthorized) {
            allHKSampels.append(hkSample)
            successBlock()
        } else {
            failiureBlock()
        }
    }
    
    func saveAllSamples() {
        saveSamplesToHK(samples: self.allHKSampels, withSuccess: {
            //
        }, failure: {
            //
        })
    }
    func saveSamplesToHK (samples:[HKSample], withSuccess successBlock: @escaping () -> Void, failure failiureBlock: @escaping () -> Void) {
        self.healthStore?.save(samples, withCompletion: { (success, error) in
            if (!success) {
                print(String(format: "An error occured saving the sample. The error was: %@.", error.debugDescription))
                failiureBlock()
            }
            DispatchQueue.main.async {
                self.writeCounterLabel?.text = "\(Int((self.writeCounterLabel?.text)!)! + samples.count)"
            }
            successBlock()
        })
    }

    func activityByName(activityName: String) -> HKWorkoutActivityType {
        var res = HKWorkoutActivityType(rawValue: 0)
        switch activityName {
        case "HKWorkoutActivityTypeWalking":
            res = HKWorkoutActivityType.walking
        case "HKWorkoutActivityTypeRunning":
            res = HKWorkoutActivityType.running
        case "HKWorkoutActivityTypeCycling":
            res = HKWorkoutActivityType.cycling
        case "HKWorkoutActivityTypeMixedMetabolicCardioTraining":
            res = HKWorkoutActivityType.mixedMetabolicCardioTraining
        case "HKWorkoutActivityTypeYoga":
            res = HKWorkoutActivityType.yoga
        case "HKWorkoutActivityTypeFunctionalStrengthTraining":
            res = HKWorkoutActivityType.functionalStrengthTraining
        case "HKWorkoutActivityTypeTraditionalStrengthTraining":
            res = HKWorkoutActivityType.traditionalStrengthTraining
        case "HKWorkoutActivityTypeDance":
            res = HKWorkoutActivityType.dance
        default:
            print ("???????")
            print ("Add support for activity - \(activityName)")
            break;
        }
        return res!
    }
}
