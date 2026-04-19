import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchboard/dart/MemoryState.dart';

Future<String> loadAsset(String asset) async {
  return await rootBundle.loadString(asset);
}

class Policies {
  static Future<String> privacyPolicy() async {
    return await loadAsset("privacypolicy.md");
  }
}

class SwitchboardConsts {
  static Future<String> getPackageVersion() async {
    PackageInfo inf = await PackageInfo.fromPlatform();

    return "${inf.version}+${inf.buildNumber}";
  }
}

Future<void> setAuthToken(String authToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("token", authToken);

  MemoryState ms = MemoryState();
  ms.authenticationToken = authToken;
}

Future<String> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  MemoryState ms = MemoryState();
  ms.authenticationToken = prefs.getString("token") ?? "";

  return prefs.getString("token") ?? "";
}
