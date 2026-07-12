import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:libacflutter/Constants.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';
import 'package:switchboard/sb.dart';

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
              AlterWidget(
                flush: ms.flushPictures,
                withFronterElement: false,
                onTap: () {},
                frontStartTime: 0,
                frontEndTime: 0,
                frontID: UUID_ZERO,
                roundedElement: ms.roundedBorder,
                squarePics: ms.squarePicture,
                backgroundColor: getAlterBackgroundColor(),
                textColor: getAlterTextColor(),
                alterID: UUID_ZERO,
                alterName: "Sample Alter",
                url: "null",
                alter: null,
              ),
              FutureBuilder(
                future: getAdsOptIn(),
                builder: (bldr, snap) {
                  if (!snap.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    return CheckboxListTile(
                      value: snap.data!,
                      title: Text("Enable Ads"),
                      subtitle: Text(
                        "Whether or not to support the development of the app via Ads",
                      ),
                      onChanged: (B) async {
                        await setAdsSupport(B ?? false);

                        setState(() {});
                      },
                    );
                  }
                },
              ),

              Row(
                children: [
                  Checkbox(
                    value: ms.flushPictures,
                    onChanged: (B) {
                      ms.flushPictures = B ?? true;
                      setAppSettings().then((V) {
                        setState(() {});
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text("Flush Pictures", style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: ms.squarePicture,
                    onChanged: (B) {
                      if (ms.flushPictures) return;
                      ms.squarePicture = B ?? true;
                      setAppSettings().then((V) {
                        setState(() {});
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text("Square Pictures", style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: ms.roundedBorder,
                    onChanged: (B) {
                      ms.roundedBorder = B ?? true;
                      setAppSettings().then((V) {
                        setState(() {});
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text("Rounded Borders", style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: ms.disableGlowAnimations,
                    onChanged: (B) {
                      ms.disableGlowAnimations = B ?? true;
                      setAppSettings().then((V) {
                        setState(() {});
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Disable glow animations",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  tempColor = getAlterBackgroundColor();

                  setState(() {});
                  await showDialog(
                    context: context,
                    builder: (BCTX) {
                      return AlertDialog(
                        title: Text("Pick A Color"),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              setAlterBackgroundColor(tempColor);

                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Text("Confirm"),
                          ),
                        ],
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (C) {
                              tempColor = C;

                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text("Alter Background Color"),
              ),
              ElevatedButton(
                onPressed: () async {
                  tempColor = getAlterTextColor();

                  setState(() {});
                  await showDialog(
                    context: context,
                    builder: (BCTX) {
                      return AlertDialog(
                        title: Text("Pick A Color"),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              setAlterTextColor(tempColor);

                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Text("Confirm"),
                          ),
                        ],
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (C) {
                              tempColor = C;

                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text("Alter Text Color"),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people_alt, color: getNavSelColor(), size: 50),
                  SizedBox(width: 25),
                  Text("NavBar Selected Color"),
                  ElevatedButton(
                    onPressed: () async {
                      tempColor = getNavSelColor();

                      await showDialog(
                        context: context,
                        builder: (bldr) {
                          return AlertDialog(
                            title: Text("Pick a color"),
                            content: ColorPicker(
                              pickerColor: tempColor,
                              onColorChanged: (C) {
                                tempColor = C;
                              },
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  setNavSelColor(tempColor);
                                  Navigator.pop(context);

                                  setState(() {});
                                },
                                child: Text("Dismiss"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.colorize),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people_alt, color: getNavUnselColor(), size: 50),
                  SizedBox(width: 25),
                  Text("NavBar Unselected Color"),
                  ElevatedButton(
                    onPressed: () async {
                      tempColor = getNavUnselColor();

                      await showDialog(
                        context: context,
                        builder: (bldr) {
                          return AlertDialog(
                            title: Text("Pick a color"),
                            content: ColorPicker(
                              pickerColor: tempColor,
                              onColorChanged: (C) {
                                tempColor = C;
                              },
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  setNavUnselColor(tempColor);
                                  Navigator.pop(context);

                                  setState(() {});
                                },
                                child: Text("Dismiss"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.colorize),
                  ),
                ],
              ),
              ListTile(
                title: Text("C H A N G E  F O N T"),
                subtitle: Text(
                  "Allows you to change the current font for the entire app.",
                ),
                leading: Icon(Icons.font_download, color: Colors.black),
                tileColor: Color.fromARGB(255, 213, 213, 213),
                textColor: Colors.black,
                onTap: () async {
                  // Open the font selection screen.
                  await Navigator.pushNamed(context, "/account/settings/font");
                },
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text("E D I T  F I E L D S"),
                tileColor: const Color.fromARGB(255, 119, 219, 255),
                textColor: Colors.black,
                subtitle: Text(
                  "Edit the fields that show up for each alter.\nYou can also rearrange the order in which they appear.",
                ),
                leading: Icon(Icons.edit_attributes, color: Colors.black),
                onTap: () async {
                  Navigator.pushNamed(context, "/account/settings/fields");
                },
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text("G L O W  S E T T I N G S"),
                subtitle: Text("Edit the glow settings!"),
                leading: Icon(CupertinoIcons.circle_fill),
                tileColor: Colors.indigo,
                onTap: () async {
                  // Open the glow settings page
                  await Navigator.pushNamed(context, "/account/settings/glow");
                  Switchboard.rebuild();
                  await setAppSettings();
                },
              ),
              Divider(height: 25),
              ListTile(
                title: Text("E X P O R T  A P P  T H E M E"),
                leading: Icon(Icons.download_for_offline, color: Colors.black),
                subtitle: Text(
                  "Export your app settings for safe-keeping, or to share with others.",
                ),
                tileColor: const Color.fromARGB(255, 138, 222, 122),
                textColor: Colors.black,
                onTap: () async {
                  String data = base64Encoder.base64Enc(
                    json.encode(ms.toJson()),
                  );

                  await showDialog(
                    context: context,
                    builder: (bldr) {
                      return AlertDialog(
                        title: Text("Export Complete"),
                        content: SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            child: Card(
                              elevation: 8,
                              child: Text(data, style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: data),
                              );
                              Navigator.pop(context);
                            },
                            child: Text("COPY"),
                          ),
                        ],
                      );
                    },
                  );

                  print(data);
                },
              ),

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

              Divider(),
              ListTile(
                title: Text("I M P O R T  F R O M  3 R D  P A R T Y"),
                subtitle: Text(
                  "Import all data from a 3RD Party export. Must be in the JSON file format.",
                ),
                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                leading: Icon(Icons.import_contacts),
                onTap: () {
                  Navigator.pushNamed(context, "/account/settings/octocon");
                },
              ),
              Divider(),

              ListTile(
                title: Text("DEBUG: Wipe Account"),
                subtitle: Text(
                  "This debug option will wipe all data from your account. It is not reversible.",
                ),
                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                onTap: () async {
                  //await NetworkInterface.wipeAccount();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Wiping account has been temporarily disabled as part of the settings menu restructuring. This option is moving to the Developer Options menu.",
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),

              Divider(),

              SizedBox(height: 50),
              ListTile(
                title: Text("L O G  O U T"),
                leading: Icon(Icons.logout),
                subtitle: Text(
                  "Immediately logs you out of the app. Remember me will also be turned off and invalidated.",
                ),
                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                onTap: () async {
                  ms.rememberMe = false;
                  ms.username = "";
                  ms.password = "";
                  ms.authenticationToken = "";

                  await setAuthToken("");

                  await Navigator.pushReplacementNamed(context, "/login");
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
