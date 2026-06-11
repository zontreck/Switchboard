import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:libacflutter/Prompt.dart';
import 'package:libacflutter/utils/colorHelpers.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
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
  BannerAd? _bannerAd;
  double adHeight = 0;

  Future<BannerAd?> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );

    if (size == null) {
      // Unable to get width of anchored banner.
      _bannerAd = null;
      return null;
    }

    bool optIn = (await getAdsOptIn())!;
    if (!optIn) {
      _bannerAd = null;
      throw Exception("Opt Out");
    }

    if (_bannerAd != null) return _bannerAd;

    var b = BannerAd(
      adUnitId: "ca-app-pub-3401801111605896/3640268235",
      request: const AdRequest(nonPersonalizedAds: true),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Called when an ad is successfully received.
          debugPrint("Ad was loaded.");
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          // Called when an ad request failed.
          debugPrint("Ad failed to load with error: $err");
          ad.dispose();
        },
      ),
    );
    await b.load();
    return b;
  }

  @override
  void didChangeDependencies() {
    updateAdHeight();

    super.didChangeDependencies();
  }

  Future<void> updateAdHeight() async {
    double adHeight = await getAdHeight();
    this.adHeight = adHeight;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as EditAlterArguments;
    alterId = args.alterId;
    alter = args.instance;
    alterNameController.text = alter.name;

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard - Edit Alter"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(adHeight + 0),
          child: FutureBuilder(
            future: _loadAd(),
            builder: (bldr, snap) {
              updateAdHeight();
              if (snap.hasError) {
                return SizedBox();
              }
              if (!snap.hasData) {
                return CircularProgressIndicator();
              } else {
                if (snap.data == null) {
                  return SizedBox();
                } else {
                  return Expanded(child: AdWidget(ad: snap.data!));
                }
              }
            },
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          alter.name = alterNameController.text;
          print(alter.encode());

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
                    width: 200,
                    height: 200,
                  ),
                  onTap: () {
                    print("Display image customize menu");

                    showCupertinoDialog(
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
                                FilePickerResult? result =
                                    await FilePicker.pickFiles(
                                      allowMultiple: false,
                                      allowedExtensions: [
                                        "png",
                                        "jpg",
                                        "webp",
                                        "jpeg",
                                      ],
                                      type: FileType.custom,
                                    );

                                if (result != null) {
                                  File file = File(result.files.single.path!);
                                  var byteStream = await file.readAsBytes();
                                  var b64Img = base64Encoder.base64EncBytes(
                                    byteStream,
                                  );
                                  await NetworkInterface.updateAvatar(
                                    alter,
                                    b64Img,
                                  );
                                  alter.avatarUrl = alter.id.toString();
                                  await NetworkInterface.updateAlter(alter);

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
                                // update the alter's preferred image URL!
                                alter.avatarUrl = url;
                                await NetworkInterface.updateAlter(alter);

                                Navigator.pop(context);
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
                                  alter.avatarUrl = UUID.ZERO.toString();
                                  await NetworkInterface.updateAlter(alter);
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
                  },
                ),
              ),
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

  S2CFieldsResponse? fields;

  Future<Widget?> getFieldList(Alter alter) async {
    List<Widget> widgets = [];
    fields ??= S2CFieldsResponse(
      id: UUID.ZERO,
      path: "/",
      reason: "reason",
      success: false,
      type: "",
      data: [],
    );

    if (fields!.reason == "reason") {
      fields!.reason = "NUL";
      fields = await NetworkInterface.getDataFields();
    }

    List<Field> fieldVals = fields!.data;
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

  AlterFieldData({
    super.key,
    required this.data,
    required this.type,
    required this.alter,
    required this.order,
  });

  @override
  State<StatefulWidget> createState() {
    return _alterFieldData();
  }
}

abstract class _FieldStorage {
  Map<String, dynamic> toJson() {
    return {"type": dataType.id};
  }

  static _FieldStorage fromJson(Map<String, dynamic> js) {
    FieldStorageType type = FieldStorageType.valueOf(js['type']);
    var store = type.init();
    store.decode(js);

    return store;
  }

  void decode(Map<String, dynamic> js);

  FieldStorageType get dataType;
}

class FieldRegistry {
  static final Map<String, _FieldStorage> _registry = {};

  static void fromJson(Map<String, dynamic> js) {}
}

enum FieldStorageType {
  Text(0),
  Color(1),
  Date(2);

  const FieldStorageType(int id) : _id = id;

  final int _id;

  int get id => _id;
  static FieldStorageType valueOf(int id) {
    return values.where((x) => x.id == id).firstOrNull ?? FieldStorageType.Text;
  }

  _FieldStorage init() {
    if (this == Text) {
      return TextFieldStorage();
    } else if (this == Color) {
      return ColorFieldStorage();
    } else
      return DateFieldStorage();
  }
}

class TextFieldStorage extends _FieldStorage {
  String _data = "";
  TextEditingController controller = TextEditingController();
  String get data => controller.text;

  /// This flag is used for Markdown previewing only.
  bool preview = false;

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

class DateFieldStorage extends _FieldStorage {
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

class ColorFieldStorage extends _FieldStorage {
  Color data = Colors.white;

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
        widget.type == FieldType.Description) {
      if (widget.data.data["type"] != FieldStorageType.Text.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {"type": FieldStorageType.Text.id, "data": ""};
      }
      _FieldStorage store = _FieldStorage.fromJson(widget.data.data);

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
      _FieldStorage store = _FieldStorage.fromJson(widget.data.data);

      controlHolders[widget.data.id.toString()] = store;
    } else if (widget.type == FieldType.Date) {
      if (widget.data.data["type"] != FieldStorageType.Date.id) {
        widget.data.data = {};
      }

      if (widget.data.data.isEmpty) {
        widget.data.data = {"type": FieldStorageType.Date.id, "data": 0};
      }

      _FieldStorage store = _FieldStorage.fromJson(widget.data.data);
      controlHolders[widget.data.id.toString()] = store;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FieldType.PlainText:
        {
          return TextField(
            controller:
                (controlHolders[widget.data.id.toString()] as TextFieldStorage)
                    .controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
            onChanged: (value) {
              TextFieldStorage tfs =
                  (controlHolders[widget.data.id.toString()]
                      as TextFieldStorage);

              widget.alter.fieldChangeNotifier.data = FieldData(
                id: widget.data.id,
                data: tfs.toJson(),
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
              color:
                  (controlHolders[widget.data.id.toString()]
                          as ColorFieldStorage)
                      .data,
            ),
            title: Text("Pick A Color"),
            subtitle: Text("Tap here to change the color selection"),
            onTap: () async {
              ColorFieldStorage Cfs =
                  controlHolders[widget.data.id.toString()]
                      as ColorFieldStorage;
              var a = AlertDialog(
                title: Text("Pick A Color"),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      widget.alter.fieldChangeNotifier.data = FieldData(
                        id: widget.data.id,
                        data: Cfs.toJson(),
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
              (controlHolders[widget.data.id.toString()] as TextFieldStorage)
                      .preview
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
                      controller:
                          (controlHolders[widget.data.id.toString()]
                                  as TextFieldStorage)
                              .controller,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (value) {
                        var tfs =
                            (controlHolders[widget.data.id.toString()]
                                as TextFieldStorage);

                        widget.alter.fieldChangeNotifier.data = FieldData(
                          id: widget.data.id,
                          data: tfs.toJson(),
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
                  (controlHolders[widget.data.id.toString()]
                              as TextFieldStorage)
                          .preview =
                      !(controlHolders[widget.data.id.toString()]
                              as TextFieldStorage)
                          .preview;

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

                          widget.alter.fieldChangeNotifier.data = FieldData(
                            id: widget.data.id,
                            data: tfs.toJson(),
                          );
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
