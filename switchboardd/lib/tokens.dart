import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboardd/users.dart';

class TokenScopeHelper {
  static Duration getDurationForScope(int scope) {
    switch (scope) {
      case TOKEN_SCOPE_LOGIN:
        {
          return Duration(days: 7);
        }
      default:
        {
          return Duration(seconds: 1); // No scope gets immediate expiration
        }
    }
  }
}

class ServerAuthToken {
  String username;
  UUID id;
  int level;
  int scope;
  int flags;

  ServerAuthToken({
    required this.username,
    required this.level,
    required this.id,
    required this.scope,
    required this.flags,
  }) {
    if (level & USER_LEVEL_APP_STORE == USER_LEVEL_APP_STORE ||
        level & USER_LEVEL_TESTER == USER_LEVEL_TESTER) {
      flags |= TOKEN_FLAGS_RESTRICTED; // Ensure that the login session is appropriately restricted at the token level.
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "level": level,
      "type": getTokenType(),
      "id": id.toString(),
      "scope": scope,
      "flags": flags,
    };
  }

  void decode(Map<String, dynamic> js) {
    username = js['username'];
    level = js['level'] as int;
    id = UUID.parse(js['id']);
    scope = js['scope'];
    flags = js['flags'];
  }

  String getTokenType() {
    return "Switchboard Login Token";
  }

  JWT encodeJWT() {
    return JWT(
      toJson(),
      issuer: "https://systemswitchboard.com",
      subject: getTokenType(),
    );
  }

  String signJWT(
    JWT jwt,
    String rsaKey, {
    Duration expiration = const Duration(days: 1),
  }) {
    return jwt.sign(RSAPrivateKey(rsaKey), expiresIn: expiration);
  }

  ServerAuthToken.fromJs(Map<String, dynamic> js)
    : username = "",
      level = 0,
      id = UUID.ZERO,
      scope = 0,
      flags = 0 {
    decode(js);
  }

  /// Performs verification of the authentication token through the same methods that the client would.
  ///
  /// On Success, returns a authentication token, but on failure, returns null.
  static ServerAuthToken? performVerification(
    String authToken,
    RSAPublicKey publicKey,
    Function() onExpired,
  ) {
    try {
      JWT token = JWT.verify(authToken, publicKey);
      Map<String, dynamic> payload = token.payload as Map<String, dynamic>;
      return ServerAuthToken.fromJs(payload);
    } on JWTExpiredException {
      // The token has expired
      onExpired();
      return null;
    } on JWTInvalidException {
      return null;
    }
  }
}

/// No token scope, no privileges.
const int TOKEN_SCOPE_NONE = 0;

/// Token is to be used for account login, and all user-actions that come with it.
const int TOKEN_SCOPE_LOGIN = 1;

/// No flags. This is common for account logins.
const int TOKEN_FLAGS_NONE = 0;

/// A special token flag that should be issued if the user account level includes a restriction like App Store or Tester, which would prevent changing the password.
const int TOKEN_FLAGS_RESTRICTED = 1;
