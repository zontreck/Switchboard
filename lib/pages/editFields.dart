import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';
import 'package:libacflutter/Prompt.dart';
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
              onPressed: () async {
                // Ask for the field name, then generate, and open the editor automatically.
                InputPrompt ip = InputPrompt(
                  title: "What is the field name?",
                  prompt: "Please provide the name of the new field",
                  type: InputPromptType.Text,
                  successAction: (fieldName) async {
                    S2CFieldResponse newField = await NetworkInterface.newField(
                      fieldName,
                    );
                    // okay, now open the editor
                    await sanityCheckFields();
                    await save();
                    fields.add(newField.data);

                    await Navigator.pushNamed(
                      context,
                      "/account/settings/fields/edit",
                      arguments: newField.data,
                    );
                    setState(() {
                      fields = [];
                    });
                  },
                );
                await showDialog(context: context, builder: (bldr) => ip);
              },
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
      fields.sort((a, b) => a.order.compareTo(b.order));

      await sanityCheckFields();
    }

    List<Widget> widgets = [];
    for (var field in fields) {
      widgets.add(
        FieldWidget(
          field: field,
          onTap: () async {
            // Perform actions
            await sanityCheckFields();

            if (_dirty) {
              await save();
            }

            await Navigator.pushNamed(
              context,
              "/account/settings/fields/edit",
              arguments: field,
            );

            setState(() {
              fields = [];
            });
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
      print("Set field ${field.id} to order ${field.order}");

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

class EditField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _editField();
  }
}

class _editField extends State<EditField> {
  Field? initialField;
  TextEditingController fieldName = TextEditingController();
  FieldType fieldType = FieldType.Unknown;

  @override
  void didChangeDependencies() {
    // Check if this has already been run
    if (initialField == null) {
      initialField = ModalRoute.of(context)!.settings.arguments as Field;
      fieldType = initialField!.type;
      fieldName.text = initialField!.name;
    }

    super.didChangeDependencies();
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
                "EDIT FIELD - ${fieldName.text}",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          // Upload the field to the server, and close the editor.
          FocusManager.instance.primaryFocus?.unfocus();

          initialField!.name = fieldName.text;
          initialField!.type = fieldType;

          setState(() {});
          // Upload field

          await NetworkInterface.updateField(initialField!);
          Navigator.pop(context);
        },
        label: Text("S A V E  &  C L O S E"),
        icon: Icon(Icons.save),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: initialField == null
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    FieldWidget(field: initialField!, onTap: () {}),

                    Divider(height: 16),
                    Container(
                      alignment: AlignmentDirectional.centerStart,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "Field ID",
                              style: TextStyle(fontSize: 22),
                            ),
                            subtitle: Text(
                              "${initialField!.id.toString()}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 22),
                          ListTile(
                            title: Text(
                              "Field Name:",
                              style: TextStyle(fontSize: 22),
                            ),
                          ),

                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Name of the Field",
                            ),
                            controller: fieldName,
                          ),

                          SizedBox(height: 22),

                          // If this is a system field, we don't want to even give dropdown access, because the server will refuse to change the field type anyway.
                          if (initialField!.type.value() < 0)
                            ListTile(
                              title: Text("REQUIRED SYSTEM FIELD"),
                              subtitle: Text(
                                "This is a required system field. The type cannot be changed.",
                              ),
                              tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                            ),

                          ListTile(
                            title: Text(
                              "Field Type:",
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          FutureBuilder(
                            future: getFieldMenuEntries(
                              includeSystem: initialField!.type.value() <= -1,
                            ),
                            builder: (bldr, snap) {
                              if (!snap.hasData) {
                                return CircularProgressIndicator();
                              } else {
                                return DropdownMenu(
                                  dropdownMenuEntries:
                                      snap.data
                                          as List<DropdownMenuEntry<FieldType>>,
                                  enabled: initialField!.type.value() >= 0,
                                  initialSelection: fieldType,
                                  expandedInsets: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == null) return;
                                    fieldType = value;
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
