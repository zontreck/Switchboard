import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';

class SecuritySettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _security();
  }
}

class _security extends State<SecuritySettings> {
  TextEditingController _nP1 = TextEditingController();
  TextEditingController _nP2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("Security Settings", style: TextStyle(fontSize: 22)),
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
              SizedBox(height: 25),
              Center(
                child: Text("Change Password", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      TextField(
                        obscureText: true,
                        controller: _nP1,
                        decoration: InputDecoration(
                          hintText: "New Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        obscureText: true,
                        controller: _nP2,
                        decoration: InputDecoration(
                          hintText: "Confirmation",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        title: Text("Submit New Password"),
                        subtitle: Text(
                          "Tap here to change your password, and submit the above form",
                        ),
                        leading: Icon(Icons.password),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        onTap: () async {
                          if (_nP1.text == _nP2.text) {
                            var reply = await NetworkInterface.updatePassword(
                              _nP1.text,
                            );
                            if (reply.success) {
                              // Session is invalidated. Inform the user
                              await showDialog(
                                context: context,
                                builder: (bldr) {
                                  return AlertDialog(
                                    title: Text("Session Invalidated"),
                                    content: Text(
                                      "Your session has been invalidated because your password was changed. You will need to sign in again.",
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Close"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              MemoryState.A.rememberMe = false;
                              MemoryState.A.authenticationToken = "";
                              MemoryState.A.password = "";
                              MemoryState.A.username = "";
                              MemoryState.A.currentUser.ID = UUID_ZERO;
                              await setAuthToken("");
                              await setAppSettings();

                              NetworkCaches.invalidate();

                              Phoenix.rebirth(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Password change failed. \nID: ${reply.id}\nReason: ${reply.reason}",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Divider(),
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
