import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libac_dart/nbt/NbtIo.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/nbt/impl/StringTag.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/storage.dart';

main() {
  test("Test version endpoint", () async {
    S2CServerVersionPacket verReply = await NetworkInterface.getServerVersion();

    print("[/version]: ${verReply.encode()}");
    expect(verReply.data.product, "Switchboard API Server (PHP)");

    print("[/version] : PASS");
  });

  test("Test make user", () async {
    var testSum = Hashing.md5Hash("test");
    expect(testSum, "098f6bcd4621d373cade4e832627b4f6");

    // Create a user named 1234apitest
    // APITest user MUST have a user account level of 3, that way we can delete it later. When a user allows account deletion, their account level will get increased.
    // 1 - Standard Account
    // 2 - Allow Deletion
    // Effectively, the level also acts as Flags for the account.

    Dio dio = Dio();
    dio.options.contentType = "application/json";

    var reply = await dio.put(
      "https://api.systemswitchboard.com/user/1234apitest",
      data: {"auth": testSum},
    );
    print("[/user/1234apitest]: ${json.encode(reply.data)}");

    // Check result flag
    expect(reply.data['success'], true);
    expect(reply.data['reason'], "User created");

    // We've passed the test.
    print("[/user/1234apitest] (PUT): PASS");
  });

  test("Get test user", () async {
    Dio dio = Dio();
    var reply = await dio.get(
      "https://api.systemswitchboard.com/user/1234apitest",
    );
    print("[/user/1234apitest]: ${json.encode(reply.data)}");

    expect(reply.data['success'], true);
    expect(reply.data['data']['user'], "1234apitest");

    print("[/user/1234apitest] (GET): PASS");
  });

  test("Test auth endpoints", () async {
    Dio dio = Dio();
    CompoundTag ctTest;
    if (File("test.nbt").existsSync()) {
      ctTest = (await NbtIo.read("test.nbt")).asCompoundTag();
    } else {
      ctTest = CompoundTag();
    }

    dio.options.contentType = "application/json";

    var reply = await dio.post(
      "https://api.systemswitchboard.com/auth/login",
      data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
    );
    print("[/auth/login]: ${json.encode(reply.data)}");
    expect(reply.data['success'], true);
    print("[/auth/login]: PASS");

    String token = reply.data['data']['token'];

    dio.options.headers["X-SB-Auth"] = token;

    reply = await dio.get("https://api.systemswitchboard.com/auth/check");
    print("[/auth/check]: ${reply.data}");
    expect(reply.data['success'], true);

    print("[/auth/check]: PASS");

    reply = await dio.get("https://api.systemswitchboard.com/auth/refresh");
    print("[/auth/refresh]: ${reply.data}");
    expect(reply.data['success'], true);

    print("[/auth/refresh]: PASS");
    ctTest.put("loginToken", StringTag.valueOf(reply.data["data"]["token"]));

    await NbtIo.write("test.nbt", ctTest);
  });

  test("Test image endpoints", () async {
    Dio dio = Dio();
    CompoundTag ctTest;
    if (File("test.nbt").existsSync()) {
      ctTest = (await NbtIo.read("test.nbt")).asCompoundTag();
    } else {
      ctTest = CompoundTag();
    }
    String token = "";
    dio.options.contentType = "application/json";
    dio.options.validateStatus = (i) {
      return true;
    };

    if (!ctTest.containsKey("loginToken")) {
      // Login to the server

      var reply = await dio.post(
        "https://api.systemswitchboard.com/auth/login",
        data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
      );

      token = reply.data["data"]["token"];
    } else {
      token = ctTest.get("loginToken")!.asString();
    }
    dio.options.headers["X-SB-Auth"] = token;

    // Test uploading the test image to the server in the image endpoint
    // First, test a obvious failure, should be a 404
    var reply = await dio.get(
      "https://api.systemswitchboard.com/images/thiswillfail",
    );
    expect(reply.statusCode, 404);

    print("[/images/thiswillfail] GET: PASS");

    // Read the file: imgtest.png
    var fData = File("test/imgtest.png").readAsBytesSync();
    var b64Data = base64.encode(fData);

    // Upload to the server's POST endpoint
    reply = await dio.post(
      "https://api.systemswitchboard.com/images/new",
      data: {"image": b64Data},
    );
    print("[/images/new] POST: ${reply.data}");
    expect(reply.data["success"], true);
    print("[/images/new] POST: PASS");

    var imageId = reply.data["data"]["img"];

    reply = await dio.put(
      "https://api.systemswitchboard.com/images/${imageId}",
      data: {"image": b64Data},
    );
    expect(reply.data["success"], true);
    print("[/images/$imageId] PUT: PASS");

    ctTest.put("imageTest", StringTag.valueOf(imageId));
    await NbtIo.write("test.nbt", ctTest);
  });

  test("Test image delete endpoint", () async {
    Dio dio = Dio();
    CompoundTag ctTest;
    if (File("test.nbt").existsSync()) {
      ctTest = (await NbtIo.read("test.nbt")).asCompoundTag();
    } else {
      ctTest = CompoundTag();
    }
    String token = "";
    dio.options.contentType = "application/json";

    if (!ctTest.containsKey("loginToken")) {
      // Login to the server

      var reply = await dio.post(
        "https://api.systemswitchboard.com/auth/login",
        data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
      );

      token = reply.data["data"]["token"];
    } else {
      token = ctTest.get("loginToken")!.asString();
    }

    dio.options.headers["X-SB-Auth"] = token;

    var imageId = ctTest.get("imageTest")!.asString();
    var reply = await dio.delete(
      "https://api.systemswitchboard.com/images/$imageId",
    );

    expect(reply.data["success"], true);
    print("[/images/$imageId] DELETE: PASS");

    ctTest.remove("imageTest");
    await NbtIo.write("test.nbt", ctTest);
  });

  test("Test alter endpoints", () async {
    // Test the endpoints designed for alter management.
    Dio dio = Dio();
    CompoundTag ctTest;
    if (File("test.nbt").existsSync()) {
      ctTest = (await NbtIo.read("test.nbt")).asCompoundTag();
    } else {
      ctTest = CompoundTag();
    }
    String token = "";
    dio.options.contentType = "application/json";

    if (!ctTest.containsKey("loginToken")) {
      // Login to the server

      var reply = await dio.post(
        "https://api.systemswitchboard.com/auth/login",
        data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
      );

      token = reply.data["data"]["token"];
    } else {
      token = ctTest.get("loginToken")!.asString();
    }

    dio.options.headers["X-SB-Auth"] = token;

    var reply = await dio.put(
      "https://api.systemswitchboard.com/alter/new",
      data: {
        "alter": {
          "name": "New Alter",
          "subid": -1,
          "parent": UUID.ZERO.toString(),
        },
      },
    );

    print("[/alter/new] PUT: ${reply.data}");
    expect(reply.data["success"], true);

    print("[/alter/new] PUT: PASS");
  });
}
