import 'dart:convert';

import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/octocon_format.dart';

class Ourcana {
  static OurcanaData decode(Map<String, dynamic> js) {
    return OurcanaData.fromJson(typeCorrectJson(js));
  }

  static String encode(OurcanaData data) {
    return json.encode(data.encode());
  }

  static OctoconData convertToOctocon(OurcanaData dat) {
    OctoconData data = OctoconData();
    data.user = OctoconUser(
      id: dat.system.id,
      description: dat.system.desc,
      fields: [],
      username: dat.system.pkSystemId,
      avatarUrl: dat.system.avatarUrl,
    );

    int p = 0;
    Map<String, int> alterIDMap = {};
    Map<String, int> tagIDMap = {};
    for (var alter in dat.members) {
      alterIDMap[alter.id] = p;

      p++;
    }

    p = 0;
    for (var tag in dat.tags) {
      tagIDMap[tag.id] = p;

      p++;
    }

    for (var alter in dat.members) {
      data.alters.add(
        OctoconAlter(
          id: alterIDMap[alter.id] ?? 0,
          name: alter.name,
          description: alter.desc,
          fields: [],
          color: alter.color,
          avatarURL: alter.avatarUrl,
          discordProxies: [],
          pronouns: alter.pronouns,
          proxyName: alter.name,
        ),
      );
    }
    for (var history in dat.frontHistory) {
      for (var mbr in history.memberIds) {
        data.fronts.add(
          OctoconFront(
            id: history.id,
            comment: "",
            timeEnd: TimeUtils.parseTimestamp(history.endTime!),
            alterId: alterIDMap[mbr]!,
            timeStart: TimeUtils.parseTimestamp(history.startTime),
          ),
        );
      }
    }

    for (var tag in dat.tags) {
      List<int> tagMembers = [];
      for (var entry in dat.members) {
        if (entry.tagIds.contains(tag.id)) {
          tagMembers.add(alterIDMap[entry.id]!);
        }
      }

      data.tags.add(
        OctoconTag(
          id: "${tagIDMap[tag.id]!}",
          name: tag.label,
          description: tag.label,
          color: tag.color,
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          securityLevel: OctoconSecurityLevel.trusted,
          alters: tagMembers,
          parentTagId:
              UUID_ZERO, // Discard structure, for now at least, the format is a bit spaghetti, at least until I have more time to properly sort it out.
        ),
      );
    }

    return data;
  }
}

/// All relevant data for importing from Ourcana
class OurcanaData {
  String format = "ourcana";
  int version = 2;
  DateTime exportedAt;
  OurcanaSystem system;
  List<OurcanaMember> members;
  List<OurcanaFront> frontHistory;
  List<OurcanaTag> tags;
  List<dynamic> customFields =
      []; // Not enough information to know the structure of this
  List<dynamic> journalEntries =
      []; // Not enough information to know the structure

  OurcanaData({
    required this.exportedAt,
    required this.system,
    required this.members,
    required this.frontHistory,
    required this.tags,
  });

  Map<String, dynamic> encode() {
    List<Map<String, dynamic>> mbrs = [];
    for (var entry in members) {
      mbrs.add(entry.encode());
    }
    List<Map<String, dynamic>> frontHists = [];
    for (var fhObj in frontHistory) {
      frontHists.add(fhObj.encode());
    }

    return {
      "format": "ourcana",
      "version": 2,
      "exportedAt": exportedAt.toIso8601String(),
      "system": system.encode(),
      "members": mbrs,
      "frontHistory": frontHists,
      "customFields": [],
      "journalEntries": [],
      "graph": {},
      "appState": {},
    };
  }

