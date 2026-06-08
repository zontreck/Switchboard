import 'dart:async' show Future;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:libac_dart/utils/StringUtils.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';

final ValueNotifier<String> customFontNotifier = ValueNotifier(
  MemoryState.A.customFontFamily,
);

Future<String> loadAsset(String asset) async {
  return await rootBundle.loadString(asset);
}

class Policies {
  static Future<String> privacyPolicy() async {
    return await loadAsset("assets/privacypolicy.md");
  }

  static Future<String> tos() async {
    return await loadAsset("assets/tos.md");
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

  await setAppSettings();
}

Future<void> setApplicationFont(Uint8List binary) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("curFont", base64.encode(binary));

  String fontFamily = StringUtils.generateRandomString(16);
  FontLoader fl = FontLoader(fontFamily);
  fl.addFont(Future.value(ByteData.sublistView(binary)));
  await fl.load();

  MemoryState.A.useCustomFont = true;
  MemoryState.A.customFontFamily = fontFamily;
  customFontNotifier.value = fontFamily;
}

Future<void> setAdsSupport(bool option) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("ads", option);
}

Future<bool?> getAdsOptIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("ads");
}

Future<void> updateOnboardingPhase(int phase) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt("onboarding", phase);
  await prefs.setString(
    "onboard_ver",
    await SwitchboardConsts.getPackageVersion(),
  );

  if (phase == 0) {
    await prefs.remove("ads");
  }
}

Future<bool> needsNewOnboarding() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String lastVer = prefs.getString("onboard_ver") ?? "";

  return lastVer != await SwitchboardConsts.getPackageVersion();
}

Future<int> getOnboardingPhase() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getInt("onboarding") ?? 0;
}

Future<void> clearApplicationFont() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("curFont");

  MemoryState.A.useCustomFont = false;
  MemoryState.A.customFontFamily = "";
  customFontNotifier.value = "";
}

Future<Uint8List> getApplicationFont() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? fontStr = prefs.getString("curFont");
  if (fontStr == null) {
    MemoryState.A.useCustomFont = false;
    MemoryState.A.customFontFamily = "";
    return Uint8List(0);
  }

  Uint8List fontBytes = base64.decode(fontStr);

  if (!MemoryState.A.useCustomFont) {
    String fontFamily = StringUtils.generateRandomString(16);
    MemoryState.A.customFontFamily = fontFamily;

    FontLoader fl = FontLoader(fontFamily);
    fl.addFont(Future.value(ByteData.sublistView(fontBytes)));
    fl.load();
  }
  MemoryState.A.useCustomFont = true;

  return fontBytes;
}

Future<bool> checkStoragePermissions() async {
  Permission storage = Permission.manageExternalStorage;
  if (await storage.isDenied) {
    await storage.request();
  }

  return await storage.isGranted;
}

ThemeData getApplicationTheme() {
  MemoryState ms = MemoryState();

  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    textTheme: ms.useCustomFont
        ? TextTheme(
            displayLarge: TextStyle(fontFamily: ms.customFontFamily),
            displayMedium: TextStyle(fontFamily: ms.customFontFamily),
            displaySmall: TextStyle(fontFamily: ms.customFontFamily),

            headlineLarge: TextStyle(fontFamily: ms.customFontFamily),
            headlineMedium: TextStyle(fontFamily: ms.customFontFamily),
            headlineSmall: TextStyle(fontFamily: ms.customFontFamily),

            titleLarge: TextStyle(fontFamily: ms.customFontFamily),
            titleMedium: TextStyle(fontFamily: ms.customFontFamily),
            titleSmall: TextStyle(fontFamily: ms.customFontFamily),

            bodyLarge: TextStyle(fontFamily: ms.customFontFamily),
            bodyMedium: TextStyle(fontFamily: ms.customFontFamily),
            bodySmall: TextStyle(fontFamily: ms.customFontFamily),

            labelLarge: TextStyle(fontFamily: ms.customFontFamily),
            labelMedium: TextStyle(fontFamily: ms.customFontFamily),
            labelSmall: TextStyle(fontFamily: ms.customFontFamily),
          )
        : null,
  );
}

Future<String> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  MemoryState ms = MemoryState();
  ms.authenticationToken = prefs.getString("token") ?? "";

  return prefs.getString("token") ?? "";
}

Future<void> setAppSettings() async {
  MemoryState ms = MemoryState();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString("settings", json.encode(ms.toJson(theme: false)));
}

Future<void> getAppSettings() async {
  MemoryState ms = MemoryState();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isNBT = false;
  String settings = prefs.getString("settings") ?? "{}";
  try {
    json.decode(settings);
  } catch (E) {
    isNBT = true;
  }

  if (!isNBT) {
    ms.fromJson(typeCorrectJsonDecode(prefs.getString("settings") ?? "{}"));
  } else {
    ms.fromJson({}); // Throw away existing settings.
  }
}

Color getAlterBackgroundColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.AlterBackgroundColor);
}

Future<void> setAlterBackgroundColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.AlterBackgroundColor = Color2List(b);

  await setAppSettings();
}

Color getAlterTextColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.AlterTextColor);
}

Future<void> setAlterTextColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.AlterTextColor = Color2List(b);

  await setAppSettings();
}

Color getNavSelColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.NavSelColor);
}

Future<void> setNavSelColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.NavSelColor = Color2List(b);

  await setAppSettings();
}

Color getNavUnselColor() {
  MemoryState ms = MemoryState();
  return ColorFromList(ms.NavUnSelColor);
}

Future<void> setNavUnselColor(Color b) async {
  MemoryState ms = MemoryState();
  ms.NavUnSelColor = Color2List(b);

  await setAppSettings();
}
