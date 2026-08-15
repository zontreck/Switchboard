/// This file is auto-generated at build time.
///
/// DO NOT EDIT MANUALLY!
///
/// What you see is a template file to allow for the app to correctly build, even without generating this file.
class SBProject {
  static const String BRANCH = "develop";
  static const String COMMIT_SHORT = "<GIT_COMMIT_SHORT>";
  static const String COMMIT = "<GIT_COMMIT>";
  static const String PUBSPEC_VERSION = "<PUBSPEC_VERSION>";
  static const String BUILD_TIMESTAMP = "<BUILD_TIMESTAMP>";

  /// Indicates whether the project is being run from a development/modified codebase.
  ///
  /// This is so we can display a warning/disclaimer to the user that the app was built from modified code, and may not be an official build.
  static const bool DIRTY = false;

  static const String TAG = "<GIT_TAG>";

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
