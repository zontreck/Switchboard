import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:switchboard/pages/website/sbsidebar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SBWebHome extends StatefulWidget {
  const SBWebHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _sbhome();
  }
}

class _sbhome extends State<SBWebHome> {
  static const double sidebarWidth = 280;

  void openFeatures() {
    Navigator.pushNamed(context, "/features");
  }

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
          children: [
            SizedBox.fromSize(size: Size.fromHeight(150)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: mobile ? 32 : 96),
              child: Column(
                children: [
                  Text(
                    "Switchboard",
                    style: TextStyle(
                      fontSize: mobile ? 50 : 72,
                      fontFamily: "nixieone",
                      fontWeight: FontWeight.bold,
                      color: Color(0xff5343d9),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "A system-tracking app for  DID/OSDD systems, Plurals, Kins, or Roleplay!",
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: "merriweather",
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9ec1c6),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Track your system, alters, headmates, kins, or  roleplays, and just everything for that in-general. \nThe app lets you see who has fronted, for how long, and many other helpful features!  Our goal is to eventually have all the  same features as other discontinued apps, and add even more that users want, from accessibility to aesthetic customization.\nIt will also eventually have a synced Discord proxy bot!",
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: "merriweather",
                      fontStyle: FontStyle.italic,
                      color: Color(0xffc7bddf),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 26,
                        fontFamily: "merriweather",
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffc7bddf),
                      ),
                      children: const [
                        TextSpan(
                          text:
                              "This app is compatible with Octocon export data, and will automatically migrate any profiles, custom fields' data, and avatar photos",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text:
                              " from any relevant CDNs (Albeit a bit slowly due to Octocon's rate limit; We also host our own CDN to allow images or avatar images to be permalinked!).\nWe're hoping to add import from SimplyPlural and other alternatives at some point.",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 300),
                ],
              ),
            ),
            Container(
              width: width,
              decoration: BoxDecoration(color: Color(0xff1b1642)),
              child: Column(
                children: [
                  SizedBox(height: 150),
                  SBOutlineButton(
                    onTap: () {
                      Navigator.pushNamed(context, "/features");
                    },
                    title: Text("(See more on the features page!)"),
                    roundedness: 10,
                    thickness: 2,
                  ),
                  SizedBox(height: 150),

                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 75, // Horizontal spacing
                      runSpacing: 50, // Vertical spacing
                      children: getPromoFeatures(context, false),
                    ),
                  ),
                  SizedBox(height: 250),
                  Text(
                    "Download Switchboard on the Play Store, App Store, \nor launch the Web App!",
                    style: TextStyle(
                      fontFamily: "ptsans",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 200),
                  InkWell(
                    onTap: () {
                      launchUrlString(
                        mobile
                            ? "https://play.google.com/store/apps/details?id=com.zontreck.switchboard"
                            : "https://play.google.com/apps/testing/com.zontreck.switchboard",
                      );
                    },
                    child: Image.asset(
                      "webassets/playstore.png",
                      scale: mobile ? 2 : 1,
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      launchUrlString(
                        "https://testflight.apple.com/join/bktcYgFX",
                      );
                    },
                    child: Image.asset("webassets/applestore.png", width: 500),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    child: Image.asset("webassets/sbweb.png", width: 500),
                    onTap: () {
                      launchUrlString("https://app.systemswitchboard.com");
                    },
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    child: Image.asset("webassets/Discord.png", width: 500),
                    onTap: () {
                      launchUrlString("https://discord.gg/gtd9JAgYVM");
                    },
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      launchUrlString(
                        "https://ci.zontreck.com/job/Projects/job/Dart/job/Switchboard/job/master/lastSuccessfulBuild/artifact/Switchboard.dmg",
                      );
                    },
                    child: Image.asset("webassets/macos.png", width: 500),
                  ),
                  SizedBox(height: 200),
                  SBWebFeatRichPromo(
                    title: "Support Us",
                    body: Row(
                      children: [
                        SBOutlineButton(
                          onTap: () {
                            launchUrlString(
                              "https://patreon.com/AstaraStudios",
                            );
                          },
                          title: Text(
                            "Patreon",
                            style: const TextStyle(
                              fontFamily: "merriweather",
                              fontSize: 20,
                              color: Color(0xffc7bddf),
                            ),
                          ),
                        ),
                        SizedBox(width: 50),
                        SBOutlineButton(
                          onTap: () {
                            launchUrlString(
                              "https://patreon.com/AstaraStudios",
                            );
                          },
                          title: Text(
                            "Ko-Fi",
                            style: const TextStyle(
                              fontFamily: "merriweather",
                              fontSize: 20,
                              color: Color(0xffc7bddf),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 200),
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

class SBOutlineButton extends StatelessWidget {
  double roundedness = 1;
  double thickness = 1;
  void Function() onTap;
  Widget title;

  SBOutlineButton({
    super.key,
    required this.onTap,
    required this.title,
    this.thickness = 1,
    this.roundedness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: BoxBorder.all(width: thickness),
          borderRadius: BorderRadius.circular(roundedness),
        ),
        child: title,
      ),
    );
  }
}

abstract class FeatPromo extends StatelessWidget {
  String title;
  double? width = 500;
  double? height;
  @override
  final GlobalKey key = GlobalKey();

  FeatPromo({super.key, required this.title, this.width = 500, this.height});
}

class SBWebFeatPromo extends FeatPromo {
  String body;

  SBWebFeatPromo({
    super.key,
    required super.title,
    required this.body,
    super.width = 500,
    super.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: "ptsans",
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xffd68185),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              body,
              style: const TextStyle(
                fontFamily: "merriweather",
                fontSize: 20,
                color: Color(0xffc7bddf),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SBWebFeatRichPromo extends FeatPromo {
  Widget body;

  SBWebFeatRichPromo({
    super.key,
    required super.title,
    required this.body,
    super.width = 500,
    super.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xffd68185),
              ),
            ),
            SizedBox(height: 20),
            body,
          ],
        ),
      ),
    );
  }
}

List<Widget> getPromoFeatures(BuildContext ctx, bool isFeaturesPage) {
  return [
    SBWebFeatPromo(
      title: "Import From Octocon",
      body:
          "Switchboard can import all of your system info easily from your Octocon export! Just select 'Import from Octocon', select the export JSON file, and choose whether to erase any alters you might've already made in Switchboard, or keep them in addition to imported ones.",
      width: 500,
    ),
    SBWebFeatPromo(
      title: "Themes + Import/Export",
      body:
          "You can change the colours, font, and theme of the app, and even for each alter!\n\nImport a custom font, like a specific dyslexia font for example (including per alter). You can also import/export themes like templates!\nAdjust what alter boxes look like (square or rounded edges, flush pictures), and the colour an alter glows when fronting (customize or choose from presets!).",
    ),
    SBWebFeatRichPromo(
      title: "Open Source",
      body: Column(
        children: [
          MarkdownBlock(
            data:
                "Switchboard is open-source, and licensed under the GPL.\n\n[View Source Code](https://git.zontreck.com/Astara/Switchboard)",
            config: MarkdownConfig(
              configs: [
                PConfig(
                  textStyle: TextStyle(
                    fontFamily: "merriweather",
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          if (!isFeaturesPage)
            SBOutlineButton(
              onTap: () {
                Navigator.pushNamed(ctx, "/features");
              },
              roundedness: 20,
              thickness: 3,
              title: Text("Learn more"),
            ),
        ],
      ),
    ),
    SBWebFeatPromo(
      title: "Android, iOS, & Web App",
      body:
          "Switchboard can be downloaded from the Play Store, App Store, or used via it's web app!\n\n(The app is also available for Mac, Windows, & Linux!)",
    ),
    SBWebFeatPromo(
      title: "No Alter Limit || Designed for Large and Small Systems",
      body:
          "Switchboard won't limit how many alters you can have, even in incredibly large polyfragmented systems.",
    ),
    SBWebFeatPromo(
      title: "Custom Fields",
      body:
          "Add custom fields, including with markdown! Field types can be plain text, markdown text, colours, numbers, or dates! More types will be added in the future.",
    ),
    SBWebFeatPromo(
      title: "Add & Track Alters + Front History",
      body:
          "Add alters, names, import profile pictures (automatically generates copy-able permalink too), add descriptions with text markdown, alter colour, and more! Track who's fronting and view front history.",
    ),
    SBWebFeatPromo(
      title: "Never Shutting Down",
      body:
          "Switchboard is a passion project, run on our own home server. We decided to make it because we ourselves need it so direly. Even if much of it's development takes some time, it's never getting shut down.",
    ),
  ];
}
