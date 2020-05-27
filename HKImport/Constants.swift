// Created by Thomas Dohmke on 5/26/20.

import UIKit
import HealthKit

class Constants {
    static let loggingEnabled = false

    static let allSampleTypes: Set<HKSampleType>? = [
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

}
