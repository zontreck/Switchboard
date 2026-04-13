import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() {
  test("Test version endpoint", () async {
    Dio dio = Dio();
    var reply = await dio.get("https://cdn.zontreck.com/version");
    var jsonData = reply.data as Map<String, dynamic>;

    print("SERVER: ${reply.headers.map["Server"]}");

    print("[/version]: ${json.encode(jsonData)}");
    expect(jsonData['data']['product'], "Switchboard API Server (PHP)");

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
      "https://cdn.zontreck.com/user/1234apitest",
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
    var reply = await dio.get("https://cdn.zontreck.com/user/1234apitest");
    print("[/user/1234apitest]: ${json.encode(reply.data)}");

    expect(reply.data['success'], true);
    expect(reply.data['data']['user'], "1234apitest");

    print("[/user/1234apitest] (GET): PASS");
  });

  test("Test auth endpoints", () async {
    Dio dio = Dio();
    SharedPreferencesAsync spa = SharedPreferencesAsync();
    dio.options.contentType = "application/json";

    var reply = await dio.post(
      "https://cdn.zontreck.com/auth/login",
      data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
    );
    print("[/auth/login]: ${json.encode(reply.data)}");
    expect(reply.data['success'], true);
    print("[/auth/login]: PASS");

    String token = reply.data['data']['token'];

    dio.options.headers["X-SB-Auth"] = token;

    reply = await dio.get("https://cdn.zontreck.com/auth/check");
    print("[/auth/check]: ${reply.data}");
    expect(reply.data['success'], true);

    print("[/auth/check]: PASS");

    reply = await dio.get("https://cdn.zontreck.com/auth/refresh");
    print("[/auth/refresh]: ${reply.data}");
    expect(reply.data['success'], true);

    print("[/auth/refresh]: PASS");
    await spa.setString("loginToken", reply.data["data"]["token"]);
  });

  test("Test image endpoints", () async {
    Dio dio = Dio();
    SharedPreferencesAsync SPA = SharedPreferencesAsync();
    String? token = await SPA.getString("loginToken");
    dio.options.contentType = "application/json";

    if (token == null) {
      // Login to the server

      var reply = await dio.post(
        "https://cdn.zontreck.com/auth/login",
        data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
      );

      token = reply.data["data"]["token"];
    }
    dio.options.headers["X-SB-Auth"] = token;

    // Test uploading the test image to the server in the image endpoint
    // First, test a obvious failure, should be a 404
    var reply = await dio.get("https://cdn.zontreck.com/images/thiswillfail");
    expect(reply.statusCode, 404);

    print("[/images/thiswillfail] GET: PASS");

    // Read the file: imgtest.png
    var fData = File("imgtest.png").readAsBytesSync();
    var b64Data = base64.encode(fData);

    // Upload to the server's POST endpoint
    reply = await dio.post(
      "https://cdn.zontreck.com/images/new",
      data: {"image": b64Data},
    );
    expect(reply.data["success"], true);
    print("[/images/new] POST: ${reply.data["data"]["img"]}");
    print("[/images/new] POST: PASS");

    var imageId = reply.data["data"]["img"];

    reply = await dio.put(
      "https://cdn.zontreck.com/images/${imageId}",
      data: {"image": b64Data},
    );
    expect(reply.data["success"], true);
    print("[/images/$imageId] PUT: PASS");

    await SPA.setString("imageTest", imageId);
  });

  test("Test image delete endpoint", () async {
    Dio dio = Dio();
    SharedPreferencesAsync SPA = SharedPreferencesAsync();
    String? token = await SPA.getString("loginToken");
    dio.options.contentType = "application/json";

    if (token == null) {
      // Login to the server

      var reply = await dio.post(
        "https://cdn.zontreck.com/auth/login",
        data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
      );

      token = reply.data["data"]["token"];
    }
    dio.options.headers["X-SB-Auth"] = token;

    var imageId = await SPA.getString("imageTest");
    var reply = await dio.delete("https://cdn.zontreck.com/images/$imageId");

    expect(reply.data["success"], true);
    print("[/images/$imageId] DELETE: PASS");

    await SPA.remove("imageTest");
  });
}
