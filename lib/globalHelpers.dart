import 'dart:async' show Future;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:libac_dart/utils/StringUtils.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/sb.dart';

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

Future<double> getAdHeight() async {
  bool optIn = (await getAdsOptIn()) ?? false;
  return optIn ? 50 : 0;
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

  if (await needsNewOnboarding()) return 0;

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

Color getReadableTextColor(Color backgroundColor, Color defaultColor) {
  Color colorWhite = Colors.white;
  Color colorBlack = Colors.black;
  double defLum = defaultColor.computeLuminance();
  double bgLum = backgroundColor.computeLuminance();
  if (defLum > 0.8) {
    colorWhite = defaultColor;
  } else {
    colorBlack = defaultColor;
  }

  return bgLum > 0.4 ? colorBlack : colorWhite;
}

void setGlowColors(List<Color> colors) {
  MemoryState.A.glowColors = [];
  for (var color in colors) {
    MemoryState.A.glowColors.add(Color2List(color));
  }

  Switchboard.rebuild();
}

List<Color> getPrideColors() {
  return [
    Color(0xFFFF0000),
    Color(0xFFFF9900),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
  ];
}

List<Color> getTransColors() {
  return [
    Color(0xFF00CCCC),
    Color.fromARGB(255, 255, 110, 255),
    Color(0xFFFFFFFF),
    Color.fromARGB(255, 255, 110, 255),
    Color(0xFF00CCCC),
  ];
}

List<Color> getLesbianColors() {
  return [
    Color(0xFFD62825),
    Color(0xFFFF9B55),
    Color(0xFFFFFFFF),
    Color(0xFFD562A6),
    Color(0xFFA40E62),
  ];
}

List<Color> getIntersexColors() {
  return [Color(0xFFFFD950), Color(0xFF7900AC), Color(0xFFFFD950)];
}

List<Color> getNonBinaryColors() {
  return [
    Color(0xFFFFF458),
    Color(0xFFFFFFFF),
    Color(0xFF9D59D1),
    Color(0xFF292929),
  ];
}

List<Color> getPanColors() {
  return [Color(0xFFFF1D8E), Color(0xFFFFD850), Color(0xFF1CB3F7)];
}

List<Color> getOmniColors() {
  return [
    Color(0xFFFF9CCE),
    Color(0xFFFF52BF),
    Color(0xFF200044),
    Color(0xFF685FF4),
    Color(0xFF8EA6F7),
  ];
}

List<Color> getBiColors() {
  return [Color(0xFFD71771), Color(0xFF9C4E97), Color(0xFF0035A9)];
}

List<Color> getAceColors() {
  return [
    Color(0xFF000000),
    Color(0xFFA4A4A5),
    Color(0xFFFFFFFF),
    Color(0xFF810481),
  ];
}

List<Color> getAroColors() {
  return [
    Color(0xFF3CA640),
    Color(0xFFA9D47A),
    Color(0xFFFFFFFF),
    Color(0xFFAAABAB),
    Color(0xFF000000),
  ];
}

List<Color> getAroAceColors() {
  return [
    Color(0xFFE28E39),
    Color(0xFFECCE4B),
    Color(0xFFFFFFFF),
    Color(0xFF62AFDD),
    Color(0xFF1A3555),
  ];
}

List<Color> getMlmFlag() {
  return [
    Color(0xFF008F70),
    Color(0xFF21CFAB),
    Color(0xFF9AE9C3),
    Color(0xFFFFFFFF),
    Color(0xFF7CAEE4),
    Color(0xFF4F47CC),
    Color(0xFF3B1379),
  ];
}

List<Color> getAbroColors() {
  return [
    Color(0xFF65C487),
    Color(0xFFB6E4CD),
    Color(0xFFFFFFFF),
    Color(0xFFE798B8),
    Color(0xFFDA426E),
  ];
}

List<Color> getGenderfluidColors() {
  return [
    Color(0xFFFE76A4),
    Color(0xFFF5F5F5),
    Color(0xFFC011D7),
    Color(0xFF282828),
    Color(0xFF303CBE),
  ];
}

List<Color> getSystemfluidColors() {
  return [
    Color(0xFF59EFB3),
    Color(0xFFFFFFFF),
    Color(0xFF72EBA5),
    Color(0xFF000000),
    Color(0xFF199F85),
  ];
}

List<Color> getGilbertBakerPrideColors() {
  return [
    Color(0xFFCC66F6),
    Color(0xFFFF6498),
    Color(0xFFFD202D),
    Color(0xFFFF9940),
    Color(0xFFFFFF5B),
    Color(0xFF019A2D),
    Color(0xFF0399CC),
    Color(0xFF34009A),
    Color(0xFF990699),
  ];
}

List<Color> getQueerColors() {
  return [
    Color(0xFF000000),
    Color(0xFF99D9EA),
    Color(0xFF00a2e9),
    Color(0xFFb5e61c),
    Color(0xFFFFFFFF),
    Color(0xFFffc90d),
    Color(0xFFfe6666),
    Color(0xFFffaec8),
    Color(0xFF000000),
  ];
}

List<Color> getPolysexualColors() {
  return [Color(0xFFF71CBA), Color(0xFF09D469), Color(0xFF1A92F6)];
}

List<Color> getPolyAmVar1Colors() {
  return [
    Color(0xFFFFFFFF),
    Color(0xFFFBBF49),
    Color(0xFF039FE2),
    Color(0xFFE61B51),
    Color(0xFF340D45),
  ];
}

List<Color> getPolyAmVar2Colors() {
  return [
    Color(0xFF0703F3),
    Color(0xFFFF202D),
    Color(0xFFFEFF5B),
    Color(0xFF000000),
  ];
}

List<Color> getXenogenderColors() {
  return [
    Color(0xFFFF6693),
    Color(0xFFFF9B99),
    Color(0xFFFFB883),
    Color(0xFFFBFFA7),
    Color(0xFF85BCF8),
    Color(0xFF9E85F6),
    Color(0xFFA512F4),
  ];
}

List<Color> getGenderqueerColors() {
  return [Color(0xFFB67FDD), Color(0xFFFFFFFF), Color(0xFF488226)];
}

List<Color> getNeurogenderAColors() {
  return [
    Color(0xFFDF2D48),
    Color(0xFFBEDA57),
    Color(0xFFB0F3DE),
    Color(0xFF942D98),
  ];
}

List<Color> getNeurogenderBColors() {
  return [
    Color(0xFFA278CF),
    Color(0xFF91CAEF),
    Color(0xFFFFFFFF),
    Color(0xFFFFDD81),
    Color(0xFFF29382),
  ];
}

List<Color> getAutigenderBColors() {
  return [
    Color(0xFFB188F7),
    Color(0xFF88F3FC),
    Color(0xFFC3FF88),
    Color(0xFFFFC788),
    Color(0xFFFF88B5),
  ];
}

List<Color> getAutigenderAColors() {
  return [
    Color(0xFFFF5C6A),
    Color(0xFFFFB88C),
    Color(0xFFFFF1AC),
    Color(0xFF8CD1FA),
    Color(0xFF6694F0),
  ];
}

List<Color> getGlowColors() {
  List<Color> colors = [];

  for (var color in MemoryState.A.glowColors) {
    colors.add(ColorFromList(color));
  }

  return colors;
}

List<Color> getCustomGlow({Color? alterPreferedColor = null}) {
  if (MemoryState.A.prideGlow) {
    return getPrideColors();
  } else if (MemoryState.A.transGlow) {
    return getTransColors();
  } else if (MemoryState.A.lesbianGlow) {
    return getLesbianColors();
  } else if (MemoryState.A.intersexGlow) {
    return getIntersexColors();
  } else if (MemoryState.A.nonBinaryGlow) {
    return getNonBinaryColors();
  } else if (MemoryState.A.panGlow) {
    return getPanColors();
  } else if (MemoryState.A.omniGlow) {
    return getOmniColors();
  } else if (MemoryState.A.biGlow) {
    return getBiColors();
  } else if (MemoryState.A.aceGlow) {
    return getAceColors();
  } else if (MemoryState.A.aroGlow) {
    return getAroColors();
  } else if (MemoryState.A.aroAceGlow) {
    return getAroAceColors();
  } else if (MemoryState.A.gayGlow) {
    return getMlmFlag();
  } else if (MemoryState.A.abroGlow) {
    return getAbroColors();
  } else if (MemoryState.A.genderfluidGlow) {
    return getGenderfluidColors();
  } else if (MemoryState.A.systemfluidGlow) {
    return getSystemfluidColors();
  } else if (MemoryState.A.gilberBakerGlow) {
    return getGilbertBakerPrideColors();
  } else if (MemoryState.A.queerGlow) {
    return getQueerColors();
  } else if (MemoryState.A.polysexualGlow) {
    return getPolysexualColors();
  } else if (MemoryState.A.polyamAGlow) {
    return getPolyAmVar1Colors();
  } else if (MemoryState.A.polyamBGlow) {
    return getPolyAmVar2Colors();
  } else if (MemoryState.A.xenogenderGlow) {
    return getXenogenderColors();
  } else if (MemoryState.A.genderqueerGlow) {
    return getGenderqueerColors();
  } else if (MemoryState.A.neurogenderAGlow) {
    return getNeurogenderAColors();
  } else if (MemoryState.A.neurogenderBGlow) {
    return getNeurogenderBColors();
  } else if (MemoryState.A.autigenderAGlow) {
    return getAutigenderAColors();
  } else if (MemoryState.A.autigenderBGlow) {
    return getAutigenderBColors();
  } else {
    var c = getGlowColors();
    if (alterPreferedColor != null) {
      c.add(alterPreferedColor);
    }

    return c;
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

void flushImageCaches() {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
}

Color htmlColorToFlutter(String hex) {
  if (hex.isEmpty) {
    return Colors.black;
  }
  hex = hex.replaceAll('#', '');

  // If no alpha is provided, assume fully opaque.
  if (hex.length == 6) {
    hex = 'FF$hex';
  }

  return Color(int.parse(hex, radix: 16));
}

void popUntil(String name, BuildContext context) {
  Navigator.popUntil(context, (rt) {
    return rt.isFirst || rt.settings.name == name;
  });
}

Future<void> requestAd(
  Function(InterstitialAd) callback,
  Function() errorCallback,
) async {
  bool optIn = await getAdsOptIn() ?? false;
  if (!optIn) return; // block ads entirely if not enabled globally.

  await InterstitialAd.load(
    adUnitId: "ca-app-pub-3401801111605896/5698618617",
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        // Called when an ad is successfully received.
        debugPrint('Ad was loaded.');
        // Keep a reference to the ad so you can show it later.
        callback(ad);
      },
      onAdFailedToLoad: (LoadAdError error) {
        // Called when an ad request failed.
        debugPrint('Ad failed to load with error: $error');

        errorCallback();
      },
    ),
  );
}

void pageChanged() {
  MemoryState.A.adSettings.navigated();

  if (MemoryState.A.adSettings.shouldShowAd()) {
    requestAd((A) async {
      A.show();
    }, () {});

    MemoryState.A.adSettings.resetPageCounter();
  }

  setAppSettings();
}
