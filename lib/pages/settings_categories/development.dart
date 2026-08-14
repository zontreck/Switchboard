import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:libacflutter/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchboard/dart/sbproj.dart';
import 'package:switchboard/dart/storage.dart';

class DevelopmentSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _devSettings();
  }
}

class _devSettings extends State<DevelopmentSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("Developer Settings", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("Debugging", style: TextStyle(fontSize: 20))),
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Clear All App Data"),
                        subtitle: Text(
                          "Erase all app data. Immediately log out, go back to onboarding.",
                        ),
                        leading: Icon(Icons.clear),
                        tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        onTap: () async {
                          await showCupertinoDialog(
                            context: context,
                            builder: (bldr) {
                              return CupertinoAlertDialog(
                                title: Text("Are you sure?"),
                                content: Text(
                                  "This action will erase all settings.\n*NOTE*: Data stored on the server is not deleted by this action.",
                                  style: TextStyle(fontSize: 22),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text("Yes"),
                                    isDefaultAction: false,
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.clear();
                                      Navigator.pop(context);
                                      NetworkCaches.invalidate();

                                      Phoenix.rebirth(context);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text("Cancel"),
                                    isDefaultAction: true,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: Text(
                  "Channel / API Server",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Production"),
                        subtitle: Text("${SBProject.isProduction}"),
                      ),
                      ListTile(
                        title: Text("Can use test database?"),
                        subtitle: Text("${(SBProject.BRANCH == 'develop')}"),
                      ),
                      ListTile(
                        title: Text("Code Branch"),
                        subtitle: Text("${SBProject.BRANCH}"),
                      ),
                      Divider(),
                      Text(
                        "NOTE: If the above text indicates you are *NOT* running a version of the app eligible to use the test database, you are limited to only using the Official server, or a self-hosted one.",
                      ),
                      Divider(),
                      Center(
                        child: Text(
                          "Official Server",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      CheckboxListTile(
                        value: false,
                        onChanged: (B) async {},
                        title: Text("Production Server"),
                        subtitle: Text(
                          "The main database, runs off the stable codebase, and is never reset.",
                        ),
                      ),
                      SizedBox(height: 25),
                      CheckboxListTile(
                        value: false,
                        enabled: SBProject.BRANCH == 'develop',
                        onChanged: (B) async {},
                        title: Text("Test Server"),
                        subtitle: Text(
                          "Testing Server that runs off of unstable code. This database will mirror the production database. It resets testing changes every 2 hours.",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
