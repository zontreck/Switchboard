import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:switchboard/pages/website/home.dart';
import 'package:switchboard/pages/website/sbsidebar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SBWebFeatures extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _sbfeatures();
  }
}

class _sbfeatures extends State<SBWebFeatures> {
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
    final promo = getPromoFeatures(context, true);
    final futureFeats = getFutureFeatures(context);

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
              "Features",
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 65,
                color: Color(0xffa2c4c9),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),

            ...promo.map(
              (feat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    final ctx = feat.key.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    (feat as FeatPromo).title,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 50),
            Text(
              "Future:",
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 32,
                color: Color(0xffa2c4c9),
                fontWeight: FontWeight.bold,
              ),
            ),

            ...futureFeats.map(
              (feat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    final ctx = feat.key.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    feat.title,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 150),
            Container(
              width: width,
              decoration: BoxDecoration(color: Color(0xff1b1642)),
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Text(
                    "Features at Launch",
                    style: TextStyle(
                      fontFamily: "ptsans",
                      fontSize: 32,
                      color: Color(0xffa2c4c9),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 75, // Horizontal spacing
                      runSpacing: 50, // Vertical spacing
                      children: promo,
                    ),
                  ),
                  SizedBox(height: 100),
                  Text(
                    "Features We Would Like To Add In The Future",
                    style: TextStyle(
                      fontFamily: "ptsans",
                      fontSize: 32,
                      color: Color(0xffa2c4c9),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 75, // Horizontal spacing
                      runSpacing: 50, // Vertical spacing
                      children: futureFeats,
                    ),
                  ),
                  SizedBox(height: 150),
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

List<FeatPromo> getFutureFeatures(BuildContext context) {
  return [
    SBWebFeatPromo(
      title: "Images In Markdown",
      body:
          "Import displayable images into descriptions or custom markdown fields! This will allow for the aesthetic and theming customization some apps have had before. Including images in themes' import/export!",
    ),
    SBWebFeatPromo(
      title: "Friend & Therapist View + Privacy Buckets",
      body:
          "Add friends (systems or singlets), as well as add people with therapist-mode accounts, who can view your system info! This will eventually have privacy-buckets too. You'll also be able to toggle which friends you want front-change notifications from.",
    ),
    SBWebFeatPromo(
      title: "Tags/Folders",
      body:
          "Add alters to different folders & sub-folders, with share-able descriptions.",
    ),
    SBWebFeatPromo(
      title: "Tiered Fronters",
      body:
          "Option to tier those added to front; Eg. \"Main Fronter\", \"Second closest\", \"Third closest\", etc.",
    ),
    SBWebFeatPromo(
      title: "Import From Other Alternatives + Export",
      body:
          "Import system info from other alternatives like SimplyPlural, PluralKit, TupperBox, etc.\n\nPossibly features to export back to some of them too, or maybe even sync, if this feature is wanted and we get enough support.",
    ),
    SBWebFeatPromo(
      title: "All Features From Octocon & SimplyPlural",
      body:
          "We know many systems pick one app or another due to which ones have features another might not, especially when it sometimes makes or breaks accessability. Even if it takes us some time, we're committed to having all the features of previous alternatives, and more.",
    ),
    SBWebFeatPromo(
      title: "Alter Image Boards",
      body:
          "A page under each alter you can add a few images, like having multiple faceclaims, for example!",
    ),
    SBWebFeatPromo(
      title: "Polls",
      body:
          "A feature providing in-system polls, that any alters can vote on, if they choose to.",
    ),
    SBWebFeatRichPromo(
      title: "User Requested Features",
      body: Column(
        children: [
          Text(
            "We're dedicated to doing our best to add as many features as possible requested by those using Switchboard! (Ko-Fi and Patreon suggestions will be prioritized; You can support Switchboard at Patreon or Ko-Fi",
            style: const TextStyle(
              fontFamily: "merriweather",
              fontSize: 20,
              color: Color(0xffc7bddf),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              SBOutlineButton(
                onTap: () {
                  launchUrlString("https://patreon.com/AstaraStudios");
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
                  launchUrlString("https://patreon.com/AstaraStudios");
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
        ],
      ),
    ),
  ];
}
