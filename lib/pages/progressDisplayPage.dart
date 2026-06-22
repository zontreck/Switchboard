import 'package:flutter/material.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:liquid_glass_widgets/widgets/feedback/glass_progress_indicator.dart';
import 'package:switchboard/dart/octocon_format.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/editAlter.dart';

class OctoconMigrationProgressPage extends StatefulWidget {
  const OctoconMigrationProgressPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _action();
  }
}

class _action extends State<OctoconMigrationProgressPage> {
  OctoconMigrationArguments args = OctoconMigrationArguments(
    data: OctoconData(),
  );
  int cur = -1;
  int max = 100;
  S2CFieldsResponse? allFields;
  String statusMessage = "Spooling up migration systems...";
  String errorMessage =
      "*ERROR*: There was a problem with upload of the profile picture. ";
  bool scheduled = false;
  Map<int, UUID> alterIDMap = {};
  int phase = 0;

  Future<void> doMigrate() async {
    if (cur == -1) {
      return;
    }
    List<Field> fields = allFields!.data;

    OctoconAlter alter = args.data.alters[cur];
    statusMessage = "Create Alter";
    setState(() {});
    var nAlter = await NetworkInterface.makeNewAlter(alter.name);
    Alter newAlter = nAlter.data!;
    alterIDMap[alter.id] = newAlter.id;

    statusMessage = "Copying over field data...";
    setState(() {});
    for (var field in fields) {
      if (field.type == FieldType.Description) {
        TextFieldStorage TFS = TextFieldStorage();
        TFS.controller.text = alter.description;

        newAlter.addOrUpdateField(FieldData(id: field.id, data: TFS.toJson()));
      }
      if (field.type == FieldType.ColorSys) {
        ColorFieldStorage CFS = ColorFieldStorage();
        CFS.data = htmlColorToFlutter(alter.color);

        newAlter.addOrUpdateField(FieldData(id: field.id, data: CFS.toJson()));
      }
      if (field.type == FieldType.Pronouns) {
        TextFieldStorage TFS = TextFieldStorage();
        TFS.controller.text = alter.pronouns;

        newAlter.addOrUpdateField(FieldData(id: field.id, data: TFS.toJson()));
      }
    }

    await NetworkInterface.updateAlter(newAlter);

    statusMessage = "Check for avatar";
    setState(() {});

    if (alter.avatarURL.isNotEmpty) {
      statusMessage = "Migrating Profile Picture...";
      setState(() {});
      await NetworkInterface.migrateAvatar(alter.avatarURL, newAlter.id);
      newAlter.avatarUrl = newAlter.id.toString();

      await NetworkInterface.updateAlter(newAlter);
      statusMessage = "Profile Picture Migrated";
      setState(() {});
    }

    setState(() {});
  }

  Future<void> migrateFrontHistory() async {
    List<OctoconFront> fronts = args.data.fronts;
    OctoconFront front = fronts[cur];

    UUID translatedID = alterIDMap[front.alterId] ?? UUID.ZERO;
    if (translatedID.toString() == UUID.ZERO.toString()) {
      errorMessage =
          "*FATAL*\nThe process unexpectedly could not find the correct alter";
      statusMessage = "";
      setState(() {});
      return;
    } else {
      errorMessage = "";
    }

    DateTime start = front.timeStart;
    int asTimestamp = (start.millisecondsSinceEpoch / 1000).round();
    DateTime end = front.timeEnd ?? start;
    int endStamp = (end.millisecondsSinceEpoch / 1000).round();

    Front newFront = Front(id: translatedID, start: asTimestamp, end: endStamp);
    var rep = await NetworkInterface.insertFronter(newFront);
    if (rep.success) {
      statusMessage = "Uploaded fronter";
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    parseArgs();
  }

  Future<void> parseArgs() async {
    if (cur == -1) {
      allFields = await NetworkInterface.getDataFields();

      cur = 0;
      max = args.data.alters.length;

      statusMessage = "";
      errorMessage = "";

      setState(() {});

      scheduleTask();
    }
  }

  void scheduleTask() {
    if (scheduled) {
      return; // Only allow one task
    }
    scheduled = true;
    Future.delayed(Duration(milliseconds: 1000), () async {
      await doMigrate();

      cur += 1;

      if (cur < max) {
        scheduled = false;
        scheduleTask();
      } else {
        scheduled = false;
        cur = 0;
        max = args.data.fronts.length;
        phase = 1;
        statusMessage = "Migrating fronting history";
        setState(() {});
        scheduleFronts();
      }

      setState(() {});
    });
  }

  void scheduleFronts() {
    if (scheduled) {
      return;
    }
    scheduled = true;
    Future.delayed(Duration(seconds: 1), () async {
      await migrateFrontHistory();
      cur += 1;
      if (cur < max) {
        scheduled = false;
        scheduleFronts();
      } else {
        flushImageCaches();
        phase = 2;
        Future.delayed(Duration(seconds: 5), () {
          popUntil("/account", context);
        });
      }

      setState(() {});
    });
  }

  double getProgress() {
    int percent = getPercent();
    return percent / 100;
  }

  int getPercent() {
    return (cur * 100 / max).round();
  }

  @override
  Widget build(BuildContext context) {
    args =
        ModalRoute.of(context)!.settings.arguments as OctoconMigrationArguments;
    parseArgs();

    // This can never be called without ActionArguments

    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("Migrating Octocon Data", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            if (cur < max && phase < 2)
              Text(
                "We're working on your data migration...",
                style: TextStyle(fontSize: 22),
              ),

            if (cur >= max)
              Text(
                "Migration Completed!\n\nWe'll take you back to the main screen in a moment. Please be aware that this feature is still experimental, and there may be some errors.",
                style: TextStyle(fontSize: 22),
              ),
            if (cur >= 0 && cur < max && phase == 0)
              Text(
                "Currently Migrating: ${args.data.alters[cur].name}",
                style: TextStyle(fontSize: 22),
              ),
            if (cur >= 0 && cur < max && phase == 0)
              Image.network(
                args.data.alters[cur].avatarURL.isNotEmpty
                    ? args.data.alters[cur].avatarURL
                    : "${getAPIServerURL()}/avatar/null",
                width: 175,
                height: 175,
              ),
            if (phase == 1)
              Text(
                "Your front history is being uploaded... Please be patient",
                style: TextStyle(fontSize: 22),
              ),
            Divider(),
            SizedBox(height: 25),
            Text(statusMessage, style: TextStyle(fontSize: 20)),
            if (cur >= 0 && cur < max)
              GlassProgressIndicator.linear(value: getProgress()),
            if (cur >= 0 && cur < max)
              Text(
                "$cur / $max - ${getPercent()}%",
                style: TextStyle(fontSize: 22),
              ),
            SizedBox(height: 50),
            if (cur >= 0 && cur < max)
              Text(
                errorMessage,
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

class OctoconMigrationArguments {
  OctoconData data;

  OctoconMigrationArguments({required this.data});
}
