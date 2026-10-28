# HKImport

## About

Import HealthKit data from a device to simulator or another device. To import your own values, get an export.xml file from a device containing health data and replace the one added to this project in the Data folder:

1. Open Health app
2. Tap your avatar in the top-right corner
3. Tap Export All Health Data
4. Airdrop the exported file to your Mac
5. Replace the export.xml file in the project

Not all HealthKit record types are supported.

### Preview and import report

Turn on "Preview only" in the app to parse the file and check it against what is already in Health without writing anything. After every run (preview or import) the app shows a report: records read, samples written (or that would be written), and every skipped record grouped by reason and HealthKit type.

Samples that already exist in Health with the same type, start, end and value are skipped, so re-running an import does not duplicate them. This check needs read access to the type: if read access was denied, HealthKit returns nothing for it and duplicates cannot be detected. Matching is by those fields only, so it is a best-effort check, not a guarantee.

## Origin

This repository was forked from [HealthKitImporter](https://github.com/Comocomo/HealthKitImporter).
