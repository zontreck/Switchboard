import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:switchboard/pages/website/home.dart';
import 'package:switchboard/pages/website/sbsidebar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SBWebSupportUs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _sbsupport();
  }
}

class _sbsupport extends State<SBWebSupportUs> {
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
          children: [
            SizedBox(height: 50),
            Text(
              "Help Support Us!",
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 64,
                color: Color(0xff76a5af),
              ),
            ),
            SizedBox(height: 50),
            Container(
              width: width,
              decoration: BoxDecoration(color: Color(0xff1b1642)),
              child: Column(
                children: [
                  SizedBox(height: 50),
                  SBWebFeatRichPromo(
                    title: "Why Support Development?",
                    body: Column(
                      children: [
                        Text(
                          "Currently we're only a team of two (well, two systems, that is!); One developer does all the coding, and another person works on the app's website, logo, and other visual design things (slowly learning to code too, though that takes time). We're also both disabled.\n\nWe do our best to work on the app's development as much as we're able to, but we also have work, and other life issues that take up our time. Until/unless we can make a living with this app, we have to spend most our time making enough to get by.\n\nEventually if we're able, we'd like to hire at least 1-2 people to help work on the app's development, once we have the money to do so.",
                          style: const TextStyle(
                            fontFamily: "merriweather",
                            fontSize: 20,
                            color: Color(0xffc7bddf),
                          ),
                        ),
                        SizedBox(height: 50),
                        Container(
                          color: Color(0xff45818e),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: "merriweather",
                                fontSize: 20,
                                color: Color(0xffd9e2e9),
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "TLDR: Until we make a living from this, we have to spend our time making a living. The more support we get, the more time we can spend on development.  ",
                                ),
                                TextSpan(
                                  text:
                                      "The more support we get, the more time we can spend on development.",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SBWebFeatPromo(
                    title: "How Can I/We Support Development?",
                    body:
                        "Currently there's two main ways! Watching optional, Non-Intrusive Ads, or via donations.",
                  ),
                  SBWebFeatRichPromo(
                    title: "Opt-In Only Ads",
                    body: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: "merriweather",
                          fontSize: 20,
                          color: Color(0xffd9e2e9),
                        ),
                        children: [
                          TextSpan(
                            text:
                                "One way you can support the app's development is by going into it's settings, and clicking on the section that says 'watch ads'. ",
                          ),
                          TextSpan(
                            text:
                                " This way ads will only show up if you choose to enable them, including a mode that only shows them within settings (or on a timer you set yourself). ",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              backgroundColor: Color(0xff45818e),
                            ),
                          ),
                          TextSpan(
                            text:
                                "We wanted to give users the option to support development, even if you can't donate to us directly. Thank you if you support us this way! It helps.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  SBWebFeatRichPromo(
                    title: "Patreon & Ko-Fi Donations",
                    body: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: "merriweather",
                          fontSize: 20,
                          color: Color(0xffd9e2e9),
                        ),
                        children: [
                          TextSpan(
                            text:
                                "Another way you can support development is by donating on Patreon or Ko-Fi. If you support us on Patreon, ",
                          ),
                          TextSpan(
                            text:
                                "you'll have priority when suggesting new features!",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              backgroundColor: Color(0xff45818e),
                            ),
                          ),
                          TextSpan(
                            text:
                                " Thank you if you support us this way! It helps greatly.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  SBOutlineButton(
                    onTap: () {
                      launchUrlString("https://patreon.com/AstaraStudios");
                    },
                    title: Text(
                      "Astara Studios Patreon",
                      style: TextStyle(
                        fontFamily: "merriweather",
                        fontSize: 24,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  SBOutlineButton(
                    onTap: () {
                      launchUrlString("https://ko-fi.com/zontreck");
                    },
                    title: Text(
                      "Zontreck's Ko-Fi",
                      style: TextStyle(
                        fontFamily: "merriweather",
                        fontSize: 24,
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                  SBWebFeatPromo(
                    title: "Share & Rate on Google Play / Apple App Store",
                    body:
                        "Lastly, you can also help support the app by sharing it with others, or posting online about it! \nWe're always going to be trying to improve Switchboard, its features, and accessibility, so feel free to give us feedback as well, whether online or via review on the App Store or Google Play.",
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
