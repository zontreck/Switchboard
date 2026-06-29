import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';
import 'package:switchboard/sb.dart';

class GlowSettingsPage extends StatefulWidget {
  const GlowSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _glowSettings();
  }
}

class _glowSettings extends State<GlowSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(125),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text("Glow Settings", style: TextStyle(fontSize: 22)),
                AlterWidget(
                  alterID: UUID_ZERO,
                  alterName: "Sample Alter",
                  url: "${getAPIServerURL()}/avatar/null",
                  withFronterElement: false,
                  frontID: UUID_ZERO,
                  fronting: true,
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        label: Text("Add new Color", style: TextStyle(fontSize: 18)),
        onPressed: () async {
          MemoryState.A.glowColors.add([255, 255, 0, 0]);
          setState(() {});
        },
        icon: Icon(CupertinoIcons.add),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 25),
              Text(
                "NOTE: We aim to be inclusive. It's not possible to add every flag preset as a toggle, or else we would. There are too many. If you have one in particular you want, you can either request it, or customize the glow yourself below.",
                style: TextStyle(fontSize: 18),
              ),
              ListTile(
                title: Text("Flag Color Presets"),
                subtitle: Text(
                  "Pick from a selection of pride flags for the glow color!",
                ),
                leading: Icon(CupertinoIcons.flag),
                tileColor: Colors.blueGrey,
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    "/account/settings/glow/presets",
                  );

                  Switchboard.rebuild();
                  await setAppSettings();

                  setState(() {});
                },
              ),

              SizedBox(height: 7),

              Divider(height: 22),
              Text(
                "Custom glow colors!\nCustomize the colors below to whatever you would like them to be.\nNOTE: The alter's color preference will always appear in the glow.",
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemBuilder: (bldr, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      background: ListTile(trailing: Icon(Icons.delete)),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // remove from list
                          MemoryState.A.glowColors.removeAt(index);
                          return true;
                        } else {
                          return false;
                        }
                      },
                      onDismissed: (direction) {
                        Switchboard.rebuild();
                      },
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Pick A Color"),
                            onTap: () async {
                              // Open a color picker
                              var reply = await showDialog(
                                context: context,
                                builder: (bldr) {
                                  return AlertDialog(
                                    title: Text("Pick A Color"),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Confirm"),
                                      ),
                                    ],
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: getGlowColors()[index],
                                        hexInputBar: true,
                                        onColorChanged: (Cv) {
                                          MemoryState.A.glowColors[index] =
                                              Color2List(Cv);

                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            leading: Icon(
                              Icons.circle,
                              color: getGlowColors()[index],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                  itemCount: getGlowColors().length,
                  shrinkWrap: true,
                ),
              ),
              Divider(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
