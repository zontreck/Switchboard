import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:libac_dart/nbt/SnbtIo.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
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

  await setAppSettings(ms.serialize());
}

Future<String> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  MemoryState ms = MemoryState();
  ms.authenticationToken = prefs.getString("token") ?? "";

  return prefs.getString("token") ?? "";
}

Future<void> setAppSettings(CompoundTag ct) async {
  MemoryState ms = MemoryState();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String snbt = SnbtIo.writeToString(ct);

  prefs.setString("settings", snbt);
  ms.deserialize(ct);

  //print("DEBUG: $snbt");
}

Future<void> getAppSettings() async {
  MemoryState ms = MemoryState();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  CompoundTag ct = (await SnbtIo.readFromString(
    prefs.getString("settings") ?? "{}",
  )).asCompoundTag();
  ms.deserialize(ct);
}

List<int> Color2List(Color b) {
  List<int> color = [];

  color.add((b.a.clamp(0.0, 1.0) * 255).round());
  color.add((b.r.clamp(0.0, 1.0) * 255).round());
  color.add((b.g.clamp(0.0, 1.0) * 255).round());
  color.add((b.b.clamp(0.0, 1.0) * 255).round());

  return color;
}

Color ColorFromList(List<int> b) {
  return Color.fromARGB(b[0], b[1], b[2], b[3]);
}

bool identicalColors(List<int> a, List<int> b) {
  if (a[0] != b[0] || a[1] != b[1] || a[2] != b[2] || a[3] != b[3]) {
    return false;
  } else {
    return true;
  }
}

Color getAlterBackgroundColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.AlterBackgroundColor);
}

Future<void> setAlterBackgroundColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.AlterBackgroundColor = Color2List(b);

  await setAppSettings(ms.serialize());
}

Color getAlterTextColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.AlterTextColor);
}

Future<void> setAlterTextColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.AlterTextColor = Color2List(b);

  await setAppSettings(ms.serialize());
}

Color getNavSelColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.NavSelColor);
}

Future<void> setNavSelColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.NavSelColor = Color2List(b);

  await setAppSettings(ms.serialize());
}

Color getNavUnselColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.NavUnSelColor);
}

Future<void> setNavUnselColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.NavUnSelColor = Color2List(b);

  await setAppSettings(ms.serialize());
}
