import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:switchboard/globalHelpers.dart';

class OctoconImport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _octocon();
  }
}

class _octocon extends State<OctoconImport> {
  String _selectedFile = "";

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
                  FilePickerResult? reply = await FilePicker.pickFiles(
                    allowedExtensions: ["json"],
                    allowMultiple: false,
                    type: FileType.custom,
                  );

                  if (reply == null) {
                    _selectedFile = "";
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Aborting import")));
                    return;
                  } else {
                    // Set the selected file path
                    _selectedFile = reply.files.first.path!;
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
                onTap: () {
                  if (_selectedFile.isEmpty) {
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
                        "This feature is coming soon. It is not yet available.",
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 25),
              ListTile(
                title: Text("O P T I O N  2"),
                subtitle: Text("Import and merge the Octocon data"),
                leading: Icon(Icons.import_contacts),
                tileColor: const Color.fromARGB(255, 0, 105, 4),
                onTap: () {
                  if (_selectedFile.isEmpty) {
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
                        "This feature is coming soon. It is not yet available.",
                      ),
                    ),
                  );
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
