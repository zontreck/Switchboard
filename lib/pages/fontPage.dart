import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:switchboard/globalHelpers.dart';

class FontPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _fontPage();
  }
}

class _fontPage extends State<FontPage> {
  TextEditingController URLController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("CHANGE FONT", style: TextStyle(fontSize: 22)),
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
              // Give some instructions
              Text(
                "This feature is highly experimental and is subject to change.",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
              Text(
                "** This feature currently will load the font, then cache it in the application settings. It will later, likely store it on the server to open the ability to make app themes that can include font customizations. **",
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              SizedBox(height: 50),
              ListTile(
                title: Text("S E L E C T  F O N T"),
                subtitle: Text(
                  "Opens a file browser to find, and load the font from device storage.",
                ),
                leading: Icon(Icons.font_download),
                tileColor: Colors.purple,
                onTap: () async {
                  var hasPerm = await checkStoragePermissions();
                  if (!hasPerm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Storage permissions are denied currently. Please grant them before you can proceed.",
                        ),
                      ),
                    );
                    return;
                  }
                  FilePickerResult? result = await FilePicker.pickFiles(
                    allowMultiple: false,
                    allowedExtensions: ["ttf"],
                    type: FileType.custom,
                  );

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    await setApplicationFont(file.readAsBytesSync());
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Aborting changing font...")),
                    );
                  }
                },
              ),

              SizedBox(height: 50),
              Divider(),

              Text("Load From URL", style: TextStyle(fontSize: 22)),
              TextField(
                controller: URLController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "https://example.com/font.ttf.......",
                ),
              ),

              ElevatedButton.icon(
                onPressed: () async {
                  Dio dio = Dio();
                  var result = await dio.get(URLController.text);
                  Uint8List data = result.data;

                  await setApplicationFont(data);
                  setState(() {});
                },
                icon: Icon(Icons.file_download),
                label: Text("L O A D   F O N T"),
              ),

              Divider(),
              SizedBox(height: 50),
              ListTile(
                title: Text("C L E A R  C U S T O M  F O N T"),
                leading: Icon(Icons.delete),
                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                subtitle: Text(
                  "Clears the font immediately and goes back to the application defaults",
                ),
                onTap: () async {
                  await clearApplicationFont();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
