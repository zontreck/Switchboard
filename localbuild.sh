#!/bin/bash

flutter clean
flutter pub get

flutter doctor
flutter doctor --android-licenses


rm -rf outputs
mkdir -pv outputs

dart compile exe -o outputs/server-x86_64-linux bin/server.dart
flutter build linux
flutter build windows || true
flutter build macos || true
flutter build ios || true
flutter build web
flutter build apk
flutter build aab



cd build/web
tar -cvf ../../outputs/web.tgz .

cd ../linux/x64/release/bundle
tar -cvf ../../../../../outputs/linux.tgz

cd ../../../../../
cp build/app/outputs/bundle/release/app-release.aab outputs/switchboard.aab
cp build/app/outputs/flutter-apk/app-release.apk outputs/switchboard.apk