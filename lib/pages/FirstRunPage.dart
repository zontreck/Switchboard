import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:switchboard/globalHelpers.dart';

class FirstRunPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _firstRun();
  }
}

class _firstRun extends State<FirstRunPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _runChecks();
  }

  Future<void> _runChecks() async {
    bool? hasSeenPage = await getAdsOptIn();
    int phase = await getOnboardingPhase();

    if (phase == -1) {
      Navigator.pushReplacementNamed(context, "/login");
    }

    if (phase == 1) {
      Navigator.pushReplacementNamed(context, "/onboarding/1");
    }

    if (phase == 2) {
      Navigator.pushReplacementNamed(context, "/onboarding/2");
    }

    if (hasSeenPage != null) {
      Navigator.pushReplacementNamed(context, "/onboarding/1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard > Onboarding"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("FIRST RUN", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MarkdownBlock(
                data:
                    "# Welcome\n\n(This page can be scrolled!)\nThis is the Switchboard App. I want you to know that this application is a passion and hobby project and the moment. Both me and my partner needed an app that worked and would never go away. So, I created this, and decided to open source, and share it with the world.\n\n# Financial\n\nThe difficult truth is that we are both disabled. So, any support you can give us means a lot. I believe in choices, so I will present you with some choices in a moment. I just wanted to get the explanation out of the way first.\n\n# Your Choice\n\n## Ads or No Ads\n\nIf you want, you can permanently disable ads in the settings for the app, or turn them back on at any given time. My pledge to you, is that the only ads you will ever see when this is turned on, are the banner ads at the top of the screen, or the bottom of the screen. Video ads can be triggered manually at will from the Ads settings page.\n\n## Patreon\n\nIf you opt out of ads, we ask only one thing. Please, donate to Patreon or to Ko-fi. It genuinely helps a lot, and if you support us for longer than a month, we will add your name to the app's credits/about screen.\n\n# Why this matters to us\n\nWe know most people will see a single ad and run, uninstall the app and find a new one. We also know that people who are able would just edit the open source code, remove the ads, and then install the app. \nI am offering you a choice. Whether to support us with ads, support us on another platform or method, or just not at all. You can use the app, no matter your choice.",
              ),
              SizedBox(height: 25),
              Divider(),
              SizedBox(height: 25),
              ListTile(
                title: Text("Would you like to enable ads?"),
                subtitle: Text(
                  "Ads will only be banner ads on the top or bottom of the screen, as non-invasive as we can make it.",
                ),
                leading: Icon(Icons.ads_click),
                tileColor: const Color.fromARGB(255, 0, 68, 123),
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (bldr) {
                      return CupertinoAlertDialog(
                        title: Text("Ads?"),
                        content: Text(
                          "Would you like to enable ads to support us? You can disable this later in settings.",
                        ),
                        actions: [
                          CupertinoButton(
                            child: Text("Yes"),
                            onPressed: () {
                              // enable ads
                              setAdsSupport(true);
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                context,
                                "/onboarding/1",
                              );
                            },
                          ),
                          CupertinoButton(
                            child: Text("No"),
                            onPressed: () {
                              setAdsSupport(false);
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                context,
                                "/onboarding/1",
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsOfServicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _tosPage();
  }
}

class _tosPage extends State<TermsOfServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard > Onboarding"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("TERMS OF SERVICE", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