  factory OurcanaData.fromJson(Map<String, dynamic> js) {
    List<OurcanaMember> mbrs = [];
    for (var entry in js['members']) {
      mbrs.add(OurcanaMember.fromJson(entry));
    }
    List<OurcanaFront> frontHist = [];
    for (var entry in js['frontHistory']) {
      frontHist.add(OurcanaFront.fromJson(entry));
    }

    List<OurcanaTag> tags = [];
    for (var entry in js['tags']) {
      tags.add(OurcanaTag.fromJson(entry));
    }

    return OurcanaData(
      exportedAt: DateTime.parse(js['exportedAt']),
      system: OurcanaSystem.fromJson(js['system']),
      members: mbrs,
      frontHistory: frontHist,
      tags: tags,
    );
  }
}

class OurcanaSystem {
  String id;
  String name;
  String desc;
  String color;
  String avatarUrl;
  String avatarUuid;
  String pkSystemId;

  OurcanaSystem({
    required this.id,
    required this.name,
    required this.desc,
    required this.color,
    required this.avatarUrl,
    required this.avatarUuid,
    required this.pkSystemId,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "name": name,
      "desc": desc,
      "color": color,
      "avatarUrl": avatarUrl,
      "avatarUuid": avatarUuid,
      "pkSystemId": pkSystemId,
    };
  }

  factory OurcanaSystem.fromJson(Map<String, dynamic> js) {
    return OurcanaSystem(
      id: js['id'],
      name: js['name'],
      desc: js['desc'] ?? "",
      color: js['color'] ?? "#00000000",
      avatarUrl: js['avatarUrl'] ?? "",
      avatarUuid: js['avatarUuid'],
      pkSystemId: js['pkSystemId'] ?? "",
    );
  }
}

class OurcanaMember {
  String id;
  String name;
  String pronouns;
  String desc;
  String color;
  String avatarUrl;
  String? primaryTagId;
  List<String> tagIds;

  OurcanaMember({
    required this.id,
    required this.name,
    required this.pronouns,
    required this.desc,
    required this.color,
    required this.avatarUrl,
    required this.primaryTagId,
    required this.tagIds,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "name": name,
      "pronouns": pronouns,
      "desc": desc,
      "color": color,
      "avatarUrl": avatarUrl,
      "primaryTagId": primaryTagId,
      "tagIds": tagIds,
    };
  }

  factory OurcanaMember.fromJson(Map<String, dynamic> js) {
    List<String> tgIds = [];
    for (var entry in js['tagIds'] ?? []) {
      tgIds.add("$entry");
    }

    return OurcanaMember(
      id: js['id'],
      name: js['name'],
      pronouns: js['pronouns'] ?? "",
      desc: js['desc'] ?? "",
      color: js['color'] ?? "#00000000",
      avatarUrl: js['avatarUrl'] ?? "",
      primaryTagId: js['primaryTagId'],
      tagIds: tgIds,
    );
  }
}

class OurcanaFront {
  String id;
  List<String> memberIds;
  int startTime;
  int? endTime;
  bool get isLive => endTime == null;

  OurcanaFront({
    required this.id,
    required this.memberIds,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "memberIds": memberIds,
      "startTime": startTime * 1000,
      "endTime": endTime != null ? (endTime! * 1000) : null,
      "isLive": isLive,
    };
  }

  factory OurcanaFront.fromJson(Map<String, dynamic> js) {
    int start = js['startTime'];
    return OurcanaFront(
      id: js['id'],
      memberIds: js['memberIds'],
      startTime: (start / 1000).round(),
      endTime: (((js['endTime'] ?? start) as int) / 1000)
          .round(), // For the purposes of importing, don't leave someone fronting.
    );
  }
}

class OurcanaTag {
  String id;
  String color;
  String label;
  String? parentId;

  OurcanaTag({
    required this.id,
    required this.color,
    required this.label,
    this.parentId,
  });

  Map<String, dynamic> encode() {
    return {"id": id, "color": color, "label": label, "parentId": parentId};
  }

  factory OurcanaTag.fromJson(Map<String, dynamic> js) {
    return OurcanaTag(
      id: js['id'],
      color: js['color'],
      label: js['label'],
      parentId: js['parentId'],
    );
  }
}
