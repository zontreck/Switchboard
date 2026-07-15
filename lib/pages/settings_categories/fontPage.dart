import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:libacflutter/Prompt.dart';
import 'package:switchboard/file_picker.dart';
import 'package:switchboard/globalHelpers.dart';

class FontPage extends StatefulWidget {
  const FontPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _fontPage();
  }
}

class _fontPage extends State<FontPage> {
  TextEditingController URLController = TextEditingController();

  void showSaveFont(Uint8List fontBytes) {
    showDialog(
      context: context,
      builder: (bldr) {
        return InputPrompt(
          title: "Font Name",
          prompt: "If you want, you can give the font a nickname to save it.",
          type: InputPromptType.Text,
          cancelAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Font will not be saved to the font library."),
              ),
            );
          },
          successAction: (p0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Saving font to Font Library...")),
            );
            if (p0.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Font will not be saved to the font library."),
                ),
              );
              return;
            }

            saveFont(p0, fontBytes);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("Font Changer", style: TextStyle(fontSize: 22)),
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
                child: Text("Font Selection", style: TextStyle(fontSize: 22)),
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
                        title: Text(
                          "This feature is currently experimental, and may change over time with very little warning.",
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      ListTile(
                        title: Text("Select Font"),
                        subtitle: Text(
                          "Select a downloaded font and import it into your app.",
                        ),
                        leading: Icon(Icons.font_download),
                        trailing: Icon(Icons.arrow_outward),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        onTap: () async {
                          var result = await FileLoader.getFile(
                            context: context,
                            allowedExtensions: ["ttf", "otf"],
                          );

                          if (result != null) {
                            await setApplicationFont(result);
                            setState(() {});

                            showSaveFont(result);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Aborting changing font..."),
                              ),
                            );
                          }
                        },
                      ),

                      Divider(),

                      ListTile(
                        title: Text("Font Library"),
                        subtitle: Text(
                          "Browse and select a font from ones you have already imported.",
                        ),
                        leading: Icon(Icons.library_books),
                        trailing: Icon(Icons.forward),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("This feature is coming soon!"),
                            ),
                          );
                        },
                      ),
                      Divider(),

                      SizedBox(height: 16),
                      TextField(
                        controller: URLController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          hintText: "https://example.com/font.ttf",
                        ),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        title: Text("Load Font From URL"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(32),
                        ),
                        subtitle: Text(
                          "Download the font and use it from direct URL.",
                        ),
                        leading: Icon(Icons.download),
                        tileColor: Color.fromARGB(75, 10, 10, 10),
                        onTap: () async {
                          Dio dio = Dio();
                          var result = await dio.get(URLController.text);
                          Uint8List data = result.data;

                          await setApplicationFont(data);
                          setState(() {});

                          showSaveFont(data);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),
              Center(
                child: Text(
                  "Danger",
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
              ),
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      ListTile(
                        title: Text("Clear Custom Font"),
                        subtitle: Text(
                          "Clears the current font and resets it back to the default. (Does not erase Font Library)",
                        ),
                        leading: Icon(Icons.delete),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                        onTap: () async {
                          await clearApplicationFont();
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        title: Text("Clear Font Library"),
                        subtitle: Text(
                          "Delete all saved fonts in the Font Library",
                        ),
                        leading: Icon(Icons.delete_forever),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (bldr) {
                              return CupertinoAlertDialog(
                                title: Text("Are you sure?"),
                                content: Text(
                                  "This action is irreversible",
                                  style: TextStyle(fontSize: 20),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      await setFontJson({});
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    child: Text("Yes"),
                                  ),
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    isDestructiveAction: false,
                                    child: Text("Cancel"),
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
            ],
          ),
        ),
      ),
    );
  }
}
