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

  @override
  void initState() {
    getAppSettings();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Switchboard")),
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
              onTap: () async {
                pageChanged();
                await Navigator.pushNamed(context, "/about");
                pageChanged();
              },
            ),
            ListTile(
              title: Text("S E T T I N G S"),
              subtitle: Text("Manage app settings"),
              leading: Icon(Icons.settings),
              onTap: () async {
                pageChanged();
                await Navigator.pushNamed(context, "/account/settings");
                pageChanged();
                setState(() {});
              },
            ),
            ListTile(
              title: Text("P R I V A C Y  P O L I C Y"),
              subtitle: Text("View the Privacy Policy"),
              leading: Icon(Icons.privacy_tip),
              onTap: () async {
                pageChanged();
                await Navigator.pushNamed(context, "/privacy");
                pageChanged();
              },
            ),
            ListTile(
              title: Text("T E R M S  O F  S E R V I C E"),
              subtitle: Text("View the Terms of Service"),
              leading: Icon(Icons.label_important),
              onTap: () async {
                pageChanged();
                await Navigator.pushNamed(context, "/tos");
                pageChanged();
              },
            ),
            ListTile(
              title: Text("P A T R E O N"),
              subtitle: Text("Open our Patreon in your browser"),
              leading: Icon(Icons.monetization_on),
              onTap: () async {
                launchUrlString("https://patreon.com/astaracreations");
              },
            ),
            ListTile(
              title: Text("F E E D B A C K"),
              subtitle: Text(
                "Feedback HUB. Submit requests, feedback, and bug reports.",
              ),
              leading: Icon(Icons.feedback),
              onTap: () async {
                pageChanged();
                await Navigator.pushNamed(context, "/feedback");
                pageChanged();
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
                        pageChanged();
                        var reply = await Navigator.pushNamed(
                          context,
                          "/editAlter",
                          arguments: EditAlterArguments(
                            alterId: alters[index].id,
                            instance: alters[index],
                          ),
                        );

                        pageChanged();
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
