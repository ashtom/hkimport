//
//  HKImportTests.swift
//  HKImportTests
//
//  Created by Jon Carl on 12/23/24.
//  Copyright © 2024 Jon Carl. All rights reserved.
//

import Testing
@testable import HKImport
import Foundation
import HealthKit

// swiftlint:disable:next function_parameter_count
func buildDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
    // NOTE: to handle date parsing and timezones we always use UTC -6 as the timezone.
    var timezone = TimeZone(secondsFromGMT: -21600)!
    if timezone.isDaylightSavingTime() {
        timezone = TimeZone(secondsFromGMT: -25200)!
    }

    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.timeZone = timezone
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = second

    return Calendar.current.date(from: dateComponents)!
}

struct HKImportTests {

    @Test func basicWorkout() async throws {
        let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<HealthData locale="en_US">
<Workout workoutActivityType="HKWorkoutActivityTypeWalking" duration="55.68215045134227" durationUnit="min" startDate="2024-12-23 10:56:58 -0600" endDate="2024-12-23 11:52:39 -0600">
 </Workout>
</HealthData>
"""
        let importer = Importer()
        importer.authorizedTypes = [.workoutType(): true]

        let parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()

        #expect(importer.allSamples.count == 1)

        // swiftlint:disable:next force_cast
        let workout = importer.allSamples[0] as! HKWorkout
        let expectedStartDate = buildDate(year: 2024, month: 12, day: 23, hour: 10, minute: 56, second: 58)
        let expectedEndDate = buildDate(year: 2024, month: 12, day: 23, hour: 11, minute: 52, second: 39)

        #expect(workout.workoutActivityType == .walking)
        #expect(workout.startDate == expectedStartDate)
        #expect(workout.endDate == expectedEndDate)
        #expect(workout.duration == 3340.929027080536)
        #expect(workout.totalDistance == nil)
        #expect(workout.totalEnergyBurned == nil)
    }
}
