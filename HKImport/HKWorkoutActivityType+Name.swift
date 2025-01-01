import UIKit
import HealthKit

extension HKWorkoutActivityType {
    static func activityTypeFromString(_ string: String) -> HKWorkoutActivityType {
        let  name = string.replacingOccurrences(of: "HKWorkoutActivityType", with: "")
        return (values[name] ?? HKWorkoutActivityType.other)!
    }

    static var values: [String: Self] {
        var values: [String: Self] = [:]
        var index: UInt = 1
        while let element = self.init(rawValue: index) {
            values[element.name] = element
            index += 1

            if element == .other { break }
        }
        return values
    }

    // NOTE: switch cases generated using script
    // To regenerate the cases, run the following from terminal in the root of the repo:
    //   ./scripts/generate_workout_names_mapping.sh | pbcopy
    // This will fill your clipboard with generated cases. Paste the result between the marks below.
    var name: String {
        switch self {
            // MARK: - BEGIN PASTE FROM SCRIPT OUTPUT
        case .americanFootball: return "AmericanFootball"
        case .archery: return "Archery"
        case .australianFootball: return "AustralianFootball"
        case .badminton: return "Badminton"
        case .baseball: return "Baseball"
        case .basketball: return "Basketball"
        case .bowling: return "Bowling"
        case .boxing: return "Boxing"
        case .climbing: return "Climbing"
        case .cricket: return "Cricket"
        case .crossTraining: return "CrossTraining"
        case .curling: return "Curling"
        case .cycling: return "Cycling"
        case .dance: return "Dance"
        case .danceInspiredTraining: return "DanceInspiredTraining"
        case .elliptical: return "Elliptical"
        case .equestrianSports: return "EquestrianSports"
        case .fencing: return "Fencing"
        case .fishing: return "Fishing"
        case .functionalStrengthTraining: return "FunctionalStrengthTraining"
        case .golf: return "Golf"
        case .gymnastics: return "Gymnastics"
        case .handball: return "Handball"
        case .hiking: return "Hiking"
        case .hockey: return "Hockey"
        case .hunting: return "Hunting"
        case .lacrosse: return "Lacrosse"
        case .martialArts: return "MartialArts"
        case .mindAndBody: return "MindAndBody"
        case .mixedMetabolicCardioTraining: return "MixedMetabolicCardioTraining"
        case .paddleSports: return "PaddleSports"
        case .play: return "Play"
        case .preparationAndRecovery: return "PreparationAndRecovery"
        case .racquetball: return "Racquetball"
        case .rowing: return "Rowing"
        case .rugby: return "Rugby"
        case .running: return "Running"
        case .sailing: return "Sailing"
        case .skatingSports: return "SkatingSports"
        case .snowSports: return "SnowSports"
        case .soccer: return "Soccer"
        case .softball: return "Softball"
        case .squash: return "Squash"
        case .stairClimbing: return "StairClimbing"
        case .surfingSports: return "SurfingSports"
        case .swimming: return "Swimming"
        case .tableTennis: return "TableTennis"
        case .tennis: return "Tennis"
        case .trackAndField: return "TrackAndField"
        case .traditionalStrengthTraining: return "TraditionalStrengthTraining"
        case .volleyball: return "Volleyball"
        case .walking: return "Walking"
        case .waterFitness: return "WaterFitness"
        case .waterPolo: return "WaterPolo"
        case .waterSports: return "WaterSports"
        case .wrestling: return "Wrestling"
        case .yoga: return "Yoga"
        case .barre: return "Barre"
        case .coreTraining: return "CoreTraining"
        case .crossCountrySkiing: return "CrossCountrySkiing"
        case .downhillSkiing: return "DownhillSkiing"
        case .flexibility: return "Flexibility"
        case .highIntensityIntervalTraining: return "HighIntensityIntervalTraining"
        case .jumpRope: return "JumpRope"
        case .kickboxing: return "Kickboxing"
        case .pilates: return "Pilates"
        case .snowboarding: return "Snowboarding"
        case .stairs: return "Stairs"
        case .stepTraining: return "StepTraining"
        case .wheelchairWalkPace: return "WheelchairWalkPace"
        case .wheelchairRunPace: return "WheelchairRunPace"
        case .taiChi: return "TaiChi"
        case .mixedCardio: return "MixedCardio"
        case .handCycling: return "HandCycling"
        case .discSports: return "DiscSports"
        case .fitnessGaming: return "FitnessGaming"
        case .cardioDance: return "CardioDance"
        case .socialDance: return "SocialDance"
        case .pickleball: return "Pickleball"
        case .cooldown: return "Cooldown"
        case .swimBikeRun: return "SwimBikeRun"
        case .transition: return "Transition"
        case .underwaterDiving: return "UnderwaterDiving"
        case .other: return "Other"
            // MARK: - END PASTE FROM SCRIPT OUTPUT
        default:
            return "Other"
        }
    }
}
