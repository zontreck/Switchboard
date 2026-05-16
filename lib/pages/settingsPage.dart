import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libac_dart/nbt/NbtIo.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:libacflutter/Constants.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _settings();
  }
}

class _settings extends State<SettingsPage> {
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
      appBar: AppBar(title: Text("Switchboard")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("SETTINGS", style: TextStyle(fontSize: 22)),
              Divider(),
              AlterWidget(
                flush: ms.flushPictures,
                roundedElement: ms.roundedBorder,
                squarePics: ms.squarePicture,
                backgroundColor: getAlterBackgroundColor(),
                textColor: getAlterTextColor(),
                alterID: UUID.ZERO,
                alterName: "Sample Alter",
              ),
              Row(
                children: [
                  Checkbox(
                    value: ms.flushPictures,
                    onChanged: (B) {
                      ms.flushPictures = B ?? true;
                      setAppSettings(ms.serialize()).then((V) {
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
                      setAppSettings(ms.serialize()).then((V) {
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
                      setAppSettings(ms.serialize()).then((V) {
                        setState(() {});
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text("Rounded Borders", style: TextStyle(fontSize: 16)),
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
                  String data = await NbtIo.writeBase64StringCompressed(
                    ms.serialize(),
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
                                CompoundTag ct =
                                    (await NbtIo.readBase64StringCompressed(
                                      importThemeController.text,
                                    )).asCompoundTag();
                                ms.deserialize(ct);

                                setState(() {});

                                setAppSettings(ct);
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
              ListTile(
                title: Text("L O G  O U T"),
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

                  await Navigator.pushReplacementNamed(context, "/");
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
