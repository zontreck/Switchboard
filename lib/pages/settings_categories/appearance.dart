import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libacflutter/Constants.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';
import 'package:switchboard/sb.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});

  @override
  State<StatefulWidget> createState() {
    return _visual();
  }
}

class _visual extends State<AppearanceSettings> {
  MemoryState ms = MemoryState();
  Color tempColor = Colors.white;
  TextEditingController importThemeController = TextEditingController();
  bool importErrorHint = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("Appearance Settings", style: TextStyle(fontSize: 20)),
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
              SizedBox(height: 50),
              Center(child: Text("Alters", style: TextStyle(fontSize: 22))),
              Divider(),
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AlterWidget(
                        flush: ms.flushPictures,
                        withFronterElement: false,
                        onTap: () {},
                        frontStartTime: TimeUtils.getUnixTimestamp() - 61195,
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
                        showFrontingTime: true,
                      ),
                      SizedBox(height: 25),

                      CheckboxListTile(
                        value: ms.flushPictures,
                        onChanged: (B) {
                          ms.flushPictures = B ?? false;
                          setAppSettings().then((V) {
                            setState(() {});
                          });
                        },
                        title: Text("Flush Pictures"),
                      ),

                      CheckboxListTile(
                        value: ms.squarePicture,
                        enabled: !ms.flushPictures,
                        onChanged: (B) {
                          if (ms.flushPictures) return;
                          ms.squarePicture = B ?? false;
                          setAppSettings().then((V) {
                            setState(() {});
                          });
                        },
                        title: Text("Square Pictures"),
                      ),

                      CheckboxListTile(
                        value: ms.roundedBorder,
                        onChanged: (B) {
                          ms.roundedBorder = B ?? true;
                          setAppSettings().then((V) {
                            setState(() {});
                          });
                        },
                        title: Text("Rounded Borders"),
                      ),

                      CheckboxListTile(
                        value: ms.disableGlowAnimations,
                        onChanged: (B) {
                          ms.disableGlowAnimations = B ?? false;
                          setAppSettings().then((V) {
                            setState(() {});
                          });
                        },
                        title: Text("Disable Fronting Glow Animations"),
                        subtitle: Text(
                          "This setting is also found in Accessibility Settings, and in Glow Settings",
                        ),
                      ),

                      ListTile(
                        title: Text("Glow Settings"),
                        leading: Icon(CupertinoIcons.circle_fill),
                        trailing: Icon(Icons.forward),
                        onTap: () async {
                          // Open the glow settings page
                          await Navigator.pushNamed(context, "/settings/glow");
                          Switchboard.rebuild();
                          await setAppSettings();
                        },
                      ),
                      Divider(),

                      SizedBox(height: 25),
                      ListTile(
                        title: Text("Note"),
                        subtitle: Text(
                          "Alter background and text colors are able to be overriden by individual alters! They simply need to set their color preference in the alter profile editor.",
                        ),
                        leading: Icon(Icons.info),
                      ),
                      SizedBox(height: 15),
                      ListTile(
                        title: Text("Alter Background Color"),
                        tileColor: Color.fromARGB(75, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),

                        leading: Icon(
                          Icons.circle,
                          color: getAlterBackgroundColor(),
                        ),
                        subtitle: Text(
                          "#${colorToHex(getAlterBackgroundColor())}",
                        ),
                        onTap: () async {
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
                      ),
                      SizedBox(height: 15),

                      ListTile(
                        title: Text("Alter Text Color"),
                        tileColor: Color.fromARGB(75, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),

                        leading: Icon(Icons.circle, color: getAlterTextColor()),
                        subtitle: Text("#${colorToHex(getAlterTextColor())}"),
                        onTap: () async {
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
                      ),
                      Divider(),
                      SizedBox(height: 20),
                      ListTile(
                        title: Text("Text Overflow"),
                        subtitle: Text(
                          "Overflow text settings for very long text",
                        ),
                        leading: Icon(Icons.wrap_text),
                        trailing: Icon(Icons.forward),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        onTap: () async {
                          pageChanged();
                          await Navigator.pushNamed(
                            context,
                            "/settings/appearance/overflow",
                          );

                          pageChanged();

                          setState(() {});
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),
              Center(
                child: Text("User Interface", style: TextStyle(fontSize: 20)),
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
                      ListTile(
                        title: Text("NavBar Tab-Selected Color"),
                        subtitle: Text(
                          "Used mostly by the navigation bar on the main screen. Current page selection color.",
                        ),
                        tileColor: Color.fromARGB(75, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),

                        leading: Icon(Icons.circle, color: getNavSelColor()),
                        trailing: Icon(Icons.colorize),
                        onTap: () async {
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
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        title: Text("NavBar Tab Not Selected Color"),
                        tileColor: Color.fromARGB(75, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        subtitle: Text(
                          "Used for inactive navigation pages. The pages not currently being viewed are indicated by this color.",
                        ),
                        leading: Icon(Icons.circle, color: getNavUnselColor()),
                        trailing: Icon(Icons.colorize),
                        onTap: () async {
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
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      ListTile(
                        title: Text("Change Font"),
                        subtitle: Text(
                          "Allows you to change the current font for the entire app.",
                        ),
                        leading: Icon(Icons.font_download),
                        trailing: Icon(Icons.forward),
                        onTap: () async {
                          // Open the font selection screen.
                          await Navigator.pushNamed(context, "/settings/font");
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Export App Theme"),
                        leading: Icon(Icons.download_for_offline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        subtitle: Text(
                          "Export your app settings for safe-keeping, or to share with others.",
                        ),
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
                                      child: Text(
                                        data,
                                        style: TextStyle(fontSize: 16),
                                      ),
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
                      Divider(),
                      ListTile(
                        title: Text("Import App Theme"),
                        leading: Icon(Icons.install_mobile),
                        subtitle: Text(
                          "Import a app theme, and apply it immediately!",
                        ),
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
                                        ms.fromJson(
                                          json.decode(data),
                                          theme: true,
                                        );

                                        setState(() {});

                                        setAppSettings();
                                        importErrorHint = false;
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
                                      if (importErrorHint)
                                        Text(
                                          "Invalid Theme data was provided.",
                                          style: TextStyle(color: Colors.red),
                                        ),
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
                      Divider(),
                      ListTile(
                        title: Text("Restore Default Theme"),
                        leading: Icon(Icons.restore_from_trash),
                        subtitle: Text("Reset all defaults for the app theme"),
                        tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
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
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
