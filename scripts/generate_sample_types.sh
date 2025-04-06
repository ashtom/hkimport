#!/usr/bin/env bash

# use macosx as everyone should have it by default
SDK_PATH=$(xcrun --sdk macosx --show-sdk-path)
HEADER_PATH="$SDK_PATH/System/Library/Frameworks/HealthKit.framework/Versions/Current/Headers/HKTypeIdentifiers.h"

# NOTE: there is not an easy way to get this so it's hard coded
BUILD_TARGET_IOS_VERSION=12.0

if [ ! -f "$HEADER_PATH" ]; then
    echo "HealthKit header file not found at $HEADER_PATH"
    exit 1
fi

ios_avail_regex="API_AVAILABLE\(ios\(([0-9]+\.[0-9]+)\)"

ignore_identifiers=(
    # forbidden to write by apple
    "HKCategoryTypeIdentifierHeadphoneAudioExposureEvent"
    "HKQuantityTypeIdentifierAppleExerciseTime"
    "HKQuantityTypeIdentifierAtrialFibrillationBurden"
    "HKCategoryTypeIdentifierAppleWalkingSteadinessEvent"
    "HKCategoryTypeIdentifierIrregularHeartRhythmEvent"
    "HKQuantityTypeIdentifierAppleMoveTime"
    "HKQuantityTypeIdentifierWalkingHeartRateAverage"
    "HKCategoryTypeIdentifierHighHeartRateEvent"
    "HKCategoryTypeIdentifierLowHeartRateEvent"
    "HKQuantityTypeIdentifierNikeFuel"
    "HKCategoryTypeIdentifierSleepApneaEvent"
    "HKCategoryTypeIdentifierPersistentIntermenstrualBleeding"
    "HKCategoryTypeIdentifierLowCardioFitnessEvent"
    "HKQuantityTypeIdentifierAppleStandTime"
    "HKQuantityTypeIdentifierAppleWalkingSteadiness"
    "HKQuantityTypeIdentifierAppleSleepingWristTemperature"
    "HKCategoryTypeIdentifierAudioExposureEvent"
    "HKCategoryTypeIdentifierAppleStandHour"
    "HKQuantityTypeIdentifierWalkingAsymmetryPercentage"
    "HKCategoryTypeIdentifierProlongedMenstrualPeriods"
    "HKCategoryTypeIdentifierIrregularMenstrualCycles"
    "HKCategoryTypeIdentifierInfrequentMenstrualCycles"
    "HKQuantityTypeIdentifierAppleSleepingBreathingDisturbances"
    "HKCategoryTypeIdentifierEnvironmentalAudioExposureEvent"
    "HKCategoryTypeIdentifierAudioExposureEvent"
)

grep -E "HKQuantityTypeIdentifier[A-Za-z0-9]+" "$HEADER_PATH" | grep -v "API_DEPRECATED" | \
    while read -r line; do
        identifier=$(echo "$line" | grep -oE "HKQuantityTypeIdentifier[A-Za-z0-9]+")
        if [[ "${ignore_identifiers[*]}" =~ $identifier ]]; then
            continue
        fi
        if [[ $line =~ $ios_avail_regex ]]; then
            ios_version="${BASH_REMATCH[1]}"
            if (( $(echo "$ios_version > $BUILD_TARGET_IOS_VERSION" | bc -l) )); then
                echo "if #available(iOS $ios_version, *) {"
            fi
        fi

        echo "base.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: \"$identifier\"))!)"
        if [[ $line =~ $ios_avail_regex ]]; then
            ios_version="${BASH_REMATCH[1]}"
            if (( $(echo "$ios_version > $BUILD_TARGET_IOS_VERSION" | bc -l) )); then
                echo "}"
            fi
        fi
    done

grep -E "HKCategoryTypeIdentifier[A-Za-z0-9]+" "$HEADER_PATH" | grep -v "API_DEPRECATED" | \
    while read -r line; do
        identifier=$(echo "$line" | grep -oE "HKCategoryTypeIdentifier[A-Za-z0-9]+")
        if [[ "${ignore_identifiers[*]}" =~ $identifier ]]; then
            continue
        fi
        if [[ $line =~ $ios_avail_regex ]]; then
            ios_version="${BASH_REMATCH[1]}"
            if (( $(echo "$ios_version > $BUILD_TARGET_IOS_VERSION" | bc -l) )); then
                echo "if #available(iOS $ios_version, *) {"
            fi
        fi

        echo "base.insert(HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: \"$identifier\"))!)"
        if [[ $line =~ $ios_avail_regex ]]; then
            ios_version="${BASH_REMATCH[1]}"
            if (( $(echo "$ios_version > $BUILD_TARGET_IOS_VERSION" | bc -l) )); then
                echo "}"
            fi
        fi
    done
