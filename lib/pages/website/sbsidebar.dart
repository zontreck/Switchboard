import 'package:flutter/material.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SBWebBar extends StatelessWidget {
  TextStyle sidebarStyle = TextStyle(
    color: Color(0xffe6e8e3),
    fontSize: 32,
    fontFamily: "merriweather",
    fontWeight: FontWeight.bold,
  );
  TextStyle sidebarStyleReg = TextStyle(
    color: Color(0xffe6e8e3),
    fontSize: 16,
    fontFamily: "nixieone",
  );

  SBWebBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff191b1c),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset(
              "webassets/Switchboard_Logo_6-29-26.png",
              width: 50,
              height: 50,
            ),
            const SizedBox(height: 50),
            Text("Switchboard", style: sidebarStyle),
            Text(
              "Site Version: \n${MemoryState.A.applicationVersion}",
              style: sidebarStyleReg,
            ),
            const SizedBox(height: 50),
            ListTile(
              title: Text("Home", style: sidebarStyleReg),
              onTap: () => {popUntil("/", context)},
            ),
            ListTile(
              title: Text("Help Support Us", style: sidebarStyleReg),
              onTap: () {
                Navigator.pushNamed(context, "/support");
              },
            ),
            ListTile(
              title: Text("Features", style: sidebarStyleReg),
              onTap: () {
                Navigator.pushNamed(context, "/features");
              },
            ),
            ListTile(
              title: Text("FAQ & Tutorials", style: sidebarStyleReg),
              onTap: () {
                Navigator.pushNamed(context, "/faq");
              },
            ),
            ListTile(
              title: Text("About Us", style: sidebarStyleReg),
              onTap: () {
                Navigator.pushNamed(context, "/about");
              },
            ),
            ListTile(
              title: Text("Astara Studios Patreon", style: sidebarStyleReg),
              onTap: () {
                launchUrlString("https://patreon.com/AstaraStudios");
              },
            ),
            ListTile(
              title: Text("Ko-Fi", style: sidebarStyleReg),
              onTap: () {
                launchUrlString("https://ko-fi.com/zontreck");
              },
            ),
            ListTile(
              title: Text("Discord", style: sidebarStyleReg),
              onTap: () {
                launchUrlString("https://discord.gg/gtd9JAgYVM");
              },
            ),
          ],
        ),
      ),
    );
  }
}
