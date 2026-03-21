import 'dart:convert';

import 'package:libac_dart/utils/uuid/UUID.dart';

class OctoconData {
  /// Alter List
  List<OctoconAlter> alters = [];

  /// Fronting History
  List<OctoconFront> fronts = [];

  /// Not enough data collected to determine the data structure of this list.
  List<dynamic> polls = [];

  ///Not enough data collected to determine data structure
  List<dynamic> tags = [];

  /// Initialized based on the octocon user json field.
  OctoconUser user = OctoconUser.blank();

  static OctoconData fromJson(String jsn) {
    OctoconData data = OctoconData();

    Map<String, dynamic> jsx = json.decode(jsn);
    List<Map<String, dynamic>> octoalt =
        jsx['alters'] as List<Map<String, dynamic>>;

    for (var octoAlter in octoalt) {
      OctoAlterBuilder OAB = OctoAlterBuilder()..fromJson(octoAlter);

      data.alters.add(OAB.build());
    }

    List<Map<String, dynamic>> frontHistory =
        jsx['fronts'] as List<Map<String, dynamic>>;
    for (var octoFront in frontHistory) {
      data.fronts.add(OctoconFront.fromJson(octoFront));
    }

    return data;
  }
}

class OctoAlterBuilder {
  OctoAlterBuilder();

  int _id = 0;
  String _name = "";
  String _description = "";
  List<OctoField> _fields = [];
  String _color = "";
  String _avatarURL = "";
  List<String> _discordProxies = [];
  String _pronouns = "";
  String _proxyName = "";

  OctoAlterBuilder fromJson(Map<String, dynamic> jsx) {
    withID(id: jsx["id"] as int);

    if (jsx['name'] != null) {
      withName(name: jsx["name"] as String);
    }
    if (jsx['description'] != null) {
      withDescription(desc: jsx["description"] as String);
    }
    if (jsx['fields'] != null) {
      List<Map<String, dynamic>> jsf = jsx['fields'];
      if (jsf.isNotEmpty) {
        for (var f in jsf) {
          withField(field: OctoField.fromJson(f));
        }
      }
    }

    if (jsx['color'] != null) {
      withColor(color: jsx['color'] as String);
    }

    if (jsx['avatar_url'] != null) {
      withAvatarURL(avatarURL: jsx['avatar_url'] as String);
    }

    if (jsx['discord_proxies'] != null) {
      List<String> proxies = jsx['discord_proxies'] as List<String>;
      for (var proxy in proxies) {
        withDiscordProxy(proxy: proxy);
      }
    }

    if (jsx['proxy_name'] != null) {
      withProxyName(proxyName: jsx['proxy_name'] as String);
    }
    return this;
  }

  OctoAlterBuilder withID({required int id}) {
    _id = id;
    return this;
  }

  OctoAlterBuilder withName({required String name}) {
    _name = name;
    return this;
  }

  OctoAlterBuilder withDescription({required String desc}) {
    _description = desc;
    return this;
  }

  OctoAlterBuilder withField({required OctoField field}) {
    _fields.add(field);
    return this;
  }

  OctoAlterBuilder withColor({required String color}) {
    _color = color;
    return this;
  }

  OctoAlterBuilder withAvatarURL({required String avatarURL}) {
    _avatarURL = avatarURL;
    return this;
  }

  OctoAlterBuilder withDiscordProxy({required String proxy}) {
    _discordProxies.add(proxy);
    return this;
  }

  OctoAlterBuilder withPronouns({required String pronouns}) {
    _pronouns = pronouns;
    return this;
  }

  OctoAlterBuilder withProxyName({required String proxyName}) {
    _proxyName = proxyName;
    return this;
  }

  OctoconAlter build() {
    return OctoconAlter(
      id: _id,
      name: _name,
      description: _description,
      fields: _fields,
      color: _color,
      avatarURL: _avatarURL,
      discordProxies: _discordProxies,
      pronouns: _pronouns,
      proxyName: _proxyName,
    );
  }

  OctoAlterBuilder fromBuiltAlter({required OctoconAlter alter}) {
    _id = alter.id;
    _name = alter.name;
    _description = alter.description;
    _fields = alter.fields;
    _color = alter.color;
    _avatarURL = alter.avatarURL;
    _discordProxies = alter.discordProxies;
    _pronouns = alter.pronouns;
    _proxyName = alter.proxyName;

    return this;
  }
}

class OctoconAlter {
  final int id;
  final String name;
  final String description;
  final List<OctoField> fields;
  final String color;
  final String avatarURL;
  final List<String> discordProxies;
  final String pronouns;
  final String proxyName;

