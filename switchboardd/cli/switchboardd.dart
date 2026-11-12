import 'dart:convert';
import 'dart:io';

import 'package:switchboardd/dart/sbproj.dart';

Future<void> main(List<String> arguments) async {
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
  print("> This server will run indefinitely until terminated manually <");
  print(
    "/!\\ To terminate, use CTRL+C, or, if using docker, kill the container. /!\\\n\n",
  );

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 80);

  print("> Now listening on port 80");

  await for (final request in server) {
    String requestPath = request.uri.path;
    String requestIP =
        request.connectionInfo?.remoteAddress.address ??
        "0.0.0.0"; // placeholder for a unknown origin IP
    Map<String, List<String>> headers = {};

    request.headers.forEach((key, values) {
      headers[key] = values;
    });

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

      default:
        {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.text
            ..write("Invalid Request");
          break;
        }
    }
  }
}
