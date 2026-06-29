import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:switchboard/pages/website/home.dart';
import 'package:switchboard/pages/website/sbsidebar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SBWebAboutUs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _sbabout();
  }
}

class _sbabout extends State<SBWebAboutUs> {
  static const double sidebarWidth = 280;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 800;

    return Scaffold(
      drawer: mobile ? Drawer(child: SBWebBar()) : null,
      appBar: mobile ? AppBar(title: const Text("Switchboard")) : null,
      body: mobile
          ? SingleChildScrollView(child: _buildContent())
          : Row(
              children: [
                SizedBox(width: sidebarWidth, child: SBWebBar()),
                Expanded(child: SingleChildScrollView(child: _buildContent())),
              ],
            ),
    );
  }

  Widget _buildContent() {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 800;
    final height = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("webassets/background01.png"),
            fit: BoxFit.fitWidth,
            alignment: AlignmentGeometry.topStart,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200),
            Text(
              "About Us",
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 65,
                color: Color(0xffa2c4c9),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 100),
            Container(
              width: width,
              decoration: BoxDecoration(color: Color(0xff1b1642)),
              child: Column(
                children: [
                  SBWebFeatPromo(
                    title: "About The Developers",
                    body:
                        "Currently we're only a team of two (well, two systems, that is!); One developer does all the coding, and another person works on the app's website, logos/visuals, and other visual design things (slowly learning to code too, though that takes time). We're also both disabled.",
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 75, // Horizontal spacing
                      runSpacing: 50, // Vertical spacing
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              "webassets/zontreck.png",
                              width: 200,
                              height: 200,
                            ),
                            SBWebFeatPromo(
                              title: "Zontreck || Code || (She/They)",
                              body:
                                  "Zontreck is a DID system, RAMCOA survivor, coder/programmer, and loves making their own apps or programs from scratch, especially whenever a solution doesn't already exist. They've been coding their whole life, and love advanced tech work, Second-Life, gaming and game development, and music.\n\n\n(We also LOVE games like Satisfactory or Vintage Story!)",
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(
                              "webassets/asterism.png",
                              width: 200,
                              height: 200,
                            ),
                            SBWebFeatPromo(
                              title:
                                  "Astérisme  || Art & Visual Design || (They/Star)",
                              body:
                                  "Astérisme is a polyfrag DID system, RAMCOA survivor, artist, singer-songwriter, and content creator. We've been drawing for almost our whole life, and love art/animation, design, fashion, ballet, and aerial arts. We're passionate about helping make things that help systems like ourself, and passionate about making system-related art and stories!",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  SBWebFeatPromo(
                    title: "Other Stuff We Make",
                    body:
                        "You can find some of the other things we each make below! Such as Zontreck's other coding projects, and Astérisme's Art/Tarot commissions.",
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
            SizedBox(height: 100),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 75, // Horizontal spacing
                runSpacing: 50, // Vertical spacing
                children: [
                  Column(
                    children: [
                      Text(
                        "Zontreck",
                        style: TextStyle(
                          fontFamily: "ptsans",
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 24,
                          color: Color(0xffa2c4c9),
                        ),
                      ),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString("https://zontreck.com");
                        },
                        title: Text(
                          "Personal website / Coding portfolio",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString("https://git.zontreck.com/zontreck");
                        },
                        title: Text(
                          "Personal git repository account",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString(
                            "https://git.zontreck.com/Astara/Switchboard",
                          );
                        },
                        title: Text(
                          "Switchboard Source code",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString("https://patreon.com/AstaraStudios");
                        },
                        title: Text(
                          "Astara Studios Patreon",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString("https://ko-fi.com/zontreck");
                        },
                        title: Text(
                          "Astara Studios Ko-Fi (zontreck)",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Astérisme",
                        style: TextStyle(
                          fontFamily: "ptsans",
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 24,
                          color: Color(0xffa2c4c9),
                        ),
                      ),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString("https://theasterismtheatre.com");
                        },
                        title: Text(
                          "Website (Portfolio / Commissions)",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString(
                            "https://linktr.ee/TheAsterismTheatre",
                          );
                        },
                        title: Text(
                          "Linktree",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString(
                            "https://ko-fi.com/theasterismtheatre",
                          );
                        },
                        title: Text(
                          "Ko-Fi",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString("https://patreon.com/AstaraStudios");
                        },
                        title: Text(
                          "Astara Studios Patreon",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SBOutlineButton(
                        roundedness: 20,
                        thickness: 3,
                        onTap: () {
                          launchUrlString(
                            "https://patreon.com/theasterismtheatre",
                          );
                        },
                        title: Text(
                          "Patreon (The Asterism Theatre)",
                          style: TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text(
              "©️ Copyright Astara Studios 2026",
              style: TextStyle(
                fontFamily: "unitblock",
                fontSize: 28,
                color: Color(0xff00a9a9),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
