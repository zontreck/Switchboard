import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:libac_dart/argparse/Builder.dart';
import 'package:libac_dart/argparse/CLIHelper.dart';
import 'package:libac_dart/argparse/Parser.dart';
import 'package:libac_dart/argparse/types/Bool.dart';
import 'package:libac_dart/argparse/types/String.dart';
import 'package:libac_dart/encryption/jwt.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:mysql_dart/mysql_dart.dart';
import 'package:switchboardd/audit.dart';
import 'package:switchboardd/dart/sbproj.dart';
import 'package:switchboardd/funcs.dart';
import 'package:switchboardd/migrations.dart';
import 'package:switchboardd/network.dart';
import 'package:switchboardd/payloads.dart';
import 'package:switchboardd/tokens.dart';

Future<void> main(List<String> arguments) async {
  final args = ArgumentParser.parse(arguments);

  final defaults = ArgumentsBuilder.builder()
      .withArgument(StringArgument(name: "dbhost", rawValue: "127.0.0.1"))
      .withArgument(StringArgument(name: "dbuser", rawValue: "user"))
      .withArgument(StringArgument(name: "dbpass", rawValue: "password"))
      .withArgument(StringArgument(name: "dbname", rawValue: "switchboard"))
      .withArgument(BoolArgument(name: "help", rawValue: "false"))
      .build();

  if (args.hasArg("help") || args.count < 4) {
    final hlp = ArgumentHelpers.generateHelpMessage(
      defaults.getArgumentsList(),
      "switchboardd",
    );
    print(hlp);
    exit(0);
  }

  String dbhost = args.getArg("dbhost")?.getValue() ?? "127.0.0.1";
  String dbuser = args.getArg("dbuser")?.getValue() ?? "user";
  String dbpass = args.getArg("dbpass")?.getValue() ?? "changeMe123";
  String dbname = args.getArg("dbname")?.getValue() ?? "switchboard";

  print(
    "  ██████  █     █░ ██▓▄▄▄█████▓ ▄████▄   ██░ ██  ▄▄▄▄    ▒█████   ▄▄▄       ██▀███  ▓█████▄ ",
  );
  print(
    "▒██    ▒ ▓█░ █ ░█░▓██▒▓  ██▒ ▓▒▒██▀ ▀█  ▓██░ ██▒▓█████▄ ▒██▒  ██▒▒████▄    ▓██ ▒ ██▒▒██▀ ██▌",
  );
  print(
    "░ ▓██▄   ▒█░ █ ░█ ▒██▒▒ ▓██░ ▒░▒▓█    ▄ ▒██▀▀██░▒██▒ ▄██▒██░  ██▒▒██  ▀█▄  ▓██ ░▄█ ▒░██   █▌",
  );
  print(
    "  ▒   ██▒░█░ █ ░█ ░██░░ ▓██▓ ░ ▒▓▓▄ ▄██▒░▓█ ░██ ▒██░█▀  ▒██   ██░░██▄▄▄▄██ ▒██▀▀█▄  ░▓█▄   ▌",
  );
  print(
    "▒██████▒▒░░██▒██▓ ░██░  ▒██▒ ░ ▒ ▓███▀ ░░▓█▒░██▓░▓█  ▀█▓░ ████▓▒░ ▓█   ▓██▒░██▓ ▒██▒░▒████▓ ",
  );
  print(
    "▒ ▒▓▒ ▒ ░░ ▓░▒ ▒  ░▓    ▒ ░░   ░ ░▒ ▒  ░ ▒ ░░▒░▒░▒▓███▀▒░ ▒░▒░▒░  ▒▒   ▓▒█░░ ▒▓ ░▒▓░ ▒▒▓  ▒ ",
  );
  print(
    "░ ░▒  ░ ░  ▒ ░ ░   ▒ ░    ░      ░  ▒    ▒ ░▒░ ░▒░▒   ░   ░ ▒ ▒░   ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ▒  ▒ ",
  );
  print(
    "░  ░  ░    ░   ░   ▒ ░  ░      ░         ░  ░░ ░ ░    ░ ░ ░ ░ ▒    ░   ▒     ░░   ░  ░ ░  ░ ",
  );
  print(
    "      ░      ░     ░           ░ ░       ░  ░  ░ ░          ░ ░        ░  ░   ░        ░    ",
  );
  print(
    "                               ░                      ░                              ░      ",
  );

  print("\n\n");

  print("Switchboard Backend Server vAPI::${SBProject.BACKEND_VERSION}");
  print("> Processing safety checks...");
  Directory keyDir = Directory("keys");
  if (await keyDir.exists()) {
    print("[OK]  Keys Directory Exists");
  } else {
    print("[OK]  Creating Keys Directory...");
    await keyDir.create();
  }

  File privKey = File("keys/private.pem");
  String publicKey = "";
  String privateKey = "";
  if (await privKey.exists()) {
    print("[OK]  Located keypair");
  } else {
    print("[OK]  Keypair not found, generating new pair");
    final keys = EncryptionKeys.NewRSAKeys();
    print("[OK]  Keys Generated... Saving...");
    await EncryptionKeys.saveKeyPair(
      keys,
      "keys/public.pem",
      "keys/private.pem",
    );
    print("[OK]  Keys Saved");
  }
  publicKey = await File("keys/public.pem").readAsString();
  privateKey = await File("keys/private.pem").readAsString();
  print("[OK]  Loaded Key Pair from Disk");

  print("> Attempting to establish connection to database...");
  final conn = MySQLConnectionPool(
    host: dbhost,
    port: 3306,
    userName: dbuser,
    password: dbpass,
    databaseName: dbname,
    maxConnections: 999,
    verifyServerCertificate: false,
  );
  print("[OK]  Database connection established");

  print("> Executing database migrator if needed...");
  await Migrator.performMigrations(conn);
  print("[OK]  Migrator loaded");

  print("> Initializing Auditor...");
  Auditor auditLogger = Auditor(pool: conn);
  print("[OK]  Auditor has been initialized");

  print("> This server will run indefinitely until terminated manually <");
  print(
    "/!\\ To terminate, use CTRL+C, or, if using docker, kill the container. /!\\\n\n",
  );

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 80);

  print("> Now listening on port 80");

  await for (final request in server) {
    String requestPath = request.uri.path;
    String requestMethod = request.method;

    String requestIP =
        request.connectionInfo?.remoteAddress.address ??
        "0.0.0.0"; // placeholder for a unknown origin IP
    var proxyIP = request.headers.value("X-Forwarded-For");
    if (proxyIP != null) {
      requestIP = proxyIP;
    }

    Map<String, List<String>> headers = {};
    print("> [$requestIP] $requestMethod: $requestPath");

    request.headers.forEach((key, values) {
      headers[key] = values;
    });
    UUID rayID = UUID.v4();

    final body = await utf8.decoder.bind(request).join();
    Map<String, dynamic> bodyJs = {};
    try {
      bodyJs = json.decode(body);
    } catch (e) {
      // Ignore error, this just means there was either no body, or the body was not in json.
    }

    await auditLogger.log(
      rayID,
      requestPath,
      requestMethod,
      json.encode(headers),
      body,
    );

    String authorizationToken = "";
    ServerAuthToken? authorization;
    if (headers.containsKey("Authorization")) {
      authorizationToken = headers["Authorization"]?.first ?? "";
      List<String> atParts = authorizationToken.split(' ');
      if (atParts[0] == "Bearer") {
        authorizationToken = atParts[1];
      } else {
        authorizationToken = atParts[0];
      }
      authorization = ServerAuthToken.performVerification(
        authorizationToken,
        RSAPublicKey(publicKey),
      );
    }

    switch (requestPath) {
      case "/robots.txt":
        {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.text
            ..write("User-Agent: *\nDisallow: /");
          break;
        }
      case "/sync/key":
        {
          // Send the public key as a response
          ServerPublicKeyResponse spkr = ServerPublicKeyResponse(
            Success: true,
            Path: requestPath,
            Method: requestMethod,
            ID: rayID,
            Reason: "",
            pemData: publicKey,
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(json.encode(spkr.encode()));
          break;
        }
      case "/sync/policy":
        {
          ServerPolicyResponse spr = ServerPolicyResponse(
            termsOfService: SBProject.BACKEND_TOS,
            privacyPolicy: SBProject.BACKEND_PRIVACY,
            policiesEnabled: SBProject.BACKEND_POLICIES_ENABLED,
            Success: true,
            Path: requestPath,
            Method: requestMethod,
            ID: rayID,
            Reason: "",
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(json.encode(spr.encode()));
          break;
        }
      case "/version":
        {
          ServerVersionResponse svr = ServerVersionResponse(
            product: "Switchboard API Server (switchboardd)",
            version: SBProject.PUBSPEC_VERSION,
            backendVersion: SBProject.BACKEND_VERSION,
            Success: true,
            Path: requestPath,
            Method: requestMethod,
            ID: rayID,
            Reason: "",
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(json.encode(svr.encode()));
          break;
        }
      case var path when path.startsWith("/user/"):
        {
          String username = "";
          List<String> pathParts = path.split('/');
          if (pathParts.length == 1) {
            // Username being absent, check the Authorization header.
            username = authorization!.username;
          } else {
            username = pathParts[1];
          }

          switch (requestMethod) {
            case "PUT":
              {
                if (username.isEmpty) {
                  request.response
                    ..statusCode = HttpStatus.ok
                    ..headers.contentType = ContentType.json
                    ..write(
                      json.encode(
                        (BasicResponse(
                          ID: rayID,
                          Success: false,
                          Path: requestPath,
                          Method: requestMethod,
                          Reason: "E0A0A",
                        )),
                      ),
                    );
                } else {
                  // We're creating the user
                  String hashedPassword = bodyJs['auth'];

                  String pwdSalt = ServerSecurityHelpers.makePasswordSalt();
                  String pwdHash = ServerSecurityHelpers.makePasswordHash(
                    hashedPassword,
                    pwdSalt,
                  );

                  UUID userID = UUID.v4();
                  UUID rootFolderID = UUID.v4();

                  await insertNewUser(conn, username, userID, pwdHash, pwdSalt);
                  await sanityCheckUserFields(conn, userID);
                  await createNewFolder(
                    conn,
                    userID,
                    rootFolderID,
                    "root",
                    null,
                    TimeUtils.getUnixTimestamp(),
                    TimeUtils.getUnixTimestamp(),
                  );

                  final userFields = await getAllUserFields(conn, userID);

                  int userLevel = await getUserAccountLevel(conn, userID);

                  ServerUserResponse SUR = ServerUserResponse(
                    user: username,
                    displayName: username,
                    alterCount: 0,
                    accountLevel: userLevel,
                    id: userID,
                    rootFolder: rootFolderID,
                    fields: userFields,
                    Success: true,
                    Path: requestPath,
                    Method: requestMethod,
                    ID: rayID,
                    Reason: "",
                  );

                  request.response
                    ..statusCode = HttpStatus.ok
                    ..headers.contentType = ContentType.json
                    ..write(SUR.encode());
                }
                if (await usernameExists(conn, username)) {}
                break;
              }
          }
          break;
        }
      case "/auth/login":
        {
          String username = bodyJs['username'];
          String hashedPwd = bodyJs['auth'];

          ServerUser? user = await getServerUserByName(conn, username);
          if (user == null) {
            // user does not exist
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.json
              ..write(
                json.encode(
                  BasicResponse(
                    Success: false,
                    Path: requestPath,
                    Method: requestMethod,
                    ID: rayID,
                    Reason: "E1A00",
                  ).encode(),
                ),
              );
          } else {
            bool login = user.authenticate(hashedPwd);
            if (login) {
              // Generate a authentication token
              ServerAuthToken nAuthToken = ServerAuthToken(
                username: username,
                level: user.accountLevel,
                id: user.userID,
                scope: TOKEN_SCOPE_LOGIN,
                flags: TOKEN_FLAGS_NONE,
              );
              String jWebToken = nAuthToken.signJWT(
                nAuthToken.encodeJWT(),
                privateKey,
                expiration: Duration(days: 7),
              );

              ServerAuthenticationResponse sar = ServerAuthenticationResponse(
                username: username,
                token: jWebToken,
                Success: true,
                Path: requestPath,
                Method: requestMethod,
                ID: rayID,
                Reason: "",
              );

              // Add the access token to the database.
              // This is a layer of redundancy, as we can check the database for the token.

              request.response
                ..statusCode = HttpStatus.ok
                ..headers.add("Authentication", jWebToken)
                ..headers.contentType = ContentType.json
                ..write(json.encode(sar.encode()));
            } else {
              request.response
                ..statusCode = HttpStatus.ok
                ..headers.contentType = ContentType.json
                ..write(
                  json.encode(
                    BasicResponse(
                      Success: false,
                      Path: requestPath,
                      Method: requestMethod,
                      ID: rayID,
                      Reason: "E1A01",
                    ).encode(),
                  ),
                );
            }
          }
          break;
        }

      default:
        {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.text
            ..write("Invalid Request");
          break;
        }
    }

    await request.response.flush();
    await request.response.close();
  }
}
