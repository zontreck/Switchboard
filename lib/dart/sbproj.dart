/// AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
/// Generated on 2026-09-09T13:59:29.342357
/// To regenerate, build and run 'cli/generate_build_inf.dart'

class SBProject {
  static const String BRANCH = 'develop';
  static const String COMMIT_SHORT = '61db767';
  static const String COMMIT = '61db76713966bdf400434d47a894d8346aca69d1';
  static const String PUBSPEC_VERSION = '0.4.0+0909261357';
  static const String BUILD_TIMESTAMP = '2026-09-09T13:59:29.342357';

  /// Indicates whether the project is being run from a development/modified codebase.
  ///
  /// This is so we can display a warning/disclaimer to the user that the app was built from modified code, and may not be an official build.
  static const bool DIRTY = true;

  static const String TAG = 'untagged';


  static String get versionString =>
      '''
Version: $PUBSPEC_VERSION
Commit: $COMMIT
Branch: $BRANCH
Production: $isProduction
''';


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
