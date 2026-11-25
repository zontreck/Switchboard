import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';

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
  });

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
  ) {
    try {
      JWT token = JWT.verify(authToken, publicKey);
      Map<String, dynamic> payload = token.payload as Map<String, dynamic>;
      return ServerAuthToken.fromJs(payload);
    } on JWTExpiredException {
      // The token has expired
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
