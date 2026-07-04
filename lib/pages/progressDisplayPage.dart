import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/widgets/feedback/glass_progress_indicator.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/octocon_format.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/sb.dart';
import 'package:synchronized/synchronized.dart';

class OctoconMigrationProgressPage extends StatefulWidget {
  const OctoconMigrationProgressPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _migrate();
  }
}

class _mem {
  // Memory holder for Octocon Migration systems.

  static ImportState currentPhase = ImportState.alters;

  static OctoconMigrationArguments args = OctoconMigrationArguments(
    data: OctoconData(),
  );
  static Map<int, String> alterIDMap = {};
  static Map<String, String> fieldIDMap = {};
  static Map<String, String> tagsIDMap = {};
  static Lock lock =
      Lock(); // Protects the task scheduling functions from double executions.
  static String statusMessage = "Spooling up migration systems...";
  static String errorMessage =
      "*ERROR*: There was a problem with upload of the profile picture. ";
  static int cur = -1;
  static int max = 100;
  static S2CFieldsResponse? allFields;
  static String rootFolderID = UUID_ZERO;
  static void Function() refreshView = () {};

  static double getProgress() {
    int percent = getPercent();
    return percent / 100;
  }

  static int getPercent() {
    return (cur * 100 / max).round();
  }

  static void reset() {
    cur = -1;
    max = 100;
    currentPhase = ImportState.alters;
    alterIDMap = {};
    args = OctoconMigrationArguments(data: OctoconData());
    fieldIDMap = {};
    tagsIDMap = {};

    statusMessage = "Spooling up migration systems...";
    errorMessage =
        "*ERROR*: There was a problem with upload of the profile picture. ";
    allFields = null;
    rootFolderID = UUID_ZERO;
    refreshView = () {};
  }
}

enum ImportState { alters, fronting, fields, fieldData, tags, completed }

class _migrate extends State<OctoconMigrationProgressPage> {
  @override
  void initState() {
    super.initState();
    _mem.refreshView = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    super.dispose();
    _mem.reset();
  }

  @override
  Widget build(BuildContext context) {
    switch (_mem.currentPhase) {
      case ImportState.alters:
        {
          return MigrateAltersView();
        }
      case ImportState.fronting:
        {
          return MigrateFrontingView();
        }
      case ImportState.fields:
        {
          return MigrateFieldsView();
        }
      case ImportState.fieldData:
        {
          return MigrateFieldDataView();
        }
      case ImportState.tags:
        {
          return MigrateFolders();
        }
      default:
        {
          // complete!
          return MigrateCompleteView();
        }
    }
  }
}

class MigrateAltersView extends StatefulWidget {
  const MigrateAltersView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _mav();
  }
}

class _mav extends State<MigrateAltersView> {
  Future<void> doMigrate() async {
    if (_mem.cur == -1) {
      return;
    }
    List<Field> fields = _mem.allFields!.data;

    OctoconAlter alter = _mem.args.data.alters[_mem.cur];
    _mem.statusMessage = "Create Alter";
    setState(() {});
    Alter newAlter;
    if (_mem.alterIDMap.containsKey(alter.id)) {
      newAlter = (await NetworkInterface.getAlterByID(
        _mem.alterIDMap[alter.id]!,
      )).data!;
    } else {
      var nAlter = await NetworkInterface.makeNewAlter(alter.name);
      newAlter = nAlter.data!;
    }

    _mem.alterIDMap[alter.id] = newAlter.id;

    _mem.statusMessage = "Copying over field data...";
    setState(() {});
    for (var field in fields) {
      if (field.type == FieldType.Description) {
        TextFieldStorage TFS = TextFieldStorage();
        TFS.controller.text = alter.description;
        print("set description to: ${alter.description}");

        newAlter.addOrUpdateField(FieldData(id: field.id, data: TFS.toJson()));
      }
      if (field.type == FieldType.ColorSys) {
        ColorFieldStorage CFS = ColorFieldStorage();
        CFS.data = htmlColorToFlutter(alter.color);
        print("set color to: ${alter.color}");

        newAlter.addOrUpdateField(FieldData(id: field.id, data: CFS.toJson()));
      }
      if (field.type == FieldType.Pronouns) {
        TextFieldStorage TFS = TextFieldStorage();
        TFS.controller.text = alter.pronouns;
        print("set pronouns to: ${alter.pronouns}");

        newAlter.addOrUpdateField(FieldData(id: field.id, data: TFS.toJson()));
      }
    }
    newAlter.subid = alter.id;

    await NetworkInterface.updateAlter(newAlter);

    _mem.statusMessage = "Check for avatar";
    setState(() {});

    if (alter.avatarURL.isNotEmpty) {
      _mem.statusMessage = "Migrating Profile Picture...";
      setState(() {});
      await NetworkInterface.migrateAvatar(alter.avatarURL, newAlter.id);
      newAlter.avatarUrl = newAlter.id.toString();

      await NetworkInterface.updateAlter(newAlter);
      _mem.statusMessage = "Profile Picture Migrated";
      setState(() {});
    }

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    parseArgs();
  }

