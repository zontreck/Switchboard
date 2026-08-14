import 'dart:io';

import 'package:yaml/yaml.dart';

void main() async {
  print("Build information generator - Switchboard Edition");

  String gitBranch = await _runGit(["rev-parse", "--abbrev-ref", "HEAD"]);
  String gitCommitHash = await _runGit(["rev-parse", "HEAD"]);
  String commitShort = gitCommitHash.substring(0, 7);

  File pubspec = File("pubspec.yaml");
  if (!await pubspec.exists()) {
    throw Exception(
      "Pubspec.yaml file not found. This tool MUST be run from the project root.",
    );
  }
  String yamlStr = await pubspec.readAsString();
  dynamic yamlDoc = loadYaml(yamlStr);
  String pubspecVersion = yamlDoc["version"]?.toString() ?? "0.0.0";

  String gitStatus = await _runGit(["status", "--porcelain"]);
  bool dirty = gitStatus.trim().isNotEmpty;

  String buildTimestamp = DateTime.now().toIso8601String();

  String gitTag = "untagged";
  try {
    gitTag = await _runGit([
      "describe",
      "--tags",
      "--always",
      "--dirty",
    ], expectNonZero: false);
  } catch (_) {}

  String template =
      '''
/// AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
/// Generated on $buildTimestamp
/// To regenerate, build and run 'cli/generate_build_inf.dart'

class SBProject {
  static const String BRANCH = '${_escapeSingleQuotes(gitBranch)}';
  static const String COMMIT_SHORT = '${_escapeSingleQuotes(commitShort)}';
  static const String COMMIT = '${_escapeSingleQuotes(gitCommitHash)}';
  static const String PUBSPEC_VERSION = '${_escapeSingleQuotes(pubspecVersion)}';
  static const String BUILD_TIMESTAMP = '${_escapeSingleQuotes(buildTimestamp)}';

  static const bool DIRTY = $dirty;

  static const String TAG = '${_escapeSingleQuotes(gitTag)}';


  static String get versionString =>
      \\\"
Version: \\\$PUBSPEC_VERSION
Commit: \\\$COMMIT
Branch: \\\$BRANCH
Production: \\\$isProduction
\\\";


  static bool get isProduction => BRANCH == 'master' && !DIRTY;

  static Map<String, dynamic> toJson() {
    return {
      "branch": BRANCH,
      "commit": COMMIT,
      "short_commit": COMMIT_SHORT,
      "version": PUBSPEC_VERSION,
      "build_timestamp": BUILD_TIMESTAMP,
    };
  }

  @override
  String toString() {
    return versionString;
  }
}
''';

  await File("lib/dart/sbproj.dart").writeAsString(template);
  print(">> /!\\ Saved SBProject to lib/dart/sbproj.dart /!\\");
}

Future<String> _runGit(List<String> args, {bool expectNonZero = true}) async {
  var res = await Process.run("git", args);
  if ((expectNonZero && res.exitCode == 0) ||
      (!expectNonZero && res.exitCode != 0)) {
    throw Exception("Git command failed: ${res.stderr}");
  }

  return res.stdout.toString().trim();
}

String _escapeSingleQuotes(String input) => input.replaceAll("'", "\\'");
