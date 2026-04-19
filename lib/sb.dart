import 'package:flutter/material.dart';
import 'package:switchboard/pages/aboutPage.dart';
import 'package:switchboard/pages/accountPage.dart';
import 'package:switchboard/pages/loginPage.dart';
import 'package:switchboard/pages/privacyPolicyPage.dart';
import 'package:switchboard/pages/registerPage.dart';

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
      },
    );
  }
}
