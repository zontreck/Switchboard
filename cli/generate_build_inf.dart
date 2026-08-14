import 'dart:io';

void main() async {
  String gitBranch = await _runGit(["rev-parse", "--abbrev-ref", "HEAD"]);
  String gitCommitHash = await _runGit(["rev-parse", "HEAD"]);

  String buildTimestamp = DateTime.now().toIso8601String();

  String template =
      '''
/// AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
/// Generated on $buildTimestamp
/// To regenerate, build and run 'cli/generate_build_inf.dart'

class SBProject {
}
''';

  await File("lib/dart/sbproj.dart").writeAsString(template);
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
