import 'package:flutter/material.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';

class EditFieldsPage extends StatefulWidget {
  const EditFieldsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _editFields();
  }
}

class _editFields extends State<EditFieldsPage> {
  List<Field> fields = [];
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("EDIT FIELDS", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              fields = [];
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              _dirty = false;
              await sanityCheckFields();

              await save();
              fields = [];

              setState(() {});
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      floatingActionButton: _dirty
          ? ElevatedButton.icon(
              onPressed: () async {
                _dirty = false;
                await sanityCheckFields();

                await save();
                fields = [];

                setState(() {});
              },
              icon: Icon(Icons.save),
              label: Text("S A V E"),
            )
          : ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text("N E W"),
            ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Center(
          child: FutureBuilder(
            future: getFields(),
            builder: (bldr, snap) {
              if (!snap.hasData) {
                return SizedBox(height: 40, child: CircularProgressIndicator());
              } else {
                return snap.data!;
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Widget> getFields() async {
    if (fields.isEmpty) {
      S2CFieldsResponse reply = await NetworkInterface.getDataFields();
      fields = reply.data;

      await sanityCheckFields();
    }

    List<Widget> widgets = [];
    for (var field in fields) {
      widgets.add(
        FieldWidget(
          field: field,
          onTap: () async {
            // Perform actions
          },
          backgroundColor: getAlterBackgroundColor(),
          textColor: getAlterTextColor(),
          enableReorder: true,
          key: ValueKey(field.id.toString()),
        ),
      );
    }

    ReorderableListView rlv = ReorderableListView.builder(
      itemBuilder: (ctx, index) {
        return widgets[index];
      },
      itemCount: widgets.length,
      onReorder: (oldIndex, newIndex) async {
        // 1. Update the data source (fields)
        final Field item = fields.removeAt(oldIndex);

        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        fields.insert(newIndex, item);

        markDirty();
        await sanityCheckFields();

        setState(() {
          didChangeDependencies();
        });
      },
    );

    return rlv;
  }

  Future<void> save() async {
    for (var field in fields) {
      var reply = await NetworkInterface.updateField(field);
    }

    setState(() {});
  }

  void markDirty() {
    _dirty = true;
  }

  Future<void> sanityCheckFields() async {
    int index = 0;
    for (var field in fields) {
      field.order = index;

      index++;
    }
  }
}

Widget getSampleWidgetByType(FieldType type) {
  switch (type) {
    default:
      {
        return Text("Unknown - Cannot generate sample");
      }
  }
}
