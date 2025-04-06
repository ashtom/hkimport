// Created by Thomas Dohmke on 5/26/20.

import UIKit
import HealthKit

class Constants {
    static let loggingEnabled = false

    static var allSampleTypes: Set<HKSampleType>? {
        return buildAllSampleTypes()
    }
}

// NOTE: types generated using script
// To regenerate the types, run the following from terminal in the root of the repo:
//   ./scripts/generate_sample_types.sh | pbcopy
// This will fill your clipboard with generated types. Paste the result between the marks below.
//
// swiftlint:disable:next function_body_length cyclomatic_complexity private_over_fileprivate
fileprivate func buildAllSampleTypes() -> Set<HKSampleType> {
    var base: Set<HKSampleType> = [
        HKQuantityType.workoutType()
    ]

    // MARK: - BEGIN PASTE FROM SCRIPT OUTPUT
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBodyFatPercentage"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBodyMass"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBodyMassIndex"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierElectrodermalActivity"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierHeight"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierLeanBodyMass"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierWaistCircumference"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierActiveEnergyBurned"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBasalEnergyBurned"))!)
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierCrossCountrySkiingSpeed"))!)
    }
    if #available(iOS 17.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierCyclingCadence"))!)
    }
    if #available(iOS 17.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierCyclingFunctionalThresholdPower"))!)
    }
    if #available(iOS 17.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierCyclingPower"))!)
    }
    if #available(iOS 17.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierCyclingSpeed"))!)
    }
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceCrossCountrySkiing"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceCycling"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceDownhillSnowSports"))!)
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistancePaddleSports"))!)
    }
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceRowing"))!)
    }
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceSkatingSports"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceSwimming"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceWalkingRunning"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDistanceWheelchair"))!)
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierEstimatedWorkoutEffortScore"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierFlightsClimbed"))!)
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierPaddleSportsSpeed"))!)
    }
    if #available(iOS 17.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierPhysicalEffort"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierPushCount"))!)
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRowingSpeed"))!)
    }
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRunningPower"))!)
    }
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRunningSpeed"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierStepCount"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierSwimmingStrokeCount"))!)
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierUnderwaterDepth"))!)
    }
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierWorkoutEffortScore"))!)
    }
    if #available(iOS 13.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierEnvironmentalAudioExposure"))!)
    }
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierEnvironmentalSoundReduction"))!)
    }
    if #available(iOS 13.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierHeadphoneAudioExposure"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierHeartRate"))!)
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierHeartRateRecoveryOneMinute"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierHeartRateVariabilitySDNN"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierPeripheralPerfusionIndex"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRestingHeartRate"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierVO2Max"))!)
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRunningGroundContactTime"))!)
    }
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRunningStrideLength"))!)
    }
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRunningVerticalOscillation"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierSixMinuteWalkTestDistance"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierStairAscentSpeed"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierStairDescentSpeed"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierWalkingDoubleSupportPercentage"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierWalkingSpeed"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierWalkingStepLength"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryBiotin"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryCaffeine"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryCalcium"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryCarbohydrates"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryChloride"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryCholesterol"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryChromium"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryCopper"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryEnergyConsumed"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryFatMonounsaturated"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryFatPolyunsaturated"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryFatSaturated"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryFatTotal"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryFiber"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryFolate"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryIodine"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryIron"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryMagnesium"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryManganese"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryMolybdenum"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryNiacin"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryPantothenicAcid"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryPhosphorus"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryPotassium"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryProtein"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryRiboflavin"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietarySelenium"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietarySodium"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietarySugar"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryThiamin"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminA"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminB12"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminB6"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminC"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminD"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminE"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryVitaminK"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryWater"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierDietaryZinc"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBloodAlcoholContent"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBloodPressureDiastolic"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBloodPressureSystolic"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierInsulinDelivery"))!)
    if #available(iOS 15.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierNumberOfAlcoholicBeverages"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierNumberOfTimesFallen"))!)
    if #available(iOS 17.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierTimeInDaylight"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierUVExposure"))!)
    if #available(iOS 16.0, *) {
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierWaterTemperature"))!)
    }
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBasalBodyTemperature"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierForcedExpiratoryVolume1"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierForcedVitalCapacity"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierInhalerUsage"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierOxygenSaturation"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierPeakExpiratoryFlowRate"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierRespiratoryRate"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBloodGlucose"))!)
    base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifierBodyTemperature"))!)
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierMindfulSession"))!)
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierHandwashingEvent"))!)
    }
    if #available(iOS 13.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierToothbrushingEvent"))!)
    }
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierBleedingAfterPregnancy"))!)
    }
    if #available(iOS 18.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierBleedingDuringPregnancy"))!)
    }
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierCervicalMucusQuality"))!)
    if #available(iOS 14.3, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierContraceptive"))!)
    }
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierIntermenstrualBleeding"))!)
    if #available(iOS 14.3, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierLactation"))!)
    }
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierMenstrualFlow"))!)
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierOvulationTestResult"))!)
    if #available(iOS 14.3, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierPregnancy"))!)
    }
    if #available(iOS 15.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierPregnancyTestResult"))!)
    }
    if #available(iOS 15.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierProgesteroneTestResult"))!)
    }
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierSexualActivity"))!)
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierSleepAnalysis"))!)
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierAbdominalCramps"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierAcne"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierAppetiteChanges"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierBladderIncontinence"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierBloating"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierBreastPain"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierChestTightnessOrPain"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierChills"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierConstipation"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierCoughing"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierDiarrhea"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierDizziness"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierDrySkin"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierFainting"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierFatigue"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierFever"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierGeneralizedBodyAche"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierHairLoss"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierHeadache"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierHeartburn"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierHotFlashes"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierLossOfSmell"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierLossOfTaste"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierLowerBackPain"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierMemoryLapse"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierMoodChanges"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierNausea"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierNightSweats"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierPelvicPain"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierRapidPoundingOrFlutteringHeartbeat"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierRunnyNose"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierShortnessOfBreath"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierSinusCongestion"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierSkippedHeartbeat"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierSleepChanges"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierSoreThroat"))!)
    }
    if #available(iOS 14.0, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierVaginalDryness"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierVomiting"))!)
    }
    if #available(iOS 13.6, *) {
    base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierWheezing"))!)
    }
    // MARK: - END PASTE FROM SCRIPT OUTPUT

    return base
}
