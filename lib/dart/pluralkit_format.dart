import 'dart:convert';

import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/octocon_format.dart';

/// A class containing helpers for decoding and encoding PluralKit json data.
class PluralKit {
  static Future<PluralKitData> decode(Map<String, dynamic> js) async {
    return PluralKitData.fromJson(typeCorrectJson(js));
  }

  static String encode(PluralKitData data) {
    return json.encode(data.encode());
  }

  static OctoconData convertToOctocon(PluralKitData data) {
    OctoconData dat = OctoconData();
    dat.user = OctoconUser(
      id: "IMPORTPK",
      description: data.description,
      fields: [],
      username: "IMPORTPK",
      avatarUrl: data.avatar_url,
    );
    dat.alters = [];
    for (PluralKitMember mbr in data.members ?? []) {
      dat.alters.add(
        OctoconAlter(
          id: mbr.id,
          name: mbr.name,
          description: mbr.description ?? "",
          fields: [],
          color: mbr.color ?? "#00000000",
          avatarURL: mbr.avatar_url ?? "",
          discordProxies: [],
          pronouns: mbr.pronouns ?? "",
          proxyName: mbr.display_name ?? "",
        ),
      );
    }

    dat.fronts = []; // We have no way to convert this at present time.
    dat.tags = [];
    for (PluralKitGroup grp in data.groups ?? []) {
      dat.tags.add(
        OctoconTag(
          id: "${grp.id}",
          name: grp.name,
          description: grp.description ?? "",
          color: grp.color ?? "#00000000",
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          securityLevel: OctoconSecurityLevel.trusted,
          alters: grp.members,
          parentTagId: "",
        ),
      );
    }

    return dat;
  }
}

/// The primary data class for pluralkit json files.
class PluralKitData {
  String? avatar_url;
  String? description;
  List<PluralKitGroup>? groups;
  List<PluralKitMember>? members;
  String name;
  List<PluralKitSwitch>? switches;
  int version = 2; // DISCARD

  PluralKitData({
    required this.name,
    this.avatar_url,
    this.description,
    this.groups,
    this.members,
    this.switches,
  });

  Map<String, dynamic> encode() {
    List<Map<String, dynamic>> grps = [];
    for (PluralKitGroup grp in groups ?? []) {
      grps.add(grp.encode());
    }
    List<Map<String, dynamic>> mbrs = [];
    for (PluralKitMember mbr in members ?? []) {
      mbrs.add(mbr.encode());
    }

    return {
      "avatar_url": avatar_url,
      "description": description,
      "groups": grps,
      "members": mbrs,
      "name": name,
      "switches": [],
      "version": 2,
    };
  }

  factory PluralKitData.fromJson(Map<String, dynamic> js) {
    List<PluralKitGroup> grps = [];
    for (var grp in js['groups'] ?? []) {
      grps.add(PluralKitGroup.fromJson(grp));
    }

    List<PluralKitMember> mbrs = [];
    for (var mbr in js['members'] ?? []) {
      mbrs.add(PluralKitMember.fromJson(mbr));
    }

    return PluralKitData(
      name: js['name'],
      avatar_url: js['avatar_url'],
      description: js['description'],
      groups: grps,
      members: mbrs,
      switches:
          [], // Discard until we have structural information to know how to decode this properly.
    );
  }
}

/// Represents a PluralKit json group
class PluralKitGroup {
  String? color;
  String? description;
  int id;
  List<int> members;
  String name;

  PluralKitGroup({
    required this.id,
    required this.name,
    required this.members,
    this.color,
    this.description,
  });

  Map<String, dynamic> encode() {
    List<String> mbrsCast = [];
    for (var member in members ?? []) {
      mbrsCast.add("$member");
    }

    return {
      "color": color,
      "description": description,
      "id": "${id}",
      "members": members,
      "name": name,
    };
  }

  factory PluralKitGroup.fromJson(Map<String, dynamic> js) {
    List<int> mbrs = [];
    for (var entry in js['members'] ?? []) {
      mbrs.add(int.parse(entry));
    }

    return PluralKitGroup(
      id: int.parse(js['id'] ?? "0"),
      name: js['name'] ?? "",
      color: js['color'],
      description: js['description'],
      members: mbrs,
    );
  }
}

class PluralKitMember {
  String? avatar_url;
  String? color;
  String? description;
  String? display_name;
  int id;
  String name;
  String? pronouns;
  List<PluralKitProxyTag> proxy_tags;

  PluralKitMember({
    required this.id,
    required this.name,
    required this.proxy_tags,
    this.avatar_url,
    this.color,
    this.description,
    this.display_name,
    this.pronouns,
  });

  Map<String, dynamic> encode() {
    List<Map<String, dynamic>> proxyTags = [];
    for (var entry in proxy_tags) {
      proxyTags.add(entry.encode());
    }

    return {
      "avatar_url": avatar_url,
      "color": color,
      "description": description,
      "display_name": display_name,
      "id": id,
      "name": name,
      "pronouns": pronouns,
      "proxy_tags": proxyTags,
    };
  }

  factory PluralKitMember.fromJson(Map<String, dynamic> js) {
    List<PluralKitProxyTag> tags = [];
    for (var entry in js['proxy_tags'] ?? []) {
      tags.add(PluralKitProxyTag.fromJson(entry));
    }

    return PluralKitMember(
      id: int.parse(js['id'] ?? "0"),
      name: js['name'],
      proxy_tags: tags,
      avatar_url: js['avatar_url'],
      color: js['color'],
      description: js['description'],
      display_name: js['display_name'],
      pronouns: js['pronouns'],
    );
  }
}

class PluralKitProxyTag {
  String prefix;
  String suffix;

  PluralKitProxyTag({required this.prefix, required this.suffix});

  Map<String, dynamic> encode() {
    return {"prefix": prefix, "suffix": suffix};
  }

  factory PluralKitProxyTag.fromJson(Map<String, dynamic> js) {
    return PluralKitProxyTag(prefix: js['prefix'], suffix: js['suffix']);
  }
}

/// We have not enough information to populate this class properly.
class PluralKitSwitch {}
