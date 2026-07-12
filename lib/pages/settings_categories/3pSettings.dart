import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/octocon_format.dart';
import 'package:switchboard/dart/ourcana_format.dart';
import 'package:switchboard/dart/pluralkit_format.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/file_picker.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/settings_categories/progressDisplayPage.dart';

class ThirdPartyImport extends StatefulWidget {
  const ThirdPartyImport({super.key});

  @override
  State<StatefulWidget> createState() {
    return _3p();
  }
}

class _3p extends State<ThirdPartyImport> {
  Uint8List? _contents;

  Future<void> runMigration() async {
    // Start importing data
    if (_contents == null) {
      return;
    }
    String octoData = await convertRawBytesToString(_contents!);
    OctoconData? octoconData;
    bool fail = false;
    try {
      octoconData = OctoconData.fromJson(octoData);
    } catch (E, stack) {
      print(E);
      print(stack);
      fail = true;
      try {
        PluralKitData pkData = await PluralKit.decode(
          typeCorrectJsonDecode(octoData),
        );

        octoconData = PluralKit.convertToOctocon(pkData);
        fail = false;
      } catch (E, stack) {
        print(E);
        print(stack);
        // Maybe try Ourcana next?
        try {
          OurcanaData ocData = Ourcana.decode(typeCorrectJsonDecode(octoData));

          octoconData = Ourcana.convertToOctocon(ocData);
          fail = false;
        } catch (E, stack) {
          print(E);
          print(stack);
          // No other supported Codecs
        }
      }
    }

    if (fail || octoconData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fatal Error: The provided file could not be decoded using any available codec. We attempted Octocon, PluralKit, and Ourcana. No valid format succeeded. If you believe this to be an error, please contact the development team. You may be asked to provide the export json in order for us to better assist you.",
          ),
        ),
      );
      return;
    }
    pageChanged();
    await Navigator.pushNamed(
      context,
      "/settings/3p/migrate",
      arguments: OctoconMigrationArguments(data: octoconData),
    );
    pageChanged();
    setState(() {});
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
              Text(
                "IMPORT FROM 3RD PARTY (JSON)",
                style: TextStyle(fontSize: 22),
              ),
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
                    "# Welcome\n\nThis is the import system. You will be able to import from a 3rd party here.\n\n## Octocon\n\nOctocon full exports are completely supported, as are PluralKit exports from Octocon. Please be aware, only a full export will have your fronting history.\n\n## PluralKit\n\nPluralKit support is experimental at best. We partially support this platform, but the PK JSON file we were provided by a friend did not contain any fronting history, so PK only is able to import your system, no history.\n\n## Ourcana\n\nOurcana support is experimental at best. We partially support this platform, however the JSON file we had available to examine did not contain every possible information type. So, some things like custom fields may not work.\n\n# Option 1: Complete Wipe\n\nThis option will completely wipe your Switchboard account and replace its contents with that of your imported file. This is for you if you wanted to try out our app before importing everything.\n\n# Option 2: As Is\n\nThis option is for you if you want to combine profile systems. It will merge the data from an export into Switchboard as seamlessly as we possibly can. Again, this option is non-destructive and will **not** erase anything.",
              ),
              Divider(),
              ListTile(
                title: Text("S E L E C T  F I L E"),
                subtitle: Text("Open the file picker and select a JSON export"),
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
                  "Please delete everything and import from 3rd party export",
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
                subtitle: Text("Import and merge"),
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
