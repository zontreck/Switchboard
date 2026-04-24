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

Color getAlterBackgroundColor() {
  MemoryState ms = MemoryState();
  return Color.fromARGB(
    ms.AlterBackgroundAlpha,
    ms.AlterBackgroundRed,
    ms.AlterBackgroundGreen,
    ms.AlterBackgroundBlue,
  );
}

Future<void> setAlterBackgroundColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.AlterBackgroundAlpha = (b.a.clamp(0.0, 1.0) * 255).round();
  ms.AlterBackgroundRed = (b.r.clamp(0.0, 1.0) * 255).round();
  ms.AlterBackgroundGreen = (b.g.clamp(0.0, 1.0) * 255).round();
  ms.AlterBackgroundBlue = (b.b.clamp(0.0, 1.0) * 255).round();

  await setAppSettings(ms.serialize());
}

Color getAlterTextColor() {
  MemoryState ms = MemoryState();
  return Color.fromARGB(
    ms.AlterTextAlpha,
    ms.AlterTextRed,
    ms.AlterTextGreen,
    ms.AlterTextBlue,
  );
}

Future<void> setAlterTextColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.AlterTextAlpha = (b.a.clamp(0.0, 1.0) * 255).round();
  ms.AlterTextRed = (b.r.clamp(0.0, 1.0) * 255).round();
  ms.AlterTextGreen = (b.g.clamp(0.0, 1.0) * 255).round();
  ms.AlterTextBlue = (b.b.clamp(0.0, 1.0) * 255).round();

  await setAppSettings(ms.serialize());
}

Color getNavSelColor() {
  MemoryState ms = MemoryState();
  return Color.fromARGB(
    ms.NavSelAlpha,
    ms.NavSelRed,
    ms.NavSelGreen,
    ms.NavSelBlue,
  );
}

Future<void> setNavSelColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.NavSelAlpha = (b.a.clamp(0.0, 1.0) * 255).round();
  ms.NavSelRed = (b.r.clamp(0.0, 1.0) * 255).round();
  ms.NavSelGreen = (b.g.clamp(0.0, 1.0) * 255).round();
  ms.NavSelBlue = (b.b.clamp(0.0, 1.0) * 255).round();

  await setAppSettings(ms.serialize());
}

Color getNavUnselColor() {
  MemoryState ms = MemoryState();
  return Color.fromARGB(
    ms.NavUnSelAlpha,
    ms.NavUnSelRed,
    ms.NavUnSelGreen,
    ms.NavUnSelBlue,
  );
}

Future<void> setNavUnselColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.NavUnSelAlpha = (b.a.clamp(0.0, 1.0) * 255).round();
  ms.NavUnSelRed = (b.r.clamp(0.0, 1.0) * 255).round();
  ms.NavUnSelGreen = (b.g.clamp(0.0, 1.0) * 255).round();
  ms.NavUnSelBlue = (b.b.clamp(0.0, 1.0) * 255).round();

  await setAppSettings(ms.serialize());
}
