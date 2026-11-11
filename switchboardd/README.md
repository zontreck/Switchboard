# Switchboard Server

This package contains the server code for Switchboard. As such, some functions may not be appropriate to call from the client mobile app.

# Building

This project was converted from php to dart, and building it is very simple.

Firstly, start your terminal session in the root project, Switchboard, and run the following commands to build this project.

```bash

flutter pub get
dart compile exe -o sbgen cli/generate_build_inf.dart
./sbgen

cp lib/dart/sbproj.dart switchboardd/lib/dart/sbproj.dart

cd switchboardd

dart pub get
dart compile exe -o switchboardd bin/exe.dart
```
