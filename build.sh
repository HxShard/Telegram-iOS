#!/bin/bash

python3 build-system/Make/Make.py \
    --cacheDir="$HOME/telegram-bazel-cache" \
    build \
    --configurationPath=build-system/appstore-configuration.json \
    --codesigningInformationPath=build-system/fake-codesigning \
    --buildNumber=29028 \
    --configuration=release_arm64