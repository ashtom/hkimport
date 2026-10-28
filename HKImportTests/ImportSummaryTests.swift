//
//  ImportSummaryTests.swift
//  HKImportTests
//

import Testing
@testable import HKImport
import Foundation

struct ImportSummaryTests {
    @Test func skipCountsGroupByReasonAndType() {
        var s = ImportSummary()
        s.skip(.durationTooLong, type: "A")
        s.skip(.durationTooLong, type: "A")
        s.skip(.durationTooLong, type: "B")
        s.skip(.duplicate, type: "")
        #expect(s.skippedCount(for: .durationTooLong) == 3)
        #expect(s.skippedCount(for: .duplicate) == 1)
        #expect(s.totalSkipped == 4)
        #expect(s.skipped[.duplicate]?["(unknown)"] == 1)
    }

    @Test func reportListsReasonsAndTopTypes() {
        var s = ImportSummary()
        s.recordsRead = 10
        s.samplesPrepared = 7
        s.samplesSaved = 7
        for _ in 0..<2 { s.skip(.unsupportedType, type: "X") }
        s.skip(.unsupportedType, type: "Y")
        let report = s.report(topTypesPerReason: 1)
        #expect(report.contains("Import finished."))
        #expect(report.contains("Written: 7 of 7"))
        #expect(report.contains("Skipped: 3"))
        #expect(report.contains("X: 2"))
        #expect(!report.contains("Y: 1"))
        #expect(report.contains("... and 1 more types"))
    }

    @Test func dryRunReportSaysNothingWritten() {
        var s = ImportSummary()
        s.dryRun = true
        s.samplesPrepared = 5
        let report = s.report()
        #expect(report.contains("Preview only. Nothing was written to Health."))
        #expect(report.contains("Would write: 5"))
    }
}

struct SampleKeyTests {
    let t0 = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func sameInputsMatch() {
        let a = SampleKey(type: "T", source: "S", start: t0, end: t0 + 60, value: 72.00001)
        let b = SampleKey(type: "T", source: "S", start: t0, end: t0 + 60, value: 72.00002)
        #expect(a == b)
    }

    @Test func differentValueTypeOrDatesDoNotMatch() {
        let a = SampleKey(type: "T", source: "S", start: t0, end: t0 + 60, value: 72)
        #expect(a != SampleKey(type: "T", source: "S", start: t0, end: t0 + 60, value: 73))
        #expect(a != SampleKey(type: "U", source: "S", start: t0, end: t0 + 60, value: 72))
        #expect(a != SampleKey(type: "T", source: "S", start: t0 + 1, end: t0 + 60, value: 72))
        #expect(a != SampleKey(type: "T", source: "S", start: t0, end: t0 + 61, value: 72))
    }

    @Test func differentSourceDoesNotMatch() {
        let a = SampleKey(type: "T", source: "Watch", start: t0, end: t0 + 60, value: 72)
        #expect(a != SampleKey(type: "T", source: "Phone", start: t0, end: t0 + 60, value: 72))
        #expect(a == SampleKey(type: "T", source: "Watch", start: t0, end: t0 + 60, value: 72))
    }

    @Test func nonFiniteValuesNeverMatchFiniteOnes() {
        let nan = SampleKey(type: "T", source: "S", start: t0, end: t0, value: .nan)
        #expect(nan != SampleKey(type: "T", source: "S", start: t0, end: t0, value: 0))
        _ = SampleKey(type: "T", source: "S", start: t0, end: t0, value: .infinity)
        _ = SampleKey(type: "T", source: "S", start: t0, end: t0, value: 1e300)
    }
}

struct ImporterSkipReportingTests {
    private func run(_ body: String) -> Importer {
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><HealthData locale=\"en_US\">\(body)</HealthData>"
        let importer = Importer()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = importer
        parser.parse()
        return importer
    }

    @Test func recordMissingRequiredAttributesIsSkippedInsteadOfCrashing() {
        let importer = run("<Record type=\"HKQuantityTypeIdentifierHeartRate\" value=\"60\" unit=\"count/min\"/>")
        #expect(importer.allSamples.isEmpty)
        #expect(importer.summary.recordsRead == 1)
        #expect(importer.summary.skippedCount(for: .malformedRecord) == 1)
    }

    @Test func overlongRecordIsCountedWithReason() {
        let importer = run("<Record type=\"HKQuantityTypeIdentifierHeartRate\" unit=\"count/min\" value=\"60\" startDate=\"2024-01-01 00:00:00 +0000\" endDate=\"2024-01-10 00:00:00 +0000\" creationDate=\"2024-01-10 00:00:00 +0000\"/>")
        #expect(importer.allSamples.isEmpty)
        #expect(importer.summary.skippedCount(for: .durationTooLong) == 1)
    }

    @Test func unrecognizedTypeIsCountedAsUnsupported() {
        let importer = run("<Record type=\"HKQuantityTypeIdentifierNotARealType\" unit=\"count\" value=\"1\" startDate=\"2024-01-01 00:00:00 +0000\" endDate=\"2024-01-01 00:00:01 +0000\" creationDate=\"2024-01-01 00:00:01 +0000\"/>")
        #expect(importer.summary.skippedCount(for: .unsupportedType) == 1)
    }
}
