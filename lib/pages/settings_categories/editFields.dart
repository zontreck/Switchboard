import 'package:flutter/cupertino.dart';
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

                    pageChanged();
                    await Navigator.pushNamed(
                      context,
                      "/account/settings/fields/edit",
                      arguments: newField.data,
                    );
                    pageChanged();
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

            pageChanged();
            await Navigator.pushNamed(
              context,
              "/settings/account/fields/edit",
              arguments: field,
            );

            pageChanged();
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
  const EditField({super.key});

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
                    Center(
                      child: Text(
                        "Information",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Divider(),
                    Card(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                "Field ID",
                                style: TextStyle(fontSize: 22),
                              ),
                              subtitle: Text(
                                initialField!.id.toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                            if (initialField!.type.value() < 0)
                              SizedBox(height: 50),

                            if (initialField!.type.value() < 0)
                              ListTile(
                                title: Text("System Field"),
                                subtitle: Text(
                                  "This field is required for proper operation of the Switchboard platform. The type cannot be changed, and the field cannot be deleted.",
                                ),
                                leading: Icon(Icons.info),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                ),
                                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),
                    Center(
                      child: Text("Properties", style: TextStyle(fontSize: 20)),
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
                            Center(
                              child: Text(
                                "Field Name",
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                hintText: "Name of the Field",
                              ),
                              controller: fieldName,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();

                                setState(() {});
                              },
                            ),

                            Divider(),
                            SizedBox(height: 25),
                            Center(
                              child: Text(
                                "Field Type",
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                "Changing a field's type will erase the data stored within it for all alters.",
                                style: TextStyle(color: Colors.red),
                              ),
                              leading: Icon(
                                Icons.warning,
                                color: Colors.yellow,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (bldr) {
                                    return CupertinoAlertDialog(
                                      title: Text("About Field Type"),
                                      content: Text(
                                        "Each field type stores the data slightly differently. This is due to the different ways of accessing and formatting the presented information.",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text("Close"),
                                          isDefaultAction: true,
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
                                            as List<
                                              DropdownMenuEntry<FieldType>
                                            >,
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
                    ),
                    SizedBox(height: 25),
                    if (initialField!.type.value() >= 0)
                      Center(
                        child: Text(
                          "DANGER",
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        ),
                      ),
                    if (initialField!.type.value() >= 0) Divider(),
                    if (initialField!.type.value() >= 0)
                      Card(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text("D E L E T E   F I E L D"),
                                leading: Icon(Icons.delete),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                ),
                                tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                                subtitle: Text(
                                  "DELETES THE FIELD ENTIRELY. All alter data using this field will be discarded. This action cannot be undone.",
                                ),
                                onTap: () async {
                                  var reply = await showDialog(
                                    context: context,
                                    builder: (bldr) {
                                      return AlertDialog(
                                        icon: Icon(Icons.dangerous),
                                        title: Text("Are you sure?"),
                                        content: Text(
                                          "This action will delete the field forever. It cannot be undone. All data assigned to this field will be permanently deleted.",
                                        ),
                                        actions: [
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              Navigator.pop(context, 1);
                                            },
                                            icon: Icon(Icons.delete_forever),
                                            label: Text("DELETE NOW"),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateColor.resolveWith((
                                                    X,
                                                  ) {
                                                    return LibACFlutterConstants
                                                        .TITLEBAR_COLOR;
                                                  }),
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                            label: Text("Abort!"),
                                            icon: Icon(Icons.cancel),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (reply == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Aborted field deletion"),
                                      ),
                                    );
                                  } else {
                                    var deleteReply =
                                        await NetworkInterface.deleteField(
                                          initialField!.id,
                                        );

                                    if (deleteReply.success) {
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "FATAL ERROR: The request failed for the following reason: ${deleteReply.reason}\n\nRequest ID: ${deleteReply.id}",
                                          ),
                                          duration: Duration(seconds: 15),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 150),
                  ],
                ),
        ),
      ),
    );
  }
}
