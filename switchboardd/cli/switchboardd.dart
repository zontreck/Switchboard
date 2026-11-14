import 'dart:convert';
import 'dart:io';

import 'package:libac_dart/argparse/Builder.dart';
import 'package:libac_dart/argparse/CLIHelper.dart';
import 'package:libac_dart/argparse/Parser.dart';
import 'package:libac_dart/argparse/types/Bool.dart';
import 'package:libac_dart/argparse/types/String.dart';
import 'package:libac_dart/encryption/jwt.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:mysql_dart/mysql_dart.dart';
import 'package:switchboardd/dart/sbproj.dart';
import 'package:switchboardd/payloads.dart';

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
  final conn = MySQLConnection.createConnection(
    host: dbhost,
    port: 3306,
    userName: dbuser,
    password: dbpass,
    databaseName: dbname,
  );

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
    Map<String, List<String>> headers = {};
    print("> [${requestIP}] ${requestMethod}: ${requestPath}");

    request.headers.forEach((key, values) {
      headers[key] = values;
    });
    String rayID = UUID.generate(4).toString();

    final body = await utf8.decoder.bind(request).join();

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
