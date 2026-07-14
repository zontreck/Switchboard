import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
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
  bool listMode = true;
  MemoryState ms = MemoryState();
  TextEditingController searchBar = TextEditingController();

  Widget getPageForIndex() {
    switch (_index) {
      case 0:
        {
          return AltersPage(searchBar: searchBar);
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

    return AltersPage(searchBar: searchBar);
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
        label: Text("Alter", style: TextStyle(fontSize: 22)),
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
    if (ms.currentUser.ID == UUID_ZERO) {
      Timer(Duration(seconds: 5), () async {
        // Obtain the current user!
        var reply = await NetworkInterface.getUser(ms.username);
        if (reply.success) {
          ms.currentUser = reply.data!;
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        actions: [
          if (_index == 2)
            ElevatedButton.icon(
              onPressed: () {
                listMode = !listMode;
                setState(() {});
              },
              label: Text(listMode ? "Timeline View" : "List View"),
              icon: Icon(Icons.history),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              if (_index == 0)
                TextField(
                  controller: searchBar,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    hintText: "Search Alters...",
                  ),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                subtitle: Text("Manage switchboard settings"),
                leading: Icon(Icons.settings),
                onTap: () async {
                  pageChanged();
                  await Navigator.pushNamed(context, "/settings");
                  pageChanged();
                  setState(() {});
                },
              ),
              ListTile(
                title: Text("S E T T I N G S  -  O L D"),
                subtitle: Text("Manage app settings - OLD INTERFACE"),
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
                  launchUrlString("https://patreon.com/astarastudios");
                },
              ),
              ListTile(
                title: Text("K O - F I"),
                subtitle: Text("Open our Ko-Fi in your browser"),
                leading: Icon(Icons.monetization_on),
                onTap: () async {
                  launchUrlString("https://ko-fi.com/zontreck");
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
              ListTile(
                title: Text("S O U R C E  C O D E"),
                subtitle: Text("View our code! (And possibly contribute?)"),
                leading: Icon(Icons.code),
                onTap: () {
                  launchUrlString(
                    "https://git.zontreck.com/Astara/Switchboard",
                  );
                },
              ),
            ],
          ),
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
          mainAxisSize: MainAxisSize.min,
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
  final TextEditingController searchBar;
  const AltersPage({super.key, required this.searchBar});

  @override
  State<StatefulWidget> createState() {
    return _alters();
  }
}

class _alters extends State<AltersPage> {
  Future<List<Alter>> pollList() async {
    return (await NetworkInterface.requestAltersList(null)).alters;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(Duration(seconds: 1), () {
          NetworkCaches.invalidate();
          setState(() {});
        });
      },
      child: FutureBuilder(
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
            if (snapshot.hasError) {
              return SizedBox();
            }
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
              padding: EdgeInsets.all(8),
              itemBuilder: (bctx, index) {
                return FutureBuilder(
                  future: alters[index].isFronting(),
                  builder: (frontingBuilder, frontingSnapshot) {
                    if (!frontingSnapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      if (frontingSnapshot.hasError) {
                        print(
                          "Fronting snapshot threw an error: ${frontingSnapshot.error}",
                        );
                      }
                      // Run search test
                      if (widget.searchBar.text.isNotEmpty) {
                        if (!alters[index].name.toLowerCase().contains(
                          widget.searchBar.text.toLowerCase(),
                        )) {
                          return SizedBox();
                        }
                      }
                      Fronter fronting =
                          frontingSnapshot.data ??
                          Fronter(
                            id: UUID_ZERO,
                            front: Front(
                              alterId: alters[index].id,
                              start: 0,
                              end: 0,
                            ),
                          );
                      print(fronting.toJson());

                      return Column(
                        children: [
                          if (fronting.front.currentFronter)
                            SizedBox(height: 12),
                          FutureBuilder(
                            future: alters[index].getAlterColor(),
                            builder: (Bldr, Snapshot) {
                              Color backgroundColor = getAlterBackgroundColor();
                              if (Snapshot.hasData) {
                                if (Snapshot.data!.isNotEmpty) {
                                  backgroundColor = ColorFromList(
                                    Snapshot.data!,
                                  );
                                }
                              }
                              if (backgroundColor ==
                                  Color.fromARGB(0, 0, 0, 0)) {
                                backgroundColor = getAlterBackgroundColor();
                              }

                              return AlterWidget(
                                withFronterElement: true,
                                flush: ms.flushPictures,
                                roundedElement: ms.roundedBorder,
                                squarePics: ms.squarePicture,
                                longPressMenu: true,
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
                                  setState(() {});
                                },
                                longPressOptions: [
                                  if (!fronting.front.currentFronter)
                                    CupertinoButton(
                                      child: Text(
                                        "Set Front",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      onPressed: () async {
                                        await NetworkInterface.setFronting(
                                          alters[index].id,
                                        );
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                    ),
                                  if (fronting.front.currentFronter)
                                    CupertinoButton(
                                      child: Text(
                                        "Remove from front",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      onPressed: () async {
                                        await NetworkInterface.unfrontFronter(
                                          alters[index].id,
                                        );
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                    ),
                                  CupertinoButton(
                                    color: LibACFlutterConstants.TITLEBAR_COLOR,
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      var resp = await showDialog(
                                        context: context,
                                        builder: (bldr) {
                                          return confirmDeleteAlter(context);
                                        },
                                      );

                                      if (resp is bool) {
                                        if (resp == true) {
                                          await NetworkInterface.deleteAlter(
                                            alters[index].id,
                                          );
                                          setState(() {});
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Delete Alter",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                                backgroundColor: backgroundColor,
                                textColor: getReadableTextColor(
                                  backgroundColor,
                                  getAlterTextColor(),
                                ),
                                alterID: alters[index].id,
                                alterName: alters[index].name,
                                url: alters[index].avatarUrl.isNotEmpty
                                    ? alters[index].avatarUrl
                                    : "null",
                                frontID: fronting.id,
                                frontStartTime: fronting.front.start,
                                frontEndTime: fronting.front.end,

                                alter: alters[index],
                              );
                            },
                          ),

                          if (fronting.front.currentFronter)
                            SizedBox(height: 12),
                        ],
                      );
                    }
                  },
                );
              },
            );
          }
        },
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
    return FutureBuilder(
      future: NetworkInterface.getFronters(false),
      builder: (bldr, snap) {
        if (!snap.hasData) {
          return CircularProgressIndicator();
        }

        var response = snap.data!;
        return ListView.builder(
          itemBuilder: (itbldr, index) {
            return FutureBuilder(
              future: NetworkInterface.getAlterByID(
                response.data[index].front.alterId,
              ),
              builder: (alterBuilder, alterSnap) {
                if (!alterSnap.hasData) {
                  return CircularProgressIndicator();
                } else {
                  Alter alter = alterSnap.data!.data!;
                  MemoryState ms = MemoryState();
                  return FutureBuilder(
                    future: alter.getAlterColor(),
                    builder: (Bldr, Snapshot) {
                      Color backgroundColor = getAlterBackgroundColor();
                      if (Snapshot.hasData) {
                        if (Snapshot.data!.isNotEmpty) {
                          backgroundColor = ColorFromList(Snapshot.data!);
                        }
                      }
                      if (backgroundColor == Color.fromARGB(0, 0, 0, 0)) {
                        backgroundColor = getAlterBackgroundColor();
                      }

                      return AlterWidget(
                        withFronterElement: true,
                        flush: ms.flushPictures,
                        roundedElement: ms.roundedBorder,
                        squarePics: ms.squarePicture,
                        backgroundColor: backgroundColor,
                        textColor: getReadableTextColor(
                          backgroundColor,
                          getAlterTextColor(),
                        ),
                        alterID: alter.id,
                        longPressMenu: true,
                        onTap: () async {
                          pageChanged();
                          var reply = await Navigator.pushNamed(
                            context,
                            "/editAlter",
                            arguments: EditAlterArguments(
                              alterId: alter.id,
                              instance: alter,
                            ),
                          );

                          pageChanged();
                          setState(() {});
                        },
                        longPressOptions: [
                          if (!response.data[index].front.currentFronter)
                            CupertinoButton(
                              child: Text(
                                "Set Front",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () async {
                                await NetworkInterface.setFronting(alter.id);
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          if (response.data[index].front.currentFronter)
                            CupertinoButton(
                              child: Text(
                                "Remove from front",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () async {
                                await NetworkInterface.unfrontFronter(alter.id);
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          CupertinoButton(
                            color: LibACFlutterConstants.TITLEBAR_COLOR,
                            onPressed: () async {
                              Navigator.pop(context);

                              var resp = await showDialog(
                                context: context,
                                builder: (bldr) {
                                  return confirmDeleteAlter(context);
                                },
                              );

                              if (resp is bool) {
                                if (resp == true) {
                                  await NetworkInterface.deleteAlter(alter.id);
                                  setState(() {});
                                }
                              }
                            },
                            child: Text(
                              "Delete Alter",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        alterName: alter.name,
                        url: alter.avatarUrl.isNotEmpty
                            ? alter.avatarUrl
                            : "null",
                        frontID: response.data[index].id,
                        alter: alter,
                        showFrontingTime: true,
                        frontEndTime: response.data[index].front.end,
                        frontStartTime: response.data[index].front.start,
                      );
                    },
                  );
                }
              },
            );
          },
          itemCount: response.data.length,
        );
      },
    );
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
    return FutureBuilder(
      future: NetworkInterface.getFronters(true),
      builder: (bldr, snap) {
        if (!snap.hasData) {
          return CircularProgressIndicator();
        }

        var response = snap.data!;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (itbldr, index) {
                  return FutureBuilder(
                    future: NetworkInterface.getAlterByID(
                      response.data[index].front.alterId,
                    ),
                    builder: (alterBuilder, alterSnap) {
                      if (!alterSnap.hasData) {
                        return CircularProgressIndicator();
                      } else {
                        Alter alter = alterSnap.data!.data!;
                        MemoryState ms = MemoryState();
                        return FutureBuilder(
                          future: alter.getAlterColor(),
                          builder: (Bldr, Snapshot) {
                            Color backgroundColor = getAlterBackgroundColor();
                            if (Snapshot.hasData) {
                              if (Snapshot.data!.isNotEmpty) {
                                backgroundColor = ColorFromList(Snapshot.data!);
                              }
                            }
                            if (backgroundColor == Color.fromARGB(0, 0, 0, 0)) {
                              backgroundColor = getAlterBackgroundColor();
                            }

                            return Column(
                              children: [
                                AlterWidget(
                                  withFronterElement: false,
                                  flush: ms.flushPictures,
                                  roundedElement: ms.roundedBorder,
                                  squarePics: ms.squarePicture,
                                  backgroundColor: backgroundColor,
                                  onTap: () {},
                                  textColor: getReadableTextColor(
                                    backgroundColor,
                                    getAlterTextColor(),
                                  ),
                                  alterID: alter.id,
                                  alterName: alter.name,
                                  url: alter.avatarUrl.isNotEmpty
                                      ? alter.avatarUrl
                                      : "null",
                                  frontID: response.data[index].id,
                                  alter: alter,
                                  showFrontingTime: true,
                                  frontEndTime: response.data[index].front.end,
                                  frontStartTime:
                                      response.data[index].front.start,
                                ),
                                SizedBox(height: 5),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                },
                itemCount: response.data.length,
              ),
            ],
          ),
        );
      },
    );
  }
}
