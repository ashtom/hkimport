#!/usr/bin/env bash

# use macosx as everyone should have it by default
SDK_PATH=$(xcrun --sdk macosx --show-sdk-path)
HEADER_PATH="$SDK_PATH/System/Library/Frameworks/HealthKit.framework/Versions/Current/Headers/HKWorkout.h"

if [ ! -f "$HEADER_PATH" ]; then
    echo "HealthKit header file not found at $HEADER_PATH"
    exit 1
fi

grep -E "HKWorkoutActivityType[A-Za-z]+" "$HEADER_PATH" | \
    awk '{print $1}' | \
    sed -E 's/,?$//' | \
    sed 's/HKWorkoutActivityType//g' | \
    while read -r caseName; do
        l=$(echo "$caseName" | sed -E 's/^(.)/\L\1/')
        echo "case .$l: return \"$caseName\""
    done
