import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';

class FirstRunPage extends StatefulWidget {
  const FirstRunPage({super.key});

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
    // This is page 0
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
                    "# Welcome\n\n(This page can be scrolled!)\nThis is the Switchboard App. I want you to know that this application is a passion and hobby project at the moment. Both me and my partner needed an app that worked and would never go away. So, I created this, and decided to open source, and share it with the world.\n\n# Financial\n\nWe are both disabled, and this project is part of our little startup company. We hope to be able to hire a few good employees, make some games, make more accessibility apps, and just do what we love, when we are physically or mentally able.\n\n# Ads or No Ads\n\nIf you want, you can permanently disable ads in the settings for the app, or turn them back on at any given time. You will have full control over the frequency at which ads get displayed. By default, this is every 4 page navigations. Video ads can be triggered manually at will from the Ads settings page.\n\n## Patreon\n\nIf you opt out of ads, and are able, please donate to Patreon or to Ko-fi. It genuinely helps a lot, and if you support us for longer than a month, we will add your name to the app's credits/about screen. Additionally, you will get priority access to the Feedback HUB, where you can communicate directly with the developer and have your ideas, or bug reports seen before anybody else's.\n\n# Why this matters to us\n\nMaking a survivable income allows us to continue development of the app. Providing support means we can make this into a full time job, not just a hobby.",
              ),
              SizedBox(height: 25),
              Divider(),
              SizedBox(height: 25),
              ListTile(
                title: Text("Would you like to enable ads?"),
                subtitle: Text(
                  "We can't just do banner ads, as they mess with the app too much. Video ads are the default, and you can turn it off later, or change the frequency of the ads.",
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
                            onPressed: () async {
                              // enable ads
                              setAdsSupport(true);
                              await getAppSettings();
                              MemoryState.A.adSettings.onNavigate = true;
                              setAppSettings();

                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                context,
                                "/onboarding/1",
                              );
                            },
                          ),
                          CupertinoButton(
                            child: Text("No"),
                            onPressed: () async {
                              setAdsSupport(false);
                              await getAppSettings();
                              MemoryState.A.adSettings.onNavigate = false;
                              setAppSettings();

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

class OnboardingTermsOfServicePage extends StatefulWidget {
  const OnboardingTermsOfServicePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _tosPage();
  }
}

class _tosPage extends State<OnboardingTermsOfServicePage> {
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: Policies.tos(),
              builder: (bldr, snap) {
                if (!snap.hasData) {
                  return CircularProgressIndicator();
                } else {
                  return Expanded(child: MarkdownWidget(data: snap.data!));
                }
              },
            ),

            Divider(),
            Text(
              "To use the official servers, you must accept the privacy policy and the terms of service.",
              style: TextStyle(fontSize: 22),
            ),
            ListTile(
              title: Text("A C C E P T"),
              tileColor: const Color.fromARGB(255, 0, 103, 3),
              onTap: () async {
                await updateOnboardingPhase(2);
                Navigator.pushReplacementNamed(context, "/onboarding/2");
              },
            ),
            Divider(),
            ListTile(
              title: Text("D E C L I N E"),
              tileColor: const Color.fromARGB(255, 103, 0, 0),
              onTap: () async {
                await updateOnboardingPhase(0);
                exit(0);
              },
            ),
            SizedBox.fromSize(size: Size.fromHeight(50)),
          ],
        ),
      ),
    );
  }
}

class OnboardingPrivacyPolicyPage extends StatelessWidget {
  const OnboardingPrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard > Onboarding"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("PRIVACY POLICY", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            SizedBox(height: 25),
            FutureBuilder(
              future: Policies.privacyPolicy(),
              builder: (BCTX, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Expanded(child: MarkdownWidget(data: snapshot.data!));
                }
              },
            ),
            Divider(),
            Text(
              "To use the official server, you must agree to the Terms of Service and our Privacy Policy.",
              style: TextStyle(fontSize: 22),
            ),
            ListTile(
              title: Text("A C C E P T"),
              tileColor: Color.fromARGB(255, 0, 105, 0),
              onTap: () async {
                await updateOnboardingPhase(-1);
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
            Divider(),
            ListTile(
              title: Text("D E C L I N E"),
              tileColor: Color.fromARGB(255, 105, 0, 0),
              onTap: () async {
                await updateOnboardingPhase(0);
                exit(0);
              },
            ),
            SizedBox.fromSize(size: Size.fromHeight(50)),
          ],
        ),
      ),
    );
  }
}
