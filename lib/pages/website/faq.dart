import 'package:flutter/material.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';
import 'package:switchboard/pages/website/home.dart';
import 'package:switchboard/pages/website/sbsidebar.dart';

class SBWebFAQ extends StatefulWidget {
  const SBWebFAQ({super.key});

  @override
  State<StatefulWidget> createState() {
    return _sbfaq();
  }
}

class _sbfaq extends State<SBWebFAQ> {
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

    List<FeatPromo> faqEntries = [
      SBWebFeatRichPromo(
        title: "How do I change who is fronting?",
        body: Column(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: "merriweather",
                  fontSize: 20,
                  color: Color(0xffc7bddf),
                ),
                children: [
                  TextSpan(text: "Swipe on an alter from"),
                  TextSpan(
                    text: " right-to-left to",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                    ),
                  ),
                  TextSpan(
                    text: " add ",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(text: "front, and "),
                  TextSpan(
                    text: "swipe from left-to-right to",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                    ),
                  ),
                  TextSpan(
                    text: " remove ",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text:
                        "from front.\n\nYou can view who's currently fronting in the Fronting tab, as well as being able to tell by which alters have a",
                  ),
                  TextSpan(
                    text: " glowing light ",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(text: "around them."),
                ],
              ),
            ),
            SizedBox(height: 20),
            AlterWidget(
              alterID: UUID_ZERO,
              alterName: "Sample Alter",
              url: "https://api.systemswitchboard.com/avatar/nul",
              withFronterElement: false,
              frontID: UUID_ZERO,
              frontEndTime: 0,
              frontStartTime: 1,
            ),
          ],
        ),
      ),
      SBWebFeatRichPromo(
        title: "How Do I Import From Octocon?",
        body: Column(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: "merriweather",
                  fontSize: 20,
                  color: Color(0xffc7bddf),
                ),
                children: [
                  TextSpan(
                    text:
                        "Firstly, you'll have needed to export your system via Octocon's export command. In Discord, type ",
                  ),
                  TextSpan(
                    text: "/export ",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: "and click on Octo's option for exporting a "),
                  TextSpan(
                    text: "Full JSON.",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        "\n\nOnce you do this, the Octocon bot will send you a direct message with your export file. Download it, and save it somewhere you can easily find again.\n\nEither when you first start the app, or from in its settings, Switchboard will give you the option to Import from Octocon. You can do so via two options:",
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: Column(
                children: [
                  Text(
                    "1. Complete Wipe",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontFamily: "merriweather",
                      fontSize: 20,
                      color: Color(0xffc7bddf),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Warning: This will permanently delete any alters and info in Switchboard that are not included in the Octocon export file.",
                    style: TextStyle(
                      fontFamily: "ptsans",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffd68185),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "This option will erase any pre-existing alters from Switchboard if you've made any, before then importing everything from an Octocon JSON. This is only reccomended for if you might've downloaded Switchboard to try it out first, and then want to import the same alters from Octocon, without duplicates.",
                    style: TextStyle(
                      fontFamily: "merriweather",
                      fontSize: 18,
                      color: Color(0xffc7bddf),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "2. Import As-Is",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      backgroundColor: Color(0xff45818e),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontFamily: "merriweather",
                      fontSize: 20,
                      color: Color(0xffc7bddf),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "This option is for you if you want to combine whatever alters and info you currently have in Switchboard, with alters and info from an Octocon export file. It will essentially merge the Octocon and Switchboard data, including front history. It will not erase anything, only add.",
                    style: TextStyle(
                      fontFamily: "merriweather",
                      fontSize: 18,
                      color: Color(0xffc7bddf),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: "merriweather",
                  fontSize: 20,
                  color: Color(0xffc7bddf),
                ),
                children: [
                  TextSpan(
                    text:
                        "Once you have your Octocon export file, and you've decided which import option you'd like to use, click ",
                  ),
                  TextSpan(
                    text: "Select File",
                    style: TextStyle(
                      backgroundColor: Color(0xff45818e),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ", and "),
                  TextSpan(
                    text: "click on your Octocon export",
                    style: TextStyle(
                      backgroundColor: Color(0xff45818e),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " from earlier. "),
                  TextSpan(
                    text: "Then, click the import option of your choosing.",
                    style: TextStyle(
                      backgroundColor: Color(0xff45818e),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text(
              "Once you do this, Switchboard will begin migrating all your Octocon data. This will likely take some time due to Octocon's rate-limit on their servers, since that's how we import your profile picture images.",
              style: const TextStyle(
                fontFamily: "merriweather",
                fontSize: 20,
                color: Color(0xffc7bddf),
              ),
            ),
            SizedBox(height: 50),
            Text(
              "Note: Importing profile picture images will only work before Octocon shuts down. After this, you can still import alters and info, but we will be unable to import the profile pictures for you; You will have to import each of them manually.",
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xffd68185),
              ),
            ),
          ],
        ),
      ),
      SBWebFeatPromo(
        title: "How Can I Provide Feedback / Bug Reports?",
        body:
            "You can do so via the feedback section in the app (from the left sidebar), or by suggesting on Patreon/Ko-Fi if you support us there (as those suggestions will be prioritized).\n\n\n(zontreck here) Hi! You can easily submit bug reports in multiple ways. \n\n1. As my partner said, the Feedback HUB in the app is the best place.\n\n2. Patreon and Ko-Fi\n\n3. Our git server! The source code repository has a issue tracker. The ticket visibility is nowhere near as nice as Feedback HUB though.\n\n4. Discord. I would prefer the discord server not get turned into a bug reporting location, but it is an option if nothing else works.",
      ),
    ];

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
            SizedBox(height: 100),
            Text(
              "Frequently Asked Questions\n& App Tutorials",
              style: TextStyle(
                fontFamily: "ptsans",
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xffa2c4c9),
              ),
            ),
            SizedBox(height: 100),
            ...faqEntries.map(
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
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 620),
            Container(
              width: width,
              decoration: BoxDecoration(color: Color(0xff1b1642)),
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 75, // Horizontal spacing
                      runSpacing: 50, // Vertical spacing
                      children: faqEntries,
                    ),
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
