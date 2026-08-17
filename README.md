# Switchboard

A proxy app and bot designed for plurals, DID, OSDD, or simply for roleplay!

# Build

To build this code, you need a Dart toolchain installed. The easiest way to generate the outputs is to use the script inside the tools folder.

**NOTE** The tool script at path: `tools/build.sh` or `tools\\build.bat` will utilize Docker to build the output binaries.

# Versioning

We use `Major.Minor.Patch` as our version scheme. There is an extra versioncode attached to every build or commit though. This is read as: `Major.Minor.Patch+DateTime`

# Server

The server as of 0.4.0+0816261451 now requires Composer. This change was made to give us access to libraries that can simplify the entire process.

## Get Started

First, deploy the server content to a webroot. Then you need to have Composer installed.

Run the command:

```bash
composer install --no-dev --optimize-autoloader
```

## WARNING:

**DO NOT UPDATE** any composer dependencies. It might ask you to do so. Ignore that. We will update dependencies at our own pace, testing them thoroughly to ensure nothing breaks.
