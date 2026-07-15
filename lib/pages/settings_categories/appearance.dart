import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
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
