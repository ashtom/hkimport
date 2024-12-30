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

        try #require(importer.allSamples.count == 1)

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

    @Test func workout_with_stats_attributes() async throws {
        let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<HealthData locale="en_US">
<Workout workoutActivityType="HKWorkoutActivityTypeWalking" duration="55.68215045134227" durationUnit="min" startDate="2024-12-23 10:56:58 -0600" endDate="2024-12-23 11:52:39 -0600" totalDistance="2.96163" totalDistanceUnit="mi" totalEnergyBurned="372.488" totalEnergyBurnedUnit="kcal">
 </Workout>
</HealthData>
"""
        let importer = Importer()
        importer.authorizedTypes = [.workoutType(): true]

        let parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()

        try #require(importer.allSamples.count == 1)

        // swiftlint:disable:next force_cast
        let workout = importer.allSamples[0] as! HKWorkout
        let expectedStartDate = buildDate(year: 2024, month: 12, day: 23, hour: 10, minute: 56, second: 58)
        let expectedEndDate = buildDate(year: 2024, month: 12, day: 23, hour: 11, minute: 52, second: 39)

        #expect(workout.workoutActivityType == .walking)
        #expect(workout.startDate == expectedStartDate)
        #expect(workout.endDate == expectedEndDate)
        #expect(workout.duration == 3340.929027080536)
        #expect(workout.totalDistance?.doubleValue(for: .mile()) == 2.96163)
        #expect(workout.totalEnergyBurned?.doubleValue(for: .largeCalorie()) == 372.488)
    }

    @Test func workout_with_stats_elements() async throws {
        let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<HealthData locale="en_US">
<Workout workoutActivityType="HKWorkoutActivityTypeRunning" duration="30.38167053262393" durationUnit="min" sourceName="Testing" creationDate="2024-12-23 07:09:37 -0600" startDate="2024-12-23 06:38:53 -0600" endDate="2024-12-23 07:09:16 -0600">
  <MetadataEntry key="HKIndoorWorkout" value="0"/>
  <MetadataEntry key="HKWeatherTemperature" value="46 degF"/>
  <MetadataEntry key="HKTimeZone" value="America/Denver"/>
  <MetadataEntry key="HKWeatherHumidity" value="6100 %"/>
  <MetadataEntry key="HKElevationAscended" value="918 cm"/>
  <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" startDate="2024-12-23 06:38:53 -0600" endDate="2024-12-23 07:09:16 -0600" sum="372.488" unit="kcal"/>
  <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" startDate="2024-12-23 06:38:53 -0600" endDate="2024-12-23 07:09:16 -0600" sum="2.96163" unit="mi"/>
  <WorkoutStatistics type="HKQuantityTypeIdentifierBasalEnergyBurned" startDate="2024-12-23 06:38:53 -0600" endDate="2024-12-23 07:09:16 -0600" sum="59.0324" unit="Cal"/>
</Workout>
</HealthData>
"""
        let importer = Importer()
        importer.authorizedTypes = [.workoutType(): true]

        let parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()

        try #require(importer.allSamples.count == 1)

        // swiftlint:disable:next force_cast
        let workout = importer.allSamples[0] as! HKWorkout
        let expectedStartDate = buildDate(year: 2024, month: 12, day: 23, hour: 6, minute: 38, second: 53)
        let expectedEndDate = buildDate(year: 2024, month: 12, day: 23, hour: 7, minute: 9, second: 16)
        let expectedMetadataKeys = Set([
            HKMetadataKeyIndoorWorkout,
            HKMetadataKeyWeatherTemperature,
            HKMetadataKeyTimeZone,
            HKMetadataKeyWeatherHumidity,
            HKMetadataKeyElevationAscended
        ])

        #expect(workout.workoutActivityType == .running)
        #expect(workout.startDate == expectedStartDate)
        #expect(workout.endDate == expectedEndDate)
        #expect(workout.duration == 1822.9002319574356)
        #expect(workout.totalDistance?.doubleValue(for: .mile()) == 2.96163)
        #expect(workout.totalEnergyBurned?.doubleValue(for: .largeCalorie()) == 372.488)

        let metadata = workout.metadata!
        let expectedTemp = HKQuantity(unit: .degreeFahrenheit(), doubleValue: 46)
        let expectedHumidity = HKQuantity(unit: .percent(), doubleValue: 6100)
        let expectedElevationAsc = HKQuantity(unit: .meterUnit(with: .centi), doubleValue: 918)

        #expect(Set(metadata.keys) == expectedMetadataKeys)
        #expect(metadata[HKMetadataKeyIndoorWorkout] as? Int == 0)
        #expect(metadata[HKMetadataKeyWeatherTemperature] as? HKQuantity == expectedTemp)
        #expect(metadata[HKMetadataKeyTimeZone] as? String == "America/Denver")
        #expect(metadata[HKMetadataKeyWeatherHumidity] as? HKQuantity == expectedHumidity)
        #expect(metadata[HKMetadataKeyElevationAscended] as? HKQuantity == expectedElevationAsc)
    }

    @Test func record_with_bad_metadata_unit() async throws {
        let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<HealthData locale="en_US">
 <Record type="HKQuantityTypeIdentifierDietaryFatSaturated" sourceName="Testing" unit="g" creationDate="2024-12-23 19:38:40 -0600" startDate="2024-12-23 19:00:00 -0600" endDate="2024-12-23 19:00:00 -0600" value="2.91379">
  <MetadataEntry key="HKFoodBrandName" value="13 Chips"/>
 </Record>
</HealthData>
"""
        let importer = Importer()
        importer.authorizedTypes = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatSaturated)!: true]

        let parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()

        try #require(importer.allSamples.count == 1)

        // swiftlint:disable:next force_cast
        let sample = importer.allSamples[0] as! HKQuantitySample
        let expectedQuantity = HKQuantity(unit: .gram(), doubleValue: 2.91379)
        let expectedStartDate = buildDate(year: 2024, month: 12, day: 23, hour: 19, minute: 0, second: 0)
        let expectedEndDate = buildDate(year: 2024, month: 12, day: 23, hour: 19, minute: 0, second: 0)
        let expectedMetadataKeys = Set([
            "HKFoodBrandName"
        ])

        #expect(sample.quantityType.identifier == HKQuantityTypeIdentifier.dietaryFatSaturated.rawValue)
        #expect(sample.quantity == expectedQuantity)
        #expect(sample.startDate == expectedStartDate)
        #expect(sample.endDate == expectedEndDate)

        let metadata = sample.metadata!

        #expect(Set(metadata.keys) == expectedMetadataKeys)
        #expect(metadata["HKFoodBrandName"] as? String == "13 Chips")
    }

    @Test func record_with_metadata_date_value() async throws {
        let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<HealthData locale="en_US">
 <Record type="HKQuantityTypeIdentifierSixMinuteWalkTestDistance" sourceName="Testing" unit="m" creationDate="2024-12-23 13:27:55 -0600" startDate="2024-12-23 13:27:55 -0600" endDate="2024-12-23 13:27:55 -0600" value="500">
  <MetadataEntry key="HKDateOfEarliestDataUsedForEstimate" value="2024-12-23 06:00:00 +0000"/>
  <MetadataEntry key="HKMetadataKeyAppleDeviceCalibrated" value="1"/>
 </Record>
</HealthData>
"""
        let importer = Importer()
        importer.authorizedTypes = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.sixMinuteWalkTestDistance)!: true]

        let parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()

        try #require(importer.allSamples.count == 1)

        // swiftlint:disable:next force_cast
        let sample = importer.allSamples[0] as! HKQuantitySample
        let expectedQuantity = HKQuantity(unit: .meter(), doubleValue: 500)
        let expectedStartDate = buildDate(year: 2024, month: 12, day: 23, hour: 13, minute: 27, second: 55)
        let expectedEndDate = buildDate(year: 2024, month: 12, day: 23, hour: 13, minute: 27, second: 55)
        let expectedMetadataKeys = Set([
            HKMetadataKeyDateOfEarliestDataUsedForEstimate,
            HKMetadataKeyAppleDeviceCalibrated
        ])

        #expect(sample.quantityType.identifier == HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue)
        #expect(sample.quantity == expectedQuantity)
        #expect(sample.startDate == expectedStartDate)
        #expect(sample.endDate == expectedEndDate)

        let metadata = sample.metadata!
        let expectedMetadataDate = buildDate(year: 2024, month: 12, day: 23, hour: 0, minute: 0, second: 0)

        #expect(Set(metadata.keys) == expectedMetadataKeys)
        #expect(metadata[HKMetadataKeyDateOfEarliestDataUsedForEstimate] as? Date == expectedMetadataDate)
        #expect(metadata[HKMetadataKeyAppleDeviceCalibrated] as? Int == 1)
    }
}
