import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';

class AccountSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _acct();
  }
}

class _acct extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("Account", style: TextStyle(fontSize: 22)),
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
              Center(
                child: Text("Third Party Apps", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Supported Third Parties:\n* Octocon (Fully)\n* PluralKit (Partial)\n* Ourcana (Partial)",
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Import JSON"),
                      subtitle: Text("Import a JSON export from a third party"),
                      leading: Icon(Icons.import_contacts),
                      trailing: Icon(Icons.forward),
                      onTap: () async {
                        pageChanged();

                        await Navigator.pushNamed(context, "/settings/3pjson");
                        pageChanged();

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Text("DANGER", style: TextStyle(fontSize: 22, color: Colors.red)),
              Divider(),
              Card(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text("Wipe Account"),
                        tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        subtitle: Text(
                          "This option will erase, but not delete, your account. All custom data will be destroyed.\nNOTE: Friends will not be erased.",
                        ),
                        leading: Icon(Icons.delete),
                        onTap: () async {
                          var reply = await showCupertinoDialog(
                            context: context,
                            builder: (bldr) {
                              return CupertinoAlertDialog(
                                title: Text("Wipe Account?"),
                                content: Text(
                                  "Are you absolutely sure? This action cannot be undone. It is permanent and irreversible. No one on the team will be able to help you undo this if something goes wrong without an exported copy of your data.",
                                  style: TextStyle(fontSize: 18),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    child: Text("Cancel!"),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: Text("Yes"),
                                    onPressed: () async {
                                      var reply =
                                          await NetworkInterface.wipeAccount();
                                      if (reply.success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Your request succeeded. Account Erased!",
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Your request failed. Account was not erased.\nID: ${reply.id}\nReason: ${reply.reason}",
                                            ),
                                          ),
                                        );
                                      }

                                      setState(() {});
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
              Text("Session", style: TextStyle(fontSize: 22)),
              Divider(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text("Log Out"),
                        tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                        leading: Icon(Icons.logout),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        subtitle: Text(
                          "Immediately ends your Switchboard Session and logs you out of your account.",
                        ),
                        onTap: () async {
                          var reply = await showCupertinoDialog(
                            context: context,
                            builder: (bldr) {
                              return CupertinoAlertDialog(
                                title: Text("Log Out?"),
                                content: Text(
                                  "Remember Me, if enabled will be turned off, and you will be logged out.",
                                  style: TextStyle(fontSize: 18),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    child: Text("Yes"),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (reply != null) {
                            MemoryState ms = MemoryState();
                            ms.rememberMe = false;
                            ms.username = "";
                            ms.password = "";
                            ms.authenticationToken = "";

                            await setAuthToken("");
                            await setAppSettings();

                            Navigator.pushReplacementNamed(
                              context,
                              "/onboarding/0",
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
