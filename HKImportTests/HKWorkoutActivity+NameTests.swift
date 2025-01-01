//
//  HKWorkoutActivity+NameTests.swift
//  HKImport
//
//  Created by Jon Carl on 1/1/25.
//  Copyright © 2025 boaz saragossi. All rights reserved.
//

import Testing
@testable import HKImport
import HealthKit

struct HKWorkoutActivityNameTests {
    @Test func basicWorkout() async throws {
        let workout = HKWorkoutActivityType.activityTypeFromString("HKWorkoutActivityTypeRunning")

        #expect(workout == .running)
    }

    @Test func workoutWithMultipleWords() async throws {
        let workout = HKWorkoutActivityType.activityTypeFromString("HKWorkoutActivityTypeCrossTraining")

        #expect(workout == .crossTraining)
    }

}
