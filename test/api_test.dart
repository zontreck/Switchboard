import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libac_dart/utils/Hashing.dart';

main() {
  test("Test version endpoint", () async {
    Dio dio = Dio();
    var reply = await dio.get("https://cdn.zontreck.com/version");
    var jsonData = reply.data as Map<String, dynamic>;

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
    dio.options.contentType = "application/json";

    var reply = await dio.post(
      "https://cdn.zontreck.com/auth/login",
      data: {"auth": Hashing.md5Hash("test"), "username": "1234apitest"},
    );
    print("[/auth/login]: ${json.encode(reply.data)}");
    expect(reply.data['success'], true);
    print("[/auth/login]: PASS");

    String token = reply.data['data']['token'];

    dio.options.headers["Authorization"] = token;

    reply = await dio.get("https://cdn.zontreck.com/auth/check");
    print("[/auth/check]: ${reply.data}");
    expect(reply.data['success'], true);

    print("[/auth/check]: PASS");
  });
}
