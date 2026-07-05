#!/bin/bash

rel="$RELEASE"

flutter clean
flutter pub get

flutter doctor
flutter doctor --android-licenses


rm -rf outputs
mkdir -pv outputs

dart compile exe -o outputs/proxybot-x86_64-linux bin/bot.dart
dart compile exe -o outputs/dlocto bin/backupOctocon.dart
flutter build linux || true
flutter build windows || true
flutter build macos || true
flutter build ios || true
flutter build web
flutter build apk
if [ "$rel" = "1" ]
then
	flutter build aab --release --obfuscate --split-debug-info=build/app/outputs/symbols
fi



cd build/web
tar -cvf ../../outputs/web.tgz .

cd ../linux/x64/release/bundle
tar -cvf ../../../../../outputs/linux.tgz .

cd ../../../../../

rm -rf build/web
flutter build web -t lib/web.dart
cd build/web
tar -cvf ../../outputs/website.tgz .
cd ../../

rm -rf build/linux
flutter build linux -t lib/web.dart
cd build/linux/x64/release/bundle
tar -cvf ../../../../../outputs/website-linux.tgz .
cd ../../../../..

if [ "$rel" = "1" ]
then
	cp build/app/outputs/bundle/release/app-release.aab outputs/switchboard.aab
fi

cp build/app/outputs/flutter-apk/app-release.apk outputs/switchboard.apk