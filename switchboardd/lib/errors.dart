class ServerErrorCodes {
  /// Cannot create a user without a supplied username
  ///
  /// Code: E0A0A
  static const String error_user_creation_noname = "E0A0A";

  /// User does not exist in the database
  ///
  /// Code: E1A00
  static const String error_no_such_user = "E1A00";

  /// Generic authentication failure
  ///
  /// Code: E1A01
  static const String error_authentication_failed = "E1A01";

  /// Account restriction in effect
  ///
  /// Code: E1A02
  static const String error_account_restricted = "E1A02";

  /// Authentication check failure
  ///
  /// Code: E2A00
  static const String error_auth_check = "E2A00";

  /// Authentication failed to refresh due to invalid token
  ///
  /// Code: E2A01
  static const String error_refresh_failure = "E2A01";

  /// No error code, but generic failure
  ///
  /// Blank reason code only is error when there is a success failure.
  /// No Code
  static const String error_generic = "";
}
