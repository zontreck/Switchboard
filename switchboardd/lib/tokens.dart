import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class ServerAuthToken {
  String username;
  int level;

  ServerAuthToken({required this.username, required this.level});

  Map<String, dynamic> toJson() {
    return {"username": username, "level": level, "type": getTokenType()};
  }

  void decode(Map<String, dynamic> js) {
    username = js['username'];
    level = js['level'] as int;
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

  String signJWT(JWT jwt, String rsaKey) {
    return jwt.sign(RSAPrivateKey(rsaKey), expiresIn: Duration(days: 1));
  }

  ServerAuthToken.fromJs(Map<String, dynamic> js) : username = "", level = 0 {
    username = js['username'];
    level = js['level'];
  }

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
    } on JWTInvalidException catch (EX) {
      return null;
    }
  }
}
