import 'package:flutter/material.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/FirstRunPage.dart';
import 'package:switchboard/pages/aboutPage.dart';
import 'package:switchboard/pages/mainPage.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/pages/settings_categories/appearance.dart';
import 'package:switchboard/pages/settings_categories/editFields.dart';
import 'package:switchboard/pages/feedbackHUB.dart';
import 'package:switchboard/pages/settings_categories/fontPage.dart';
import 'package:switchboard/pages/settings_categories/glowPresets.dart';
import 'package:switchboard/pages/settings_categories/glowSettingsPage.dart';
import 'package:switchboard/pages/loginPage.dart';
import 'package:switchboard/pages/settings_categories/3pSettings.dart';
import 'package:switchboard/pages/privacyPolicyPage.dart';
import 'package:switchboard/pages/settings_categories/progressDisplayPage.dart';
import 'package:switchboard/pages/registerPage.dart';
import 'package:switchboard/pages/settings.dart';
import 'package:switchboard/pages/settings_categories/account.dart';
import 'package:switchboard/pages/settings_categories/ads.dart';
import 'package:switchboard/pages/settings_categories/security.dart';

class Switchboard extends StatefulWidget {
  static void Function() rebuild = () {
    print("Dummy rebuild function invoked too soon");
  };

  const Switchboard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _switchboard();
  }
}

class _switchboard extends State<Switchboard> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Switchboard.rebuild = rebuild;
    NetworkCaches.onInvalidate = rebuild;
    return ValueListenableBuilder(
      valueListenable: customFontNotifier,
      builder: (ctx, value, _) {
        return MaterialApp(
          title: "Switchboard",
          theme: getApplicationTheme(),
          initialRoute: "/onboarding/0",
          routes: {
            "/onboarding/0": (ctx) => FirstRunPage(),
            "/onboarding/1": (ctx) => OnboardingTermsOfServicePage(),
            "/onboarding/2": (ctx) => OnboardingPrivacyPolicyPage(),
            "/login": (ctx) => SBLoginPage(),
            "/about": (ctx) => SBAboutPage(),
            "/register": (ctx) => SBRegisterPage(),
            "/privacy": (ctx) => PrivacyPolicyPage(),
            "/tos": (ctx) => TermsOfServicePage(),
            "/settings": (ctx) => SettingsPage(),
            "/settings/font": (ctx) => FontPage(),
            "/settings/ads": (ctx) => AdSettings(),
            "/settings/appearance": (ctx) => AppearanceSettings(),
            "/settings/account": (ctx) => AccountSettings(),
            "/settings/account/security": (ctx) => SecuritySettings(),
            "/settings/account/fields": (ctx) => EditFieldsPage(),
            "/settings/account/fields/edit": (ctx) => EditField(),
            "/settings/3pjson": (ctx) => ThirdPartyImport(),
            "/settings/3p/migrate": (ctx) => ThirdPartyMigrationProgress(),
            "/settings/glow": (ctx) => GlowSettingsPage(),
            "/settings/glow/presets": (ctx) => GlowPresets(),
            "/account": (ctx) => AccountPage(),
            "/editAlter": (ctx) => EditAlterPage(),
            "/feedback": (ctx) => FeedbackHUB(),
          },
        );
      },
    );
  }
}
