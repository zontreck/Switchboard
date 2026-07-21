import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libacflutter/Constants.dart';
import 'package:libacflutter/Prompt.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/file_picker.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';
import 'package:switchboard/sb.dart';

class EditAlterPage extends StatefulWidget {
  const EditAlterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _editAlter();
  }
}

class _editAlter extends State<EditAlterPage> {
  String alterId = UUID_ZERO;
  bool previewMode = false;
  Alter alter = Alter(
    id: UUID_ZERO,
    user: UUID_ZERO,
    name: "name",
    avatarUrl: "avatarUrl",
    subid: 0,
    parent: UUID_ZERO,
    flags: 0,
    fields: [],
    proxyName: "",
    proxies: [],
  );
  TextEditingController alterNameController = TextEditingController();

  @override
  void deactivate() {
    super.deactivate();
    print("Deactivated the Edit Alter page");
  }

  @override
  Widget build(BuildContext context) {
    if (alter.id == UUID_ZERO) {
      var args =
          ModalRoute.of(context)!.settings.arguments as EditAlterArguments;
      alterId = args.alterId;
      alter = args.instance;
      alterNameController.text = alter.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard - Edit Alter"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text(alter.name, style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                previewMode = !previewMode;
              });
            },
            icon: Icon(Icons.preview),
          ),
        ],
      ),
      floatingActionButton: previewMode
          ? ElevatedButton.icon(
              onPressed: () {
                previewMode = false;
                setState(() {});
              },
              label: Text("Leave Preview"),
              icon: Icon(Icons.close),
            )
          : ElevatedButton.icon(
              onPressed: () async {
                alter.name = alterNameController.text;
                print(alter.encode());

                FocusManager.instance.primaryFocus?.unfocus();

                setState(() {});

                var reply = await NetworkInterface.updateAlter(alter);
                if (reply.success) {
                  flushImageCaches();
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
              Center(
                child: InkWell(
                  child: AlterImage.defaults(
                    alter: alter,
                    width: 200,
                    height: 200,
                    useCacheBusting: true,
                  ),
                  onTap: () async {
                    if (previewMode) {
                      return;
                    }
                    print("Display image customize menu");

                    await showCupertinoDialog(
                      context: context,
                      builder: (bldr) {
                        return CupertinoAlertDialog(
                          title: Text("What would you like to do?"),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                "Upload Image",
                                style: TextStyle(fontSize: 22),
                              ),
                              onPressed: () async {
                                Uint8List? result = await FileLoader.getFile(
                                  allowedExtensions: [
                                    "png",
                                    "jpg",
                                    "jpeg",
                                    "tif",
                                    "tiff",
                                  ],
                                  photos: true,
                                  camera: false,
                                );

                                if (result != null) {
                                  var b64Img = base64Encoder.base64EncBytes(
                                    result,
                                  );
                                  await NetworkInterface.updateAvatar(
                                    alter,
                                    b64Img,
                                  );
                                  alter.avatarUrl = alter.id.toString();
                                  await NetworkInterface.updateAlter(alter);

                                  flushImageCaches();
                                  Navigator.pop(context);

                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Aborting profile upload...",
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Set URL",
                                style: TextStyle(fontSize: 22),
                              ),
                              onPressed: () async {
                                var reply = await showDialog(
                                  context: context,
                                  builder: (bldr) {
                                    return InputPrompt(
                                      title: "What is the URL?",
                                      prompt:
                                          "Please input the image's direct URL. It needs to be a raw image link.",
                                      type: InputPromptType.Text,
                                    );
                                  },
                                );

                                var url = reply as String;

                                var success =
                                    await NetworkInterface.migrateAvatar(
                                      url,
                                      alter.id,
                                    );
                                if (success) {
                                  alter.avatarUrl = alter.id.toString();
                                }
                                // update the alter's preferred image URL!
                                await NetworkInterface.updateAlter(alter);

                                Navigator.pop(context);
                                flushImageCaches();
                                setState(() {});
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Clear Image",
                                style: TextStyle(fontSize: 22),
                              ),
                              onPressed: () async {
                                var reply = await NetworkInterface.deleteAvatar(
                                  alter,
                                );
                                if (reply.success) {
                                  alter.avatarUrl = UUID_ZERO;
                                  await NetworkInterface.updateAlter(alter);
                                  flushImageCaches();
                                  setState(() {});
                                } else {
                                  if (reply.reason == "No such image found") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "There is already no image set.",
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "FATAL: Could not delete the alter profile image.\nReason: ${reply.reason}\nRequest ID: ${reply.id.toString()}",
                                        ),
                                      ),
                                    );
                                  }

                                  setState(() {});
                                }

                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Copy Permalink URL",
                                style: TextStyle(fontSize: 22),
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: alter.getAvatarURL()),
                                );
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: const Color.fromARGB(255, 209, 0, 0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    flushImageCaches();
                    await alter.pullUpdates();

                    setState(() {});
                  },
                ),
              ),
              if (!previewMode)
                ElevatedButton.icon(
                  icon: Icon(Icons.perm_identity),
                  label: Text("Show Alter ID"),
                  onPressed: () {
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
              if (!previewMode)
                TextField(
                  controller: alterNameController,
                  decoration: InputDecoration(
                    hintText: "Alter Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              if (previewMode) ListTile(title: Text(alterNameController.text)),
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
              SizedBox(height: 20),
              if (!previewMode)
                ListTile(
                  title: Text("Delete Alter"),
                  subtitle: Text(
                    "Delete this alter from the system. Cannot be undone!",
                  ),
                  onTap: () async {
                    var reply = await showDialog(
                      context: context,
                      builder: (bldr) {
                        return confirmDeleteAlter(context);
                      },
                    );

                    if (reply is bool) {
                      if (reply == true) {
                        var resp = await NetworkInterface.deleteAlter(alter.id);
                        if (resp.success) {
                          Switchboard.rebuild();
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Fatal Error: Could not delete alter. Request ID [${resp.id}]\nReason: ${resp.reason}",
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  tileColor: LibACFlutterConstants.TITLEBAR_COLOR,
                  leading: Icon(Icons.delete_forever),
                ),
              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget?> getFieldList(Alter alter) async {
    List<Widget> widgets = [];
    var fields = S2CFieldsResponse(
      id: UUID_ZERO,
      path: "/",
      reason: "reason",
      success: false,
      type: "",
      data: [],
    );

    if (fields.reason == "reason") {
      fields.reason = "NUL";
      fields = await NetworkInterface.getDataFields();
    }

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
          order: field.order,
          fieldName: field.name,
          preview: previewMode,
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
  int order;
  String fieldName;
  bool preview;

  AlterFieldData({
    super.key,
    required this.data,
    required this.type,
    required this.alter,
    required this.order,
    required this.fieldName,
    required this.preview,
  });

  @override
  State<StatefulWidget> createState() {
    return _alterFieldData();
  }
}

abstract class FieldStorage {
  Map<String, dynamic> toJson() {
    return {"type": dataType.id};
  }

  static FieldStorage fromJson(Map<String, dynamic> js) {
    FieldStorageType type = FieldStorageType.valueOf(js['type']);
    var store = type.init();
    store.decode(js);

    return store;
  }

  void decode(Map<String, dynamic> js);

  FieldStorageType get dataType;
}

class FieldRegistry {
  static final Map<String, FieldStorage> _registry = {};

  static void fromJson(Map<String, dynamic> js) {}
}

enum FieldStorageType {
  Text(0),
  Color(1),
  Date(2),
  Number(3),
  Boolean(4);

  const FieldStorageType(int id) : _id = id;

  final int _id;

  int get id => _id;
  static FieldStorageType valueOf(int id) {
    return values.where((x) => x.id == id).firstOrNull ?? FieldStorageType.Text;
  }

  FieldStorage init() {
    if (this == Text) {
      return TextFieldStorage();
    } else if (this == Color) {
      return ColorFieldStorage();
    } else if (this == Date) {
      return DateFieldStorage();
    } else if (this == Number) {
      return NumberFieldStorage();
    } else {
      return BooleanFieldStorage();
    }
  }
}

class TextFieldStorage extends FieldStorage {
  String _data = "";
  TextEditingController controller = TextEditingController();
  String get data => controller.text;

  @override
  FieldStorageType get dataType => FieldStorageType.Text;

  @override
  Map<String, dynamic> toJson() {
    var m = super.toJson();
    _data = controller.text;
    m.addAll({"data": _data});

    return m;
  }

  @override
  void decode(Map<String, dynamic> js) {
    _data = js['data'];
    controller.text = _data;
  }
}

class BooleanFieldStorage extends FieldStorage {
  bool data = false;

  @override
  FieldStorageType get dataType => FieldStorageType.Boolean;

  @override
  Map<String, dynamic> toJson() {
    var m = super.toJson();
    m.addAll({"data": data});

    return m;
  }

  @override
  void decode(Map<String, dynamic> js) {
    data = js['data'];
  }
}

class DateFieldStorage extends FieldStorage {
  int date = 0;
  TextEditingController controller = TextEditingController();
  String get data => controller.text;
  String get formattedDate => _getFormatted();

  String _getFormatted() {
    List<String> parts = controller.text.split('/');

    String formatted =
        "${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}";

    return formatted;
  }

  @override
  FieldStorageType get dataType => FieldStorageType.Date;

  @override
  void decode(Map<String, dynamic> js) {
    date = js['data'];

    DateTime dt = TimeUtils.parseTimestamp(date);
    controller.text = "${dt.month}/${dt.day}/${dt.year}";

    print(js);
  }

  @override
  Map<String, dynamic> toJson() {
    var m = super.toJson();
    String formatted = formattedDate;

    DateTime dt = DateTime.parse(formatted);
    int ret = (dt.millisecondsSinceEpoch / 1000).round();
    date = ret;

    m.addAll({"data": date});

    return m;
  }
}

class NumberFieldStorage extends FieldStorage {
  TextEditingController controller = TextEditingController();
  String get text => controller.text;
  int get data => int.parse(text);

  @override
  FieldStorageType get dataType => FieldStorageType.Number;

  @override
  void decode(Map<String, dynamic> js) {
    controller.text = "${js['data'] ?? 0}";
  }

  @override
  Map<String, dynamic> toJson() {
    var m = super.toJson();
    m.addAll({"data": data});

    return m;
  }
}

class ColorFieldStorage extends FieldStorage {
  Color data = Color.fromARGB(0, 0, 0, 0);

  @override
  FieldStorageType get dataType => FieldStorageType.Color;

  @override
  Map<String, dynamic> toJson() {
    var m = super.toJson();
    m.addAll({"data": Color2List(data)});

    return m;
  }

  @override
  void decode(Map<String, dynamic> js) {
    data = ColorFromList(js['data']);
  }
}

class _alterFieldData extends State<AlterFieldData> {
  Map<String, Object> controlHolders = {};

  _alterFieldData();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.type == FieldType.PlainText ||
        widget.type == FieldType.Markdown ||
        widget.type == FieldType.Description ||
        widget.type == FieldType.Pronouns) {
      if (widget.data.data["type"] != FieldStorageType.Text.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {"type": FieldStorageType.Text.id, "data": ""};
      }
      FieldStorage store = FieldStorage.fromJson(widget.data.data);

      controlHolders[widget.data.id.toString()] = store;
    } else if (widget.type == FieldType.Color ||
        widget.type == FieldType.ColorSys) {
      if (widget.data.data["type"] != FieldStorageType.Color.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {
          "type": FieldStorageType.Color.id,
          "data": [255, 0, 0, 0],
        };
      }
      FieldStorage store = FieldStorage.fromJson(widget.data.data);

      controlHolders[widget.data.id.toString()] = store;
    } else if (widget.type == FieldType.Date) {
      if (widget.data.data["type"] != FieldStorageType.Date.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {"type": FieldStorageType.Date.id, "data": 0};
      }

      FieldStorage store = FieldStorage.fromJson(widget.data.data);
      controlHolders[widget.data.id.toString()] = store;
    } else if (widget.type == FieldType.Number) {
      if (widget.data.data["type"] != FieldStorageType.Number.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {"type": FieldStorageType.Number.id, "data": 0};
      }

      FieldStorage store = FieldStorage.fromJson(widget.data.data);
      controlHolders[widget.data.id.toString()] = store;
    } else if (widget.type == FieldType.Boolean) {
      if (widget.data.data["type"] != FieldStorageType.Boolean.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {"type": FieldStorageType.Boolean.id, "data": false};
      }

      FieldStorage store = FieldStorage.fromJson(widget.data.data);
      controlHolders[widget.data.id.toString()] = store;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FieldType.Pronouns:
      case FieldType.PlainText:
        {
          if (!widget.preview) {
            return TextField(
              controller:
                  (controlHolders[widget.data.id.toString()]
                          as TextFieldStorage)
                      .controller,
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) {
                TextFieldStorage tfs =
                    (controlHolders[widget.data.id.toString()]
                        as TextFieldStorage);

                widget.alter.addOrUpdateField(
                  FieldData(id: widget.data.id, data: tfs.toJson()),
                );

                setState(() {});
              },
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            );
          } else {
            return ListTile(
              title: Text(
                (controlHolders[widget.data.id] as TextFieldStorage)
                    .controller
                    .text,
              ),
            );
          }
        }
      case FieldType.Color:
      case FieldType.ColorSys:
        {
          // Both color and Color System have the same controls for editing. So we'll just preserve that here, and reduce the redundancy.
          return ListTile(
            leading: Icon(
              Icons.circle,
              color:
                  (controlHolders[widget.data.id.toString()]
                          as ColorFieldStorage)
                      .data,
            ),
            title: Text(widget.preview ? "Color" : "Pick A Color"),
            subtitle: Text(
              widget.preview
                  ? "#${colorToHex((controlHolders[widget.data.id] as ColorFieldStorage).data)}"
                  : "Tap here to change the color selection",
            ),
            onTap: () async {
              if (widget.preview) {
                return;
              }
              ColorFieldStorage Cfs =
                  controlHolders[widget.data.id.toString()]
                      as ColorFieldStorage;
              var a = AlertDialog(
                title: Text("Pick A Color"),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      widget.alter.addOrUpdateField(
                        FieldData(id: widget.data.id, data: Cfs.toJson()),
                      );
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: Text("Confirm"),
                  ),
                ],
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: Cfs.data,
                    hexInputBar: true,
                    onColorChanged: (Cv) {
                      Cfs.data = Cv;

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
              widget.preview
                  ? Card(
                      child: SingleChildScrollView(
                        child: MarkdownWidget(
                          data:
                              (controlHolders[widget.data.id.toString()]
                                      as TextFieldStorage)
                                  .data,
                          shrinkWrap: true,
                        ),
                      ),
                    )
                  : TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 4,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller:
                          (controlHolders[widget.data.id.toString()]
                                  as TextFieldStorage)
                              .controller,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (value) {
                        var tfs =
                            (controlHolders[widget.data.id.toString()]
                                as TextFieldStorage);

                        widget.alter.addOrUpdateField(
                          FieldData(id: widget.data.id, data: tfs.toJson()),
                        );

                        setState(() {});
                      },
                    ),
            ],
          );
        }
      case FieldType.Date:
        {
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.cake),
                title: Text(
                  (controlHolders[widget.data.id.toString()]
                          as DateFieldStorage)
                      .data,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (bldr) {
                      return CupertinoDatePicker(
                        onDateTimeChanged: (dt) {
                          var tfs =
                              (controlHolders[widget.data.id.toString()]
                                  as DateFieldStorage);
                          tfs.controller.text =
                              "${dt.month}/${dt.day}/${dt.year}";

                          widget.alter.addOrUpdateField(
                            FieldData(id: widget.data.id, data: tfs.toJson()),
                          );

                          setState(() {});
                        },
                        maximumDate: DateTime(2500),
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: DateTime.parse(
                          (controlHolders[widget.data.id.toString()]
                                  as DateFieldStorage)
                              .formattedDate,
                        ),
                      );
                    },
                  );

                  return;
                },
              ),
            ],
          );
        }
      case FieldType.Number:
        {
          return TextField(
            controller:
                (controlHolders[widget.data.id.toString()]
                        as NumberFieldStorage)
                    .controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
              NumberFieldStorage store =
                  controlHolders[widget.data.id.toString()]
                      as NumberFieldStorage;
              store.controller.text = "${store.data}";
              setState(() {});
            },
            onChanged: (value) {
              NumberFieldStorage store =
                  controlHolders[widget.data.id.toString()]
                      as NumberFieldStorage;
              store.controller.text = "${store.data}";

              NumberFieldStorage tfs =
                  (controlHolders[widget.data.id.toString()]
                      as NumberFieldStorage);

              widget.alter.addOrUpdateField(
                FieldData(id: widget.data.id, data: tfs.toJson()),
              );

              setState(() {});
            },
          );
        }
      case FieldType.Boolean:
        {
          return CheckboxListTile(
            title: Text(widget.fieldName),
            value:
                (controlHolders[widget.data.id.toString()]
                        as BooleanFieldStorage)
                    .data,
            onChanged: (B) {
              bool x = B ?? false;
              (controlHolders[widget.data.id.toString()] as BooleanFieldStorage)
                      .data =
                  x;

              widget.alter.addOrUpdateField(
                FieldData(
                  id: widget.data.id,
                  data:
                      (controlHolders[widget.data.id.toString()]
                              as BooleanFieldStorage)
                          .toJson(),
                ),
              );

              setState(() {});
            },
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
  String alterId;
  Alter instance;

  EditAlterArguments({required this.alterId, required this.instance});
}