  Future<void> parseArgs() async {
    if (_mem.cur == -1) {
      _mem.allFields = await NetworkInterface.getDataFields();

      _mem.cur = 0;
      _mem.max = _mem.args.data.alters.length;

      _mem.statusMessage = "";
      _mem.errorMessage = "";

      setState(() {});

      scheduleTask();
    }
  }

  void scheduleTask() {
    if (_mem.currentPhase != ImportState.alters) {
      return; // lock out scheduler!
    }
    _mem.lock.synchronized(() async {
      NetworkCaches.suspendRefresh();
      int tries = 0;
      while (tries <= 4) {
        if (!mounted) {
          return;
        }
        try {
          await doMigrate();
          _mem.errorMessage = "";
          break;
        } catch (E) {
          if (!mounted) {
            return;
          }
          tries++;

          _mem.errorMessage = "The request failed, retry: $tries/4";
          setState(() {});
          sleep(Duration(seconds: 1));
        }
      }

      _mem.cur += 1;

      if (_mem.cur < _mem.max) {
        scheduleTask();
      } else {
        NetworkCaches.resumeRefresh();
        _mem.cur = 0;
        _mem.max = _mem.args.data.fronts.length;
        _mem.currentPhase = ImportState.fronting;
        _mem.statusMessage = "Migrating fronting history";
        Switchboard.rebuild();
        _mem.refreshView();
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _mem.args =
        ModalRoute.of(context)!.settings.arguments as OctoconMigrationArguments;
    parseArgs();

    // This can never be called without ActionArguments

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text(
                "Migrating Octocon Data\nAlters",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            if (_mem.cur < _mem.max)
              Text(
                "We're working on your data migration...",
                style: TextStyle(fontSize: 22),
              ),

            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "Currently Migrating: ${_mem.args.data.alters[_mem.cur].name}",
                style: TextStyle(fontSize: 22),
              ),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Image.network(
                _mem.args.data.alters[_mem.cur].avatarURL.isNotEmpty
                    ? _mem.args.data.alters[_mem.cur].avatarURL
                    : "${getAPIServerURL()}/avatar/null",
                width: 175,
                height: 175,
              ),
            Divider(),
            SizedBox(height: 25),
            Text(_mem.statusMessage, style: TextStyle(fontSize: 20)),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              GlassProgressIndicator.linear(value: _mem.getProgress()),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "${_mem.cur} / ${_mem.max} - ${_mem.getPercent()}%",
                style: TextStyle(fontSize: 22),
              ),
            SizedBox(height: 50),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                _mem.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MigrateFrontingView extends StatefulWidget {
  const MigrateFrontingView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _migrateFronting();
  }
}

class _migrateFronting extends State<MigrateFrontingView> {
  bool helloWorld = true;

  Future<void> migrateFrontHistory() async {
    List<OctoconFront> fronts = _mem.args.data.fronts;
    OctoconFront front = fronts[_mem.cur];

    String translatedID = _mem.alterIDMap[front.alterId] ?? UUID_ZERO;
    if (translatedID == UUID_ZERO) {
      _mem.errorMessage =
          "*FATAL*\nThe process unexpectedly could not find the correct alter";
      _mem.statusMessage = "";
      setState(() {});
      return;
    } else {
      _mem.errorMessage = "";
    }

    DateTime start = front.timeStart;
    int asTimestamp = (start.millisecondsSinceEpoch / 1000).round();
    DateTime end = front.timeEnd ?? start;
    int endStamp = (end.millisecondsSinceEpoch / 1000).round();

    Front newFront = Front(
      alterId: translatedID,
      start: asTimestamp,
      end: endStamp,
    );
    int tries = 0;
    while (tries <= 4) {
      if (!mounted) {
        return;
      }
      try {
        var rep = await NetworkInterface.insertFronter(newFront);
        if (rep.success) {
          _mem.statusMessage = "Uploaded fronter";
          setState(() {});
        }
        break;
      } catch (E) {
        tries++;
        setState(() {});
      }
    }
  }

  void scheduleFronts() {
    if (_mem.currentPhase != ImportState.fronting) {
      print("schedule lock for fronting, phase mismatch: ${_mem.currentPhase}");
      return; // lock out scheduler!
    }
    _mem.lock.synchronized(() async {
      NetworkCaches.suspendRefresh();
      await migrateFrontHistory();
      _mem.cur += 1;
      if (_mem.cur < _mem.max) {
        scheduleFronts();
      } else {
        _mem.currentPhase = ImportState.fields;
        _mem.cur = 0;
        _mem.max = _mem.args.data.user.fields.length;
        _mem.statusMessage = "Migrating custom fields";
        NetworkCaches.resumeRefresh();
        Switchboard.rebuild();
        _mem.refreshView();
      }

      setState(() {});
    });
  }

  Future<void> parseArgs() async {
    if (helloWorld) {
      helloWorld = false;
      _mem.allFields = await NetworkInterface.getDataFields();

      _mem.cur = 0;
      _mem.max = _mem.args.data.fronts.length;

      _mem.statusMessage = "";
      _mem.errorMessage = "";

      setState(() {});

      scheduleFronts();
    }
  }

  @override
  Widget build(BuildContext context) {
    parseArgs();
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text(
                "Migrating Octocon Data\nFronting History",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            if (_mem.cur < _mem.max)
              Text(
                "We're working on your data migration...",
                style: TextStyle(fontSize: 22),
              ),
            Text(
              "Your front history is being uploaded... Please be patient",
              style: TextStyle(fontSize: 22),
            ),
            Divider(),
            SizedBox(height: 25),
            Text(_mem.statusMessage, style: TextStyle(fontSize: 20)),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              GlassProgressIndicator.linear(value: _mem.getProgress()),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "${_mem.cur} / ${_mem.max} - ${_mem.getPercent()}%",
                style: TextStyle(fontSize: 22),
              ),
            SizedBox(height: 50),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                _mem.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MigrateFieldsView extends StatefulWidget {
  const MigrateFieldsView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _mfv();
  }
}

class _mfv extends State<MigrateFieldsView> {
  Future<void> migrateField() async {
    List<OctoconField> fields = _mem.args.data.user.fields;
    if (_mem.cur == fields.length) {
      return;
    }
    OctoconField field = fields[_mem.cur];

    var srvField = await NetworkInterface.newField(field.name);
    Field myField = srvField.data;
    if (field.type == "text") {
      myField.type = FieldType.Markdown;
    } else if (field.type == "number") {
      myField.type = FieldType.Number;
    } else if (field.type == "boolean") {
      myField.type = FieldType.Boolean;
    }

    await NetworkInterface.updateField(myField);
    _mem.fieldIDMap[field.id.toString()] = myField.id;

    _mem.statusMessage = "Created field: ${myField.name},\n${myField.toJson()}";
  }

  void scheduleFields() {
    if (_mem.currentPhase != ImportState.fields) {
      return; // lock out scheduler!
    }
    _mem.lock.synchronized(() async {
      await migrateField();
      _mem.cur += 1;

      if (_mem.cur < _mem.max) {
        scheduleFields();
      } else {
        _mem.currentPhase = ImportState.fieldData;
        _mem.cur = 0;
        _mem.max = _mem.args.data.alters.length;
        //scheduleFieldData();
        Switchboard.rebuild();
        _mem.refreshView();
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _mem.cur = -1;
  }

  Future<void> parseArgs() async {
    if (_mem.cur == -1) {
      _mem.allFields = await NetworkInterface.getDataFields();

      _mem.cur = 0;
      _mem.max = _mem.args.data.user.fields.length;

      _mem.statusMessage = "";
      _mem.errorMessage = "";

      setState(() {});

      scheduleFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    parseArgs();

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text(
                "Migrating Octocon Data\nCustom Data Fields",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            if (_mem.cur < _mem.max)
              Text(
                "We're working on your data migration...",
                style: TextStyle(fontSize: 22),
              ),
            Text(
              "Your custom fields are being uploaded... Please be patient",
              style: TextStyle(fontSize: 22),
            ),
            Divider(),
            SizedBox(height: 25),
            Text(_mem.statusMessage, style: TextStyle(fontSize: 20)),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              GlassProgressIndicator.linear(value: _mem.getProgress()),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "${_mem.cur} / ${_mem.max} - ${_mem.getPercent()}%",
                style: TextStyle(fontSize: 22),
              ),
            SizedBox(height: 50),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                _mem.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MigrateFieldDataView extends StatefulWidget {
  const MigrateFieldDataView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _mfdv();
  }
}

class _mfdv extends State<MigrateFieldDataView> {
  @override
  void initState() {
    super.initState();
    _mem.cur = -1;
  }

  Future<void> migrateFieldData() async {
    OctoconAlter alter = _mem.args.data.alters[_mem.cur];
    var realAlter = await NetworkInterface.getAlterByID(
      _mem.alterIDMap[alter.id]!,
    );
    Alter myAlter = realAlter.data!;

    _mem.statusMessage = "Inserting new data...";

    for (var field in alter.fields) {
      var newField = _mem.fieldIDMap[field.id.toString()];
      if (newField != null) {
        // get the real alter instance
        String fieldType = _mem.args.data.user.fields
            .where((x) => x.id.toString() == field.id.toString())
            .first
            .type;
        FieldStorage store = TextFieldStorage();
        if (fieldType == "text") {
          store = TextFieldStorage();
          var storetfs = store as TextFieldStorage;
          storetfs.controller.text = field.value;
        } else if (fieldType == "number") {
          store = NumberFieldStorage();
          var storenfs = store as NumberFieldStorage;
          storenfs.controller.text = field.value;
        } else if (fieldType == "boolean") {
          store = BooleanFieldStorage();
          var storebfs = store as BooleanFieldStorage;
          storebfs.data = bool.parse(field.value);
        }

        myAlter.addOrUpdateField(FieldData(id: newField, data: store.toJson()));
      }
    }

    await NetworkInterface.updateAlter(myAlter);
  }

  void scheduleFieldData() {
    if (_mem.currentPhase != ImportState.fieldData) {
      return; // lock out scheduler!
    }
    _mem.lock.synchronized(() async {
      int tries = 0;
      while (tries <= 4) {
        if (!mounted) {
          return;
        }
        try {
          await migrateFieldData();
          break;
        } catch (E) {
          tries++;
        }
      }
      if (tries > 4) {
        throw Exception("Failed to update field data. unknown error.");
      }
      _mem.cur++;

      setState(() {});

      if (_mem.cur < _mem.max) {
        scheduleFieldData();
      } else {
        _mem.currentPhase = ImportState.tags;

        _mem.cur = 0;
        _mem.max = _mem.args.data.tags.length;

        Switchboard.rebuild();

        _mem.refreshView();
      }
    });
  }

  Future<void> parseArgs() async {
    if (_mem.cur == -1) {
      _mem.allFields = await NetworkInterface.getDataFields();

      _mem.cur = 0;
      _mem.max = _mem.args.data.alters.length;

      _mem.statusMessage = "";
      _mem.errorMessage = "";

      setState(() {});

      scheduleFieldData();
    }
  }

  @override
  Widget build(BuildContext context) {
    parseArgs();

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text(
                "Migrating Octocon Data\nAlter Field Data",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            if (_mem.cur < _mem.max)
              Text(
                "We're working on your data migration...",
                style: TextStyle(fontSize: 22),
              ),
            Text(
              "Your custom field data per alter is being uploaded... Please be patient",
              style: TextStyle(fontSize: 22),
            ),

            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "Currently Migrating: ${_mem.args.data.alters[_mem.cur].name}",
                style: TextStyle(fontSize: 22),
              ),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Image.network(
                _mem.args.data.alters[_mem.cur].avatarURL.isNotEmpty
                    ? _mem.args.data.alters[_mem.cur].avatarURL
                    : "${getAPIServerURL()}/avatar/null",
                width: 175,
                height: 175,
              ),
            Divider(),
            SizedBox(height: 25),
            Text(_mem.statusMessage, style: TextStyle(fontSize: 20)),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              GlassProgressIndicator.linear(value: _mem.getProgress()),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "${_mem.cur} / ${_mem.max} - ${_mem.getPercent()}%",
                style: TextStyle(fontSize: 22),
              ),
            SizedBox(height: 50),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                _mem.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MigrateFolders extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _mfldr();
  }
}

class _mfldr extends State<MigrateFolders> {
  @override
  void initState() {
    super.initState();
    _mem.cur = -1;
  }

  Future<void> migrateFolder() async {
    // This migration is done a little bit differently, since we cannot really sort to know parent tags in advance, we must iterate, find eligible tags, then remove them from the queue. Adjust cur and max accordingly.
    OctoconTag tag = _mem.args.data.tags[_mem.cur];

    bool hasMappedID = false;

    if (tag.parentTagId == UUID_ZERO) {
      hasMappedID = true;
    } else {
      if (_mem.tagsIDMap.containsKey(tag.parentTagId)) {
        hasMappedID = true;
      }
    }

    if (hasMappedID) {
      _mem.statusMessage = "Creating folder...";
      setState(() {});
      var newFolderReply = await NetworkInterface.createFolder(tag.name);
      if (_mem.rootFolderID == UUID_ZERO) {
        _mem.statusMessage =
            "Retrieving User's Root Folder ID from the server...";
        setState(() {});
        var rootReply = await NetworkInterface.getFolderOrItem(UUID_ZERO, true);
        _mem.rootFolderID = rootReply.data.id;
      }
      // Check folder's parent
      if (tag.parentTagId == UUID_ZERO) {
        // Move to the parent folder.
        _mem.statusMessage = "Moving new folder into place...";
        var moveReply = await NetworkInterface.addToFolderContents(
          newFolderReply.data.id,
          _mem.rootFolderID,
          tag.name,
          true,
          false,
          false,
          false,
        );
      } else {
        _mem.statusMessage = "Moving new folder into place...";
        var moveReply = await NetworkInterface.addToFolderContents(
          newFolderReply.data.id,
          _mem.tagsIDMap[tag.parentTagId]!,
          tag.name,
          true,
          false,
          false,
          false,
        );
      }
      // Add any alters to the newly created folder!
      for (var alter in tag.alters) {
        // Get the SB ID
        String sbID = _mem.alterIDMap[alter]!;
        _mem.statusMessage = "Adding alters to new folder...";
        setState(() {});

        await NetworkInterface.addToFolderContents(
          sbID,
          newFolderReply.data.id,
          sbID,
          false,
          true,
          false,
          false,
        );
      }

      _mem.args.data.tags.remove(tag);
      _mem.cur = 0;
      _mem.max = _mem.args.data.tags.length;
      _mem.tagsIDMap[tag.id] = newFolderReply.data.id;
    } else {
      _mem.cur++;
    }
  }

  void scheduleFolder() {
    if (_mem.currentPhase != ImportState.tags) {
      return; // lock out scheduler!
    }
    _mem.lock.synchronized(() async {
      int tries = 0;
      while (tries <= 4) {
        if (!mounted) {
          return;
        }
        try {
          await migrateFolder();
          break;
        } catch (E) {
          tries++;
        }
      }
      if (tries > 4) {
        throw Exception("Failed to update folder data. unknown error.");
      }

      setState(() {});

      if (_mem.cur < _mem.max) {
        scheduleFolder();
      } else {
        _mem.currentPhase = ImportState.completed;

        Switchboard.rebuild();

        _mem.refreshView();
      }
    });
  }

  Future<void> parseArgs() async {
    if (_mem.cur == -1) {
      _mem.allFields = await NetworkInterface.getDataFields();

      _mem.cur = 0;
      _mem.max = _mem.args.data.tags.length;

      _mem.statusMessage = "";
      _mem.errorMessage = "";

      setState(() {});

      scheduleFolder();
    }
  }

  @override
  Widget build(BuildContext context) {
    parseArgs();

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text(
                "Migrating Octocon Data\nTags",
                style: TextStyle(fontSize: 22),
              ),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            if (_mem.cur < _mem.max)
              Text(
                "We're working on your data migration...",
                style: TextStyle(fontSize: 22),
              ),
            Text(
              "Your tags / folders are now being created and uploaded...\n\n> Switchboard refers to Tags a bit differently than Octocon did. We refer to them as Folders. They currently are experimental, and function more like a filesystem than a tag. The feature can be revised and changed later.",
              style: TextStyle(fontSize: 22),
            ),

            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "Currently Migrating: ${_mem.args.data.tags[_mem.cur].name}",
                style: TextStyle(fontSize: 22),
              ),
            Divider(),
            SizedBox(height: 25),
            Text(_mem.statusMessage, style: TextStyle(fontSize: 20)),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              GlassProgressIndicator.linear(value: _mem.getProgress()),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                "${_mem.cur} / ${_mem.max} - ${_mem.getPercent()}%",
                style: TextStyle(fontSize: 22),
              ),
            SizedBox(height: 50),
            if (_mem.cur >= 0 && _mem.cur < _mem.max)
              Text(
                _mem.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MigrateCompleteView extends StatelessWidget {
  bool firstRun = true;

  MigrateCompleteView({super.key});
  @override
  Widget build(BuildContext context) {
    if (firstRun) {
      firstRun = false;
      flushImageCaches();

      Future.delayed(Duration(seconds: 5), () {
        popUntil("/account", context);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text("Switchboard")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            Center(
              child: Text(
                "Migration Completed\n\nYou will be taken back to the main application screen shortly.",
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OctoconMigrationArguments {
  OctoconData data;

  OctoconMigrationArguments({required this.data});
}
