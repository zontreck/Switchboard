import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';

class EditFieldsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _editFields();
  }
}

class _editFields extends State<EditFieldsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Switchboard")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("EDIT FIELDS", style: TextStyle(fontSize: 22)),
              Divider(),

              FutureBuilder(
                future: getFields(),
                builder: (bldr, snap) {
                  if (!snap.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    return snap.data!;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Widget> getFields() async {
  S2CFieldsResponse reply = await NetworkInterface.getDataFields();
  List<Widget> widgets = [];
  for (var field in reply.data) {
    widgets.add(
      FieldWidget(
        field: field,
        onTap: () async {
          // Perform actions
        },
        backgroundColor: getAlterBackgroundColor(),
        textColor: getAlterTextColor(),
        enableReorder: true,
      ),
    );
    widgets.add(SizedBox(height: 8));
  }

  return Column(children: widgets);
}

Widget getSampleWidgetByType(FieldType type) {
  switch (type) {
    default:
      {
        return Text("Unknown - Cannot generate sample");
      }
  }
}
