import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/pages/elements.dart';

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
            arguments: EditAlterArguments(alterId: newAlter.data!.id),
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: NetworkInterface.requestAltersList(null),
          builder: (bldr, AsyncSnapshot<S2CAltersResponse> snapshot) {
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
              List<Alter> alters = snapshot.data!.alters;
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
                        ),
                      );
                    },
                    child: AlterWidget(
                      flush: ms.flushPictures,
                      roundedElement: ms.roundedBorder,
                      squarePics: ms.squarePicture,
                      backgroundColor: getAlterBackgroundColor(),
                      textColor: getAlterTextColor(),
                      alterID: alters[index].id,
                      alterName: alters[index].name,
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
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
