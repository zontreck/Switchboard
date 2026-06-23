import 'dart:io';

import 'package:flutter/material.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:liquid_glass_widgets/widgets/feedback/glass_progress_indicator.dart';
import 'package:switchboard/dart/octocon_format.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/editAlter.dart';
import 'package:switchboard/sb.dart';
import 'package:synchronized/synchronized.dart';

class OctoconMigrationProgressPage extends StatefulWidget {
  OctoconMigrationProgressPage({super.key});

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
  static Map<int, UUID> alterIDMap = {};
  static Map<String, UUID> fieldIDMap = {};
  static Lock lock =
      Lock(); // Protects the task scheduling functions from double executions.
  static String statusMessage = "Spooling up migration systems...";
  static String errorMessage =
      "*ERROR*: There was a problem with upload of the profile picture. ";
  static int cur = -1;
  static int max = 100;
  static S2CFieldsResponse? allFields;
  static void Function() refreshView = () {};

  static double getProgress() {
    int percent = getPercent();
    return percent / 100;
  }

  static int getPercent() {
    return (cur * 100 / max).round();
  }
}

enum ImportState { alters, fronting, fields, fieldData, completed }

class _migrate extends State<OctoconMigrationProgressPage> {
  @override
  void initState() {
    super.initState();
    _mem.refreshView = () {
      setState(() {});
    };
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
      default:
        {
          // complete!
          return MigrateCompleteView();
        }
    }
  }
}

class MigrateAltersView extends StatefulWidget {
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
        try {
          await doMigrate();
          _mem.errorMessage = "";
          break;
        } catch (E) {
          tries++;

          _mem.errorMessage = "The request failed, retry: ${tries}/4";
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

    UUID translatedID = _mem.alterIDMap[front.alterId] ?? UUID.ZERO;
    if (translatedID.toString() == UUID.ZERO.toString()) {
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

    Front newFront = Front(id: translatedID, start: asTimestamp, end: endStamp);
    int tries = 0;
    while (tries <= 4) {
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
      myField.type == FieldType.Boolean;
    }

    await NetworkInterface.updateField(myField);
    _mem.fieldIDMap[field.id.toString()] = myField.id;

    _mem.statusMessage = "Created field: ${myField.name}";
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
          storebfs.data = field.value;
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
        _mem.currentPhase = ImportState.completed;
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
          preferredSize: Size.fromHeight(25),
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

class MigrateCompleteView extends StatelessWidget {
  bool firstRun = true;
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
