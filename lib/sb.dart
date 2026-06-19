import 'package:flutter/material.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/FirstRunPage.dart';
import 'package:switchboard/pages/aboutPage.dart';
import 'package:switchboard/pages/accountPage.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/pages/editFields.dart';
import 'package:switchboard/pages/feedbackHUB.dart';
import 'package:switchboard/pages/fontPage.dart';
import 'package:switchboard/pages/loginPage.dart';
import 'package:switchboard/pages/octoconSettings.dart';
import 'package:switchboard/pages/privacyPolicyPage.dart';
import 'package:switchboard/pages/registerPage.dart';
import 'package:switchboard/pages/settingsPage.dart';

class Switchboard extends StatelessWidget {
  const Switchboard({super.key});

  @override
  Widget build(BuildContext context) {
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
            "/account": (ctx) => AccountPage(),
            "/account/settings": (ctx) => SettingsPage(),
            "/account/settings/ads": (ctx) => AdSettingsPage(),
            "/account/settings/font": (ctx) => FontPage(),
            "/account/settings/octocon": (ctx) => OctoconImport(),
            "/account/settings/fields": (ctx) => EditFieldsPage(),
            "/account/settings/fields/edit": (ctx) => EditField(),
            "/editAlter": (ctx) => EditAlterPage(),
            "/feedback": (ctx) => FeedbackHUB(),
          },
        );
      },
    );
  }
}
