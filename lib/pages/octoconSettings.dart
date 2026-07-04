import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:switchboard/dart/octocon_format.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/file_picker.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/progressDisplayPage.dart';

class OctoconImport extends StatefulWidget {
  const OctoconImport({super.key});

  @override
  State<StatefulWidget> createState() {
    return _octocon();
  }
}

class _octocon extends State<OctoconImport> {
  Uint8List? _contents;

  Future<void> runMigration() async {
    // Start importing OctoconData
    if (_contents == null) {
      return;
    }
    String octoData = await convertRawBytesToString(_contents!);
    OctoconData octoconData = OctoconData.fromJson(octoData);

    await Navigator.pushNamed(
      context,
      "/account/settings/octocon/migrate",
      arguments: OctoconMigrationArguments(data: octoconData),
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
              Text("IMPORT FROM OCTOCON", style: TextStyle(fontSize: 22)),
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
              MarkdownBlock(
                data:
                    "# Welcome\n\nThis is the Octocon import system. You will be able to import a full export of your Octocon data here. Please be aware that there are two modes you can choose from.\n\n## Option 1 : Complete Wipe\n\nThis option will fully wipe your account. It will erase normally protected data, like the fronting history, and all alters. This is for you if you wanted to try out our app before importing everything.\n\n## Option 2 : Import-As-Is\n\nThis option is for you if you want to combine profile systems. It will essentially merge the Octocon data with our own. Front history will be merged, properly. It will not erase anything, only add.",
              ),
              Divider(),
              ListTile(
                title: Text("S E L E C T  F I L E"),
                subtitle: Text(
                  "Open the file picker and select a Octocon JSON export",
                ),
                leading: Icon(Icons.file_open),
                tileColor: Colors.blueGrey,
                onTap: () async {
                  _contents = await FileLoader.getFile(
                    context: context,
                    allowedExtensions: ["json"],
                  );

                  if (_contents == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Aborting import")));
                    return;
                  }
                },
              ),
              SizedBox(height: 25),
              ListTile(
                title: Text("O P T I O N  1"),
                subtitle: Text(
                  "Please delete everything and import from Octocon",
                ),
                leading: Icon(Icons.import_contacts),
                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                onTap: () async {
                  if (_contents == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("ERROR: You must select the file first."),
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "This feature is experimental and may not function exactly as expected yet.",
                      ),
                    ),
                  );

                  // return;
                  var reply = await NetworkInterface.wipeAccount();
                  if (reply.success) {
                    runMigration();
                  }
                },
              ),
              SizedBox(height: 25),
              ListTile(
                title: Text("O P T I O N  2"),
                subtitle: Text("Import and merge the Octocon data"),
                leading: Icon(Icons.import_contacts),
                tileColor: const Color.fromARGB(255, 0, 105, 4),
                onTap: () {
                  if (_contents == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("ERROR: You must select the file first."),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "This feature is experimental and may not function exactly as expected yet.",
                      ),
                    ),
                  );

                  // return;
                  runMigration();
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
