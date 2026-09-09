/// AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
/// Generated on 2026-09-09T13:51:36.126609
/// To regenerate, build and run 'cli/generate_build_inf.dart'

class SBProject {
  static const String BRANCH = 'develop';
  static const String COMMIT_SHORT = 'e8cae29';
  static const String COMMIT = 'e8cae290e0c85ada40363b3172abc36e6d4bb7d5';
  static const String PUBSPEC_VERSION = '0.4.0+0909260017';
  static const String BUILD_TIMESTAMP = '2026-09-09T13:51:36.126609';

  static const bool DIRTY = false;

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
