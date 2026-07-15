import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';

class SettingsPageOld extends StatefulWidget {
  const SettingsPageOld({super.key});

  @override
  State<StatefulWidget> createState() {
    return _settings();
  }
}

class _settings extends State<SettingsPageOld> {
  MemoryState ms = MemoryState();
  Color tempColor = getAlterBackgroundColor();
  TextEditingController importThemeController = TextEditingController();
  bool importErrorHint = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("SETTINGS", style: TextStyle(fontSize: 22)),
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
              SizedBox(height: 8),

              SizedBox(height: 8),
              Divider(height: 25),

              SizedBox(height: 25),
              ListTile(
                title: Text("I M P O R T  A P P  T H E M E"),
                leading: Icon(Icons.install_mobile),
                subtitle: Text("Import a app theme, and apply it immediately!"),
                tileColor: const Color.fromARGB(255, 0, 148, 99),
                onTap: () async {
                  // Display a prompt to obtain the base64 encoded settings.
                  await showDialog(
                    context: context,
                    builder: (bldr) {
                      return AlertDialog(
                        title: Text("Paste Theme"),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              // Do apply theme
                              try {
                                String data = base64Encoder.base64Dec(
                                  importThemeController.text,
                                );
                                ms.fromJson(json.decode(data), theme: true);

                                setState(() {});

                                setAppSettings();
                                Navigator.pop(context);
                              } catch (E) {
                                importErrorHint = true;
                                setState(() {});
                              }
                            },
                            child: Text("Apply"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: Text("CANCEL"),
                          ),
                        ],
                        content: SizedBox(
                          height: 75,
                          child: Column(
                            children: [
                              TextField(
                                controller: importThemeController,
                                decoration: InputDecoration(
                                  hintText: "Base64 Encoded Theme",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 25),
              ListTile(
                title: Text("R E S E T  T O  D E F A U L T S"),
                leading: Icon(Icons.restore_from_trash),
                subtitle: Text("Reset all defaults for the app theme"),
                tileColor: const Color.fromARGB(255, 155, 80, 80),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (builder) {
                      return AlertDialog(
                        title: Text("Are you sure?"),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              ms.reset();
                              await clearApplicationFont();

                              setState(() {});

                              Navigator.pop(context);
                            },
                            child: Text("Confirm"),
                          ),
                        ],
                        content: Text(
                          "WARNING: This cannot be undone. All theme settings will be reset to defaults.",
                        ),
                        icon: Icon(Icons.warning),
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
