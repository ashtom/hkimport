//
//  DuplicateCheckTests.swift
//  HKImportTests
//
//  The duplicate check is tested with real HealthKit sample types and a fake list of
//  "existing" samples. It does not talk to a real Health store, which would need the
//  user to approve the Health permission sheet.
//

import Testing
@testable import HKImport
import Foundation
import HealthKit

/// An Importer whose "Health store" is a fixed list of samples.
final class FakeStoreImporter: Importer {
    var existing: [HKSample] = []

    override func fetchExistingSamples(of sampleType: HKSampleType, start: Date, end: Date, completion: @escaping ([HKSample]) -> Void) {
        completion(existing.filter { $0.sampleType == sampleType })
    }
}

struct DuplicateCheckTests {
    private static let heartRate = HKQuantityType(.heartRate)
    private static let unit = HKUnit.count().unitDivided(by: .minute())

    private static func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter.date(from: string)!
    }

    private static func xmlRecord(bpm: Int, minute: Int, source: String) -> String {
        let start = String(format: "2024-12-23 10:%02d:00 -0600", minute)
        let end = String(format: "2024-12-23 10:%02d:30 -0600", minute)
        return "<Record type=\"HKQuantityTypeIdentifierHeartRate\" sourceName=\"\(source)\" unit=\"count/min\" creationDate=\"\(end)\" startDate=\"\(start)\" endDate=\"\(end)\" value=\"\(bpm)\"/>"
    }

    /// A sample as it looks in Health after this importer (or an earlier run) wrote it.
    private static func existingSample(bpm: Int, minute: Int, originalSource: String?) -> HKQuantitySample {
        HKQuantitySample(
            type: heartRate,
            quantity: HKQuantity(unit: unit, doubleValue: Double(bpm)),
            start: date(String(format: "2024-12-23 10:%02d:00 -0600", minute)),
            end: date(String(format: "2024-12-23 10:%02d:30 -0600", minute)),
            metadata: originalSource.map { ["HKImportOriginalSourceName": $0] }
        )
    }

    private func parse(_ records: [String], existing: [HKSample]) -> FakeStoreImporter {
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><HealthData locale=\"en_US\">\(records.joined())</HealthData>"
        let importer = FakeStoreImporter()
        importer.healthStore = HKHealthStore()
        importer.authorizedTypes = [Self.heartRate: true]
        importer.existing = existing
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()
        return importer
    }

    private func filter(_ importer: Importer) async -> [HKSample] {
        await withCheckedContinuation { continuation in
            importer.filterExistingSamples(importer.allSamples) { continuation.resume(returning: $0) }
        }
    }

    @Test func nothingExistingKeepsEverything() async throws {
        let importer = parse([Self.xmlRecord(bpm: 60, minute: 0, source: "Watch")], existing: [])
        try #require(importer.allSamples.count == 1)
        let kept = await filter(importer)
        #expect(kept.count == 1)
        #expect(importer.summary.skippedCount(for: .duplicate) == 0)
    }

    @Test func repeatImportIsSkipped() async throws {
        let existing = [Self.existingSample(bpm: 60, minute: 0, originalSource: "Watch")]
        let importer = parse([Self.xmlRecord(bpm: 60, minute: 0, source: "Watch")], existing: existing)
        try #require(importer.allSamples.count == 1)
        let kept = await filter(importer)
        #expect(kept.isEmpty)
        #expect(importer.summary.skippedCount(for: .duplicate) == 1)
    }

    @Test func overlappingImportOnlySkipsTheRecordsAlreadyThere() async throws {
        let existing = [Self.existingSample(bpm: 61, minute: 1, originalSource: "Watch")]
        let importer = parse([
            Self.xmlRecord(bpm: 60, minute: 0, source: "Watch"),
            Self.xmlRecord(bpm: 61, minute: 1, source: "Watch"),
            Self.xmlRecord(bpm: 62, minute: 2, source: "Watch")
        ], existing: existing)
        try #require(importer.allSamples.count == 3)
        let kept = await filter(importer)
        #expect(kept.count == 2)
        #expect(importer.summary.skippedCount(for: .duplicate) == 1)
    }

    @Test func sameTimeAndValueFromADifferentSourceIsKept() async throws {
        let existing = [Self.existingSample(bpm: 60, minute: 0, originalSource: "Phone")]
        let importer = parse([Self.xmlRecord(bpm: 60, minute: 0, source: "Watch")], existing: existing)
        try #require(importer.allSamples.count == 1)
        let kept = await filter(importer)
        #expect(kept.count == 1)
        #expect(importer.summary.skippedCount(for: .duplicate) == 0)
    }

    @Test func sameSourceAndTimeButDifferentValueIsKept() async throws {
        let existing = [Self.existingSample(bpm: 70, minute: 0, originalSource: "Watch")]
        let importer = parse([Self.xmlRecord(bpm: 60, minute: 0, source: "Watch")], existing: existing)
        try #require(importer.allSamples.count == 1)
        let kept = await filter(importer)
        #expect(kept.count == 1)
    }

    @Test func identicalRecordsAreOnlyMatchedAsManyTimesAsTheyExist() async throws {
        let twoIdentical = [Self.xmlRecord(bpm: 60, minute: 0, source: "Watch"), Self.xmlRecord(bpm: 60, minute: 0, source: "Watch")]

        let oneExisting = parse(twoIdentical, existing: [Self.existingSample(bpm: 60, minute: 0, originalSource: "Watch")])
        try #require(oneExisting.allSamples.count == 2)
        #expect(await filter(oneExisting).count == 1)
        #expect(oneExisting.summary.skippedCount(for: .duplicate) == 1)

        let twoExisting = parse(twoIdentical, existing: [
            Self.existingSample(bpm: 60, minute: 0, originalSource: "Watch"),
            Self.existingSample(bpm: 60, minute: 0, originalSource: "Watch")
        ])
        try #require(twoExisting.allSamples.count == 2)
        #expect(await filter(twoExisting).isEmpty)
    }

    @Test func recordWithoutSourceNameIsNeverTreatedAsDuplicate() async throws {
        let existing = [Self.existingSample(bpm: 60, minute: 0, originalSource: "Watch")]
        let importer = parse([Self.xmlRecord(bpm: 60, minute: 0, source: "")], existing: existing)
        try #require(importer.allSamples.count == 1)
        #expect(await filter(importer).count == 1)
    }

    @Test func checkCanBeTurnedOff() async throws {
        let existing = [Self.existingSample(bpm: 60, minute: 0, originalSource: "Watch")]
        let importer = parse([Self.xmlRecord(bpm: 60, minute: 0, source: "Watch")], existing: existing)
        importer.skipExistingSamples = false
        #expect(await filter(importer).count == 1)
    }
}