  ///DO NOT USE. USE BUILDER INSTEAD
  OctoconAlter({
    required this.id,
    required this.name,
    required this.description,
    required this.fields,
    required this.color,
    required this.avatarURL,
    required this.discordProxies,
    required this.pronouns,
    required this.proxyName,
  });
}

class OctoField {
  UUID id;
  dynamic value;

  OctoField({required this.id, required this.value});

  factory OctoField.fromJson(Map<String, dynamic> jsx) {
    return OctoField(id: UUID.parse(jsx['id'] as String), value: jsx['value']);
  }
}

class OctoconFront {
  final UUID id;
  final String comment;
  final DateTime timeEnd; // time_end
  final int alterId; // alter_id
  final DateTime timeStart; // time_start

  OctoconFront({
    required this.id,
    required this.comment,
    required this.timeEnd,
    required this.alterId,
    required this.timeStart,
  });

  factory OctoconFront.fromJson(Map<String, dynamic> jsx) {
    UUID id = UUID.parse(jsx['id'] as String);
    String comment = jsx['comment'] as String;
    DateTime end = DateTime.parse(jsx['time_end'] as String);
    int alterId = jsx['alter_id'] as int;
    DateTime start = DateTime.parse(jsx['time_start'] as String);

    return OctoconFront(
      id: id,
      comment: comment,
      timeEnd: end,
      alterId: alterId,
      timeStart: start,
    );
  }

  String toJson() {
    return json.encode({
      "id": id.toString(),
      "comment": comment,
      "time_end": timeEnd.toIso8601String(),
      "alter_id": alterId,
      "start": timeStart.toIso8601String(),
    });
  }
}

class OctoconUser {
  final UUID id;
  final String description;
  final List<OctoconField> fields;
  final String username;
  final String avatarUrl; // avatar_url

  OctoconUser({
    required this.id,
    required this.description,
    required this.fields,
    required this.username,
    required this.avatarUrl,
  });

  static OctoconUser blank() {
    return OctoconUser(
      id: UUID.ZERO,
      description: "",
      fields: [],
      username: "",
      avatarUrl: "",
    );
  }

  factory OctoconUser.fromJson(Map<String, dynamic> jsx) {
    UUID id = UUID.parse(jsx['id'] as String);
    String description = jsx['description'] as String;
    List<Map<String, dynamic>> fieldx =
        jsx['fields'] as List<Map<String, dynamic>>;
    String username = jsx['username'] as String;
    String avatarUrl = jsx['avatar_url'];

    List<OctoconField> fields = [];
    return OctoconUser(
      id: id,
      description: description,
      fields: fields,
      username: username,
      avatarUrl: avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fieldsJs = [];
    for (var entry in fields) {
      fieldsJs.add(entry.toJson());
    }

    return {
      "id": id.toString(),
      "description": description,
      "fields": fieldsJs,
      "username": username,
      "avatar_url": avatarUrl,
    };
  }

  OctoconField? getFieldByID(UUID id) {
    for (var field in fields) {
      if (field.id.toString() == id.toString()) {
        return field;
      }
    }
    return null;
  }
}

class OctoconField {
  final UUID id;
  final String name;
  final String type;
  final bool locked;
  final OctoconSecurityLevel securityLevel; // security_level

  OctoconField({
    required this.id,
    required this.name,
    required this.type,
    required this.locked,
    required this.securityLevel,
  });

  factory OctoconField.fromJson(Map<String, dynamic> jsx) {
    UUID id = UUID.parse(jsx['id'] as String);
    String name = jsx['name'] as String;
    String type = jsx['type'] as String;
    bool locked = jsx['locked'] as bool;
    OctoconSecurityLevel secLvl = OctoconSecurityLevel.parseSecurityLevel(
      jsx['security_level'] as String,
    );

    return OctoconField(
      id: id,
      name: name,
      type: type,
      locked: locked,
      securityLevel: secLvl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "name": name,
      "type": type,
      "locked": locked,
      "security_level": securityLevel.toString(),
    };
  }
}

enum OctoconSecurityLevel {
  friendsOnly,
  private,
  trusted,
  public;

  @override
  String toString() {
    switch (this) {
      case friendsOnly:
        return "friends_only";
      case private:
        return "private";
      case trusted:
        return "trusted";
      default:
        return "public";
    }
  }

  static OctoconSecurityLevel parseSecurityLevel(String sec) {
    switch (sec) {
      case "friends_only":
        return OctoconSecurityLevel.friendsOnly;
      case "private":
        return OctoconSecurityLevel.private;
      case "trusted":
        return OctoconSecurityLevel.trusted;
      default:
        return OctoconSecurityLevel.public;
    }
  }
}
