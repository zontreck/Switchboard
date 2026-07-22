#!/bin/bash

# This script invokes a build
cd /app/project
rsync -a --progress -h /app/source/ ./

flutter clean
flutter doctor
flutter doctor --android-licenses

flutter build web
cd build/web
tar -cvf ../../outputs/web.tgz .
cd ../..

flutter build linux
cd build/linux/x64/release/bundle
tar -cvf ../../../../../outputs/linux.tgz .
cd ../../../../../

flutter build apk
cd build/app/outputs/flutter-apk
cp app-release.apk ../../../../outputs/switchboard.apk
cd ../../../../