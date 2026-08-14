@echo off

title Switchboard Builder
color 1f

call flutter pub get
call flutter doctor
mkdir outputs
call dart compile exe -o outputs\sbgen.exe cli/generate_build_inf.dart
outputs\sbgen.exe

call flutter build windows
call flutter build apk