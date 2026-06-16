import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/pages/elements.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccountPage();
  }
}

class _AccountPage extends State<AccountPage> {
  int _index = 0;
  MemoryState ms = MemoryState();
  BannerAd? _bannerAd;
  double adHeight = 0;

  Widget getPageForIndex() {
    switch (_index) {
      case 0:
        {
          return AltersPage();
        }
      case 1:
        {
          return FrontingPage();
        }
      case 2:
        {
          return FrontHistoryPage();
        }
    }

    return AltersPage();
  }

  Widget? getActionButton() {
    if (_index == 0) {
      return ElevatedButton.icon(
        onPressed: () async {
          // Add new alter!
          // Make a new alter and immediately open the editor.
          var newAlter = await NetworkInterface.makeNewAlter("New Alter");
          setState(() {});

          var reply = await Navigator.pushNamed(
            context,
            "/editAlter",
            arguments: EditAlterArguments(
              alterId: newAlter.data!.id,
              instance: newAlter.data!,
            ),
          );
        },
        label: Text("Alter"),
        icon: Icon(Icons.add),
      );
    }

    return null;
  }

  Future<BannerAd?> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );

    if (size == null) {
      // Unable to get width of anchored banner.
      _bannerAd = null;
      return null;
    }

    bool optIn = (await getAdsOptIn())!;
    if (!optIn) {
      _bannerAd = null;
      throw Exception("Opt Out");
    }

    if (_bannerAd != null) return _bannerAd;

    var b = BannerAd(
      adUnitId: "ca-app-pub-3401801111605896/3640268235",
      request: const AdRequest(nonPersonalizedAds: true),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Called when an ad is successfully received.
          debugPrint("Ad was loaded.");
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          // Called when an ad request failed.
          debugPrint("Ad failed to load with error: $err");
          ad.dispose();
        },
      ),
    );
    await b.load();
    return b;
  }

  @override
  void didChangeDependencies() {
    updateAdHeight();

    super.didChangeDependencies();
  }

  Future<void> updateAdHeight() async {
    double adHeight = await getAdHeight();
    this.adHeight = adHeight;

    setState(() {});
  }

  @override
  void initState() {
    getAppSettings();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(adHeight),
          child: FutureBuilder(
            future: _loadAd(),
            builder: (bldr, snap) {
              updateAdHeight();
              if (snap.hasError) {
                return SizedBox();
              }
              if (!snap.hasData) {
                return CircularProgressIndicator();
              } else {
                if (snap.data == null) {
                  return SizedBox();
                } else {
                  return Expanded(child: AdWidget(ad: snap.data!));
                }
              }
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Text("Switchboard"),
                  FutureBuilder(
                    future: SwitchboardConsts.getPackageVersion(),
                    builder: (BTX, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text("Version v${snapshot.data}");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("A B O U T"),
              leading: Icon(Icons.info_rounded),
              onTap: () {
                Navigator.pushNamed(context, "/about");
              },
            ),
            ListTile(
              title: Text("S E T T I N G S"),
              subtitle: Text("Manage app settings"),
              leading: Icon(Icons.settings),
              onTap: () async {
                await Navigator.pushNamed(context, "/account/settings");
                setState(() {});
              },
            ),
            ListTile(
              title: Text("P R I V A C Y  P O L I C Y"),
              subtitle: Text("View the Privacy Policy"),
              leading: Icon(Icons.privacy_tip),
              onTap: () {
                Navigator.pushNamed(context, "/privacy");
              },
            ),
            ListTile(
              title: Text("T E R M S  O F  S E R V I C E"),
              subtitle: Text("View the Terms of Service"),
              leading: Icon(Icons.label_important),
              onTap: () {
                Navigator.pushNamed(context, "/tos");
              },
            ),
            ListTile(
              title: Text("P A T R E O N"),
              subtitle: Text("Open our Patreon in your browser"),
              leading: Icon(Icons.monetization_on),
              onTap: () {
                launchUrlString("https://patreon.com/astaracreations");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: getActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Alters",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2),
            label: "Fronting",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
        onTap: (value) async {
          _index = value;
          setState(() {});
        },
        selectedItemColor: getNavSelColor(),
        unselectedItemColor: getNavUnselColor(),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(),
            Expanded(child: getPageForIndex()),
          ],
        ),
      ),
    );
  }
}

class AltersPage extends StatefulWidget {
  const AltersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _alters();
  }
}

class _alters extends State<AltersPage> {
  List<Alter>? altersList;

  Future<void> markListDirty() async {
    altersList = null;
  }

  Future<List<Alter>> pollList() async {
    if (altersList != null) return altersList!;
    altersList = [];
    altersList = (await NetworkInterface.requestAltersList(null)).alters;

    return altersList!;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(Duration(seconds: 1), () {
          altersList = null;
          setState(() {});
        });
      },
      child: Column(
        children: [
          FutureBuilder(
            future: pollList(),
            builder: (bldr, AsyncSnapshot<List<Alter>> snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Icon(Icons.error, size: 120),
                    Text(
                      "FATAL ERROR: Could not load alters from the server.\nRequest ID: ${MemoryState.A.lastErrorRay}",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                );
              }

              if (!snapshot.hasData) {
                return Column(
                  children: [
                    CircularProgressIndicator(),
                    Center(
                      child: Text(
                        "Loading Alters from Server...",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                );
              } else {
                List<Alter> alters = snapshot.data!;
                MemoryState ms = MemoryState();

                return ListView.builder(
                  itemCount: alters.length,
                  shrinkWrap: true,
                  itemBuilder: (bctx, index) {
                    return InkWell(
                      onTap: () async {
                        var reply = await Navigator.pushNamed(
                          context,
                          "/editAlter",
                          arguments: EditAlterArguments(
                            alterId: alters[index].id,
                            instance: alters[index],
                          ),
                        );

                        setState(() {
                          altersList = null;
                        });
                      },
                      child: AlterWidget(
                        flush: ms.flushPictures,
                        roundedElement: ms.roundedBorder,
                        squarePics: ms.squarePicture,
                        backgroundColor: getAlterBackgroundColor(),
                        textColor: getAlterTextColor(),
                        alterID: alters[index].id,
                        alterName: alters[index].name,
                        url: alters[index].avatarUrl.isNotEmpty
                            ? alters[index].avatarUrl
                            : "null",
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class FrontingPage extends StatefulWidget {
  const FrontingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _fronting();
  }
}

class _fronting extends State<FrontingPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FrontHistoryPage extends StatefulWidget {
  const FrontHistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _history();
  }
}

class _history extends State<FrontHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
