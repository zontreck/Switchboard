import 'package:flutter/material.dart';
import 'package:switchboard/pages/aboutPage.dart';
import 'package:switchboard/pages/accountPage.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/pages/editFields.dart';
import 'package:switchboard/pages/loginPage.dart';
import 'package:switchboard/pages/privacyPolicyPage.dart';
import 'package:switchboard/pages/registerPage.dart';
import 'package:switchboard/pages/settingsPage.dart';

class Switchboard extends StatelessWidget {
  const Switchboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Switchboard",
      theme: ThemeData.dark(),
      routes: {
        "/": (ctx) => SBLoginPage(),
        "/about": (ctx) => SBAboutPage(),
        "/register": (ctx) => SBRegisterPage(),
        "/privacy": (ctx) => PrivacyPolicyPage(),
        "/account": (ctx) => AccountPage(),
        "/account/settings": (ctx) => SettingsPage(),
        "/account/settings/fields": (ctx) => EditFieldsPage(),
        "/account/settings/fields/edit": (ctx) => EditField(),
        "/editAlter": (ctx) => EditAlterPage(),
      },
    );
  }
}
