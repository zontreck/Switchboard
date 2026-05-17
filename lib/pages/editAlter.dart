import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libac_dart/nbt/SnbtIo.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/nbt/impl/IntArrayTag.dart';
import 'package:libac_dart/nbt/impl/StringTag.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/pages/elements.dart';

class EditAlterPage extends StatefulWidget {
  const EditAlterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _editAlter();
  }
}

class _editAlter extends State<EditAlterPage> {
  UUID alterId = UUID.ZERO;
  Alter alter = Alter(
    id: UUID.ZERO,
    user: UUID.ZERO,
    name: "name",
    avatarUrl: "avatarUrl",
    subid: 0,
    parent: UUID.ZERO,
    flags: 0,
    fields: [],
  );
  TextEditingController alterNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as EditAlterArguments;
    alterId = args.alterId;
    alter = args.instance;
    alterNameController.text = alter.name;

    return Scaffold(
      appBar: AppBar(title: Text("Switchboard - Edit Alter")),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          alter.name = alterNameController.text;
          print(SnbtIo.writeToString(alter.encodeTag()));

          FocusManager.instance.primaryFocus?.unfocus();

          setState(() {});

          var reply = await NetworkInterface.updateAlter(alter);
          if (reply.success) {
            Navigator.pop(context);
          }
        },
        label: Text("Save"),
        icon: Icon(Icons.done_outline_rounded),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(alter.name, style: TextStyle(fontSize: 22)),
              Divider(),
              Center(
                child: InkWell(
                  child: AlterImage.defaults(
                    alter: alter,
                    width: 25,
                    height: 25,
                  ),
                  onTap: () {},
                ),
              ),
              ListTile(
                title: Text("Alter ID"),
                leading: Icon(Icons.perm_identity),
                subtitle: Text(
                  "Click / Tap to reveal the UUID assigned to this alter",
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (builder) {
                      return AlertDialog(
                        title: Text("Alter ID"),
                        content: Text(
                          "The Alter ID is: ${alter.id.toString()}",
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: alter.id.toString()),
                              );
                            },
                            child: Text("Copy"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Dismiss"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 25),
              TextField(
                controller: alterNameController,
                decoration: InputDecoration(
                  hintText: "Alter Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 25),
              Divider(),
              FutureBuilder(
                future: getFieldList(alter),
                builder: (bldr, snapFields) {
                  if (!snapFields.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapFields.data == null) {
                      return SizedBox();
                    }
                    return snapFields.data!;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget?> getFieldList(Alter alter) async {
    List<Widget> widgets = [];
    S2CFieldsResponse fields = await NetworkInterface.getDataFields();
    List<Field> fieldVals = fields.data;
    fieldVals.sort((F1, F2) {
      return F1.order.compareTo(F2.order);
    });

    for (var field in fieldVals) {
      widgets.add(Text(field.name, style: TextStyle(fontSize: 22)));
      widgets.add(
        AlterFieldData(
          data: alter.getDataByFieldID(field.id),
          type: field.type,
          alter: alter,
        ),
      );

      widgets.add(Divider());
    }
    return Column(children: widgets);
  }
}

class AlterFieldData extends StatefulWidget {
  FieldData data;
  FieldType type;
  Alter alter;

  AlterFieldData({
    super.key,
    required this.data,
    required this.type,
    required this.alter,
  });

  @override
  State<StatefulWidget> createState() {
    return _alterFieldData();
  }
}

class _alterFieldData extends State<AlterFieldData> {
  Map<String, Object> controlHolders = {};

  _alterFieldData();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.type == FieldType.PlainText) {
      TextEditingController ptCon = TextEditingController(
        text:
            widget.data.data
                .get("${widget.type.name}-${widget.type.value()}")
                ?.asString() ??
            "",
      );

      controlHolders[widget.data.id.toString()] = ptCon;
    } else if (widget.type == FieldType.Color ||
        widget.type == FieldType.ColorSys) {
      List<int> lst =
          widget.data.data
              .get("${widget.type.name}-${widget.type.value()}")
              ?.asIntArray() ??
          [255, 255, 255, 255];

      Color color = ColorFromList(lst);

      controlHolders[widget.data.id.toString()] = color;
    } else if (widget.type == FieldType.Markdown ||
        widget.type == FieldType.Description) {
      TextEditingController con = TextEditingController(
        text:
            widget.data.data
                .get("${widget.type.name}-${widget.type.value()}")
                ?.asString() ??
            "",
      );

      controlHolders[widget.data.id.toString()] = con;
      controlHolders["${widget.data.id.toString()}-prev"] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FieldType.PlainText:
        {
          return TextField(
            controller:
                controlHolders[widget.data.id.toString()]
                    as TextEditingController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            onChanged: (value) {
              CompoundTag ct = CompoundTag();
              ct.put(
                "${widget.type.name}-${widget.type.value()}",
                StringTag.valueOf(
                  (controlHolders[widget.data.id.toString()]
                          as TextEditingController)
                      .text,
                ),
              );

              widget.alter.fieldChangeNotifier.value = FieldData(
                id: widget.data.id,
                data: ct,
              );
            },
          );
        }
      case FieldType.Color:
      case FieldType.ColorSys:
        {
          // Both color and Color System have the same controls for editing. So we'll just preserve that here, and reduce the redundancy.
          return ListTile(
            leading: Icon(
              Icons.circle,
              color: controlHolders[widget.data.id.toString()] as Color,
            ),
            title: Text("Pick A Color"),
            subtitle: Text("Tap here to change the color selection"),
            onTap: () async {
              Color C = controlHolders[widget.data.id.toString()] as Color;
              var a = AlertDialog(
                title: Text("Pick A Color"),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      CompoundTag ct = CompoundTag();
                      List<int> lst = Color2List(C);
                      controlHolders[widget.data.id.toString()] = C;
                      IntArrayTag iat = IntArrayTag.valueOf(lst);
                      ct.put("${widget.type.name}-${widget.type.value()}", iat);

                      widget.alter.fieldChangeNotifier.value = FieldData(
                        id: widget.data.id,
                        data: ct,
                      );
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: Text("Confirm"),
                  ),
                ],
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor:
                        controlHolders[widget.data.id.toString()] as Color,
                    onColorChanged: (Cv) {
                      C = Cv;

                      setState(() {});
                    },
                  ),
                ),
              );
              await showDialog(context: context, builder: (B) => a);
              setState(() {});
            },
          );
        }
      case FieldType.Markdown:
      case FieldType.Description:
        {
          return Column(
            children: [
              (controlHolders["${widget.data.id.toString()}-prev"] as bool)
                  ? Card(
                      child: SingleChildScrollView(
                        child: MarkdownWidget(
                          data:
                              (controlHolders[widget.data.id.toString()]
                                      as TextEditingController)
                                  .text,
                          shrinkWrap: true,
                        ),
                      ),
                    )
                  : TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 4,
                      controller:
                          controlHolders[widget.data.id.toString()]
                              as TextEditingController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (value) {
                        CompoundTag ct = CompoundTag();
                        ct.put(
                          "${widget.type.name}-${widget.type.value()}",
                          StringTag.valueOf(
                            (controlHolders[widget.data.id.toString()]
                                    as TextEditingController)
                                .text,
                          ),
                        );

                        widget.alter.fieldChangeNotifier.value = FieldData(
                          id: widget.data.id,
                          data: ct,
                        );
                      },
                    ),
              SizedBox(height: 8),
              ListTile(
                title: Text("Preview"),
                leading: Icon(Icons.preview),
                subtitle: Text(
                  "Enable/Disable editing and render a markdown preview.",
                ),
                onTap: () {
                  controlHolders["${widget.data.id.toString()}-prev"] =
                      !(controlHolders["${widget.data.id.toString()}-prev"]
                          as bool);

                  setState(() {});
                },
              ),
            ],
          );
        }
      default:
        {
          return SizedBox();
        }
    }
  }
}

class EditAlterArguments {
  UUID alterId;
  Alter instance;

  EditAlterArguments({required this.alterId, required this.instance});
}
