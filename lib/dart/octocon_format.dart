import 'dart:convert';

import 'package:switchboard/dart/globalHelpers.dart';

class OctoconData {
  /// Alter List
  List<OctoconAlter> alters = [];

  /// Fronting History
  List<OctoconFront> fronts = [];

  /// All polls logged in the app. Compatibility with SB unknown at this time.
  //List<OctoconPoll> polls = [];

  /// All tag groupings
  List<OctoconTag> tags = [];

  /// Initialized based on the octocon user json field.
  OctoconUser user = OctoconUser.blank();

  static OctoconData fromJson(String jsn) {
    OctoconData data = OctoconData();

    Map<String, dynamic> jsx = json.decode(jsn);

    List<dynamic> octoalt = jsx['alters'] as List<dynamic>;

    for (var octoAlter in octoalt) {
      OctoAlterBuilder OAB = OctoAlterBuilder()..fromJson(octoAlter);

      data.alters.add(OAB.build());
    }

    List<dynamic> frontHistory = jsx['fronts'] as List<dynamic>;

    //List<dynamic> polling = jsx['polls'] as List<dynamic>;
    for (var octoFront in frontHistory) {
      data.fronts.add(OctoconFront.fromJson(octoFront));
    }

    //for (var poll in polling) {
    //  data.polls.add(OctoconPoll.fromJson(poll));
    //}

    List<dynamic> tags = jsx['tags'] as List<dynamic>;

    for (var tag in tags) {
      data.tags.add(OctoconTag.fromJson(tag));
    }

    data.user = OctoconUser.fromJson(jsx['user']);

    return data;
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> alterList = [];
    for (var alter in alters) {
      alterList.add(alter.toJson());
    }

    List<Map<String, dynamic>> frontHistory = [];
    for (var front in fronts) {
      frontHistory.add(front.toJson());
    }

    //List<Map<String, dynamic>> polling = [];
    //for (var poll in polls) {
    //  polling.add(poll.toJson());
    //}

    List<Map<String, dynamic>> tagging = [];
    for (var tag in tags) {
      tagging.add(tag.toJson());
    }
    return {
      "alters": alterList,
      "fronts": frontHistory,
      //  "polls": polling,
      "tags": tagging,
      "user": user.toJson(),
    };
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
    if (jsx['pronouns'] != null) {
      withPronouns(pronouns: jsx['pronouns']);
    }
    if (jsx['description'] != null) {
      withDescription(desc: jsx["description"] as String);
    }
    if (jsx['fields'] != null) {
      List<dynamic> jsf = jsx['fields'];
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
      List<dynamic> proxies = jsx['discord_proxies'] as List<dynamic>;
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

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fieldLs = [];
    for (var field in fields) {
      fieldLs.add(field.toJson());
    }

    return {
      "id": id,
      "name": name,
      "description": description,
      "fields": fieldLs,
      "color": color,
      "avatar_url": avatarURL,
      "discord_proxies": discordProxies,
      "pronouns": pronouns,
      "proxy_name": proxyName,
    };
  }
}

class OctoField {
  String id;
  dynamic value;

  OctoField({required this.id, required this.value});

  factory OctoField.fromJson(Map<String, dynamic> jsx) {
    return OctoField(id: jsx['id'] as String, value: jsx['value']);
  }

  Map<String, dynamic> toJson() {
    return {"id": id.toString(), "value": value};
  }
}

class OctoconFront {
  final String id;
  final String comment;
  final DateTime? timeEnd; // time_end
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
    String id = jsx['id'] as String;
    String comment = (jsx['comment'] ?? "") as String;
    DateTime? end;
    if (jsx.containsKey("time_end")) {
      if (jsx['time_end'] == null) {
        end = null;
      } else {
        end = DateTime.parse(jsx['time_end'] as String);
      }
    }
    int alterId = jsx['alter_id'] as int;
    DateTime start;
    if (jsx['time_start'] == null) {
      start = DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      start = DateTime.parse(jsx['time_start'] as String);
    }

    return OctoconFront(
      id: id,
      comment: comment,
      timeEnd: end,
      alterId: alterId,
      timeStart: start,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "comment": comment,
      "time_end": timeEnd?.toIso8601String(),
      "alter_id": alterId,
      "start": timeStart.toIso8601String(),
    };
  }
}

class OctoconUser {
  final String id;
  final String? description;
  final List<OctoconField> fields;
  final String? username;
  final String? avatarUrl; // avatar_url

  OctoconUser({
    required this.id,
    required this.description,
    required this.fields,
    required this.username,
    required this.avatarUrl,
  });

  static OctoconUser blank() {
    return OctoconUser(
      id: UUID_ZERO,
      description: "",
      fields: [],
      username: "",
      avatarUrl: "",
    );
  }

  factory OctoconUser.fromJson(Map<String, dynamic> jsx) {
    String id = jsx['id'] as String;
    String? description = jsx['description'];
    List<dynamic> fieldx = jsx['fields'] as List<dynamic>;
    String? username = jsx['username'];
    String? avatarUrl = jsx['avatar_url'];

    List<OctoconField> fields = [];
    for (var entry in fieldx) {
      fields.add(OctoconField.fromJson(entry));
    }

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

  OctoconField? getFieldByID(String id) {
    for (var field in fields) {
      if (field.id.toString() == id.toString()) {
        return field;
      }
    }
    return null;
  }
}

class OctoconField {
  final String id;
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
    String id = jsx['id'] as String;
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

class OctoconPoll {
  final OctoconPollData data;
  final String id;
  final OctoconPollType type;
  final String description;
  final String title;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime timeEnd; // time_end

  OctoconPoll({
    required this.data,
    required this.id,
    required this.type,
    required this.description,
    required this.title,
    required this.insertedAt,
    required this.updatedAt,
    required this.timeEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      "data": data.toJson(),
      "id": id.toString(),
      "type": type.toString(),
      "description": description,
      "title": title,
      "inserted_at": insertedAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "time_end": (timeEnd.year > 1995) ? timeEnd.toIso8601String() : null,
    };
  }

  factory OctoconPoll.fromJson(Map<String, dynamic> jsx) {
    OctoconPollData opd = OPDVoteData(allowVeto: false, responses: []);
    String id = UUID_ZERO;
    OctoconPollType type = OctoconPollType.vote;
    String description = "";
    String title = "";
    DateTime insert = DateTime.now();
    DateTime update = DateTime.now();
    DateTime end = DateTime(1995);

    if (jsx['type'] != null) {
      type = OctoconPollType.fromString(jsx['type'] as String);
    }

    if (jsx['data'] != null) {
      if (type == OctoconPollType.vote) {
        opd = OPDVoteData.fromJson(jsx['data'] as Map<String, dynamic>);
      }
      if (type == OctoconPollType.choice) {
        opd = OPDChoiceData.fromJson(jsx['data'] as Map<String, dynamic>);
      }
    }

    if (jsx['id'] != null) {
      id = jsx['id'] as String;
    }
    if (jsx['description'] != null) {
      description = jsx['description'] as String;
    }

    if (jsx['title'] != null) {
      title = jsx['title'] as String;
    }

    if (jsx['inserted_at'] != null) {
      insert = DateTime.parse(jsx['inserted_at'] as String);
    }

    if (jsx['updated_at'] != null) {
      update = DateTime.parse(jsx['updated_at'] as String);
    }

    if (jsx['time_end'] != null) {
      end = DateTime.parse(jsx['time_end'] as String);
    }

    return OctoconPoll(
      data: opd,
      id: id,
      type: type,
      description: description,
      title: title,
      insertedAt: insert,
      updatedAt: update,
      timeEnd: end,
    );
  }
}

abstract class OctoconPollData {
  Map<String, dynamic> toJson();
}

class OPDChoiceData implements OctoconPollData {
  final List<OPDChoice> choices;
  final List<OPDChoiceSelection> responses;

  OPDChoiceData({required this.choices, required this.responses});

  @override
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> choiceList = [];

    for (var entry in choices) {
      choiceList.add(entry.toJson());
    }

    List<Map<String, dynamic>> response = [];

    for (var entry in responses) {
      response.add(entry.toJson());
    }
    return {"choices": choiceList, "responses": response};
  }

  factory OPDChoiceData.fromJson(Map<String, dynamic> jsx) {
    List<OPDChoice> parse = [];
    List<Map<String, dynamic>> enc =
        jsx['choices'] as List<Map<String, dynamic>>;

    for (var entry in enc) {
      parse.add(OPDChoice.fromJson(entry));
    }

    List<OPDChoiceSelection> response = [];
    enc = jsx['responses'] as List<Map<String, dynamic>>;
    for (var entry in enc) {
      response.add(OPDChoiceSelection.fromJson(entry));
    }

    return OPDChoiceData(choices: parse, responses: response);
  }
}

class OPDChoiceSelection {
  final int alterId;
  final String choiceId;

  OPDChoiceSelection({required this.alterId, required this.choiceId});

  Map<String, dynamic> toJson() {
    return {"alter_id": alterId, "choice_id": choiceId.toString()};
  }

  factory OPDChoiceSelection.fromJson(Map<String, dynamic> jsx) {
    int alter = 0;
    String id = UUID_ZERO;

    if (jsx['alter_id'] != null) {
      alter = jsx['alter_id'] as int;
    }

    if (jsx['choice_id'] != null) {
      id = jsx['choice_id'] as String;
    }

    return OPDChoiceSelection(alterId: alter, choiceId: id);
  }
}

class OPDChoice {
  final String id;
  final String name;

  OPDChoice({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {"id": id.toString(), "name": name};
  }

  factory OPDChoice.fromJson(Map<String, dynamic> jsx) {
    String id = UUID_ZERO;
    String name = "";

    if (jsx['id'] != null) id = jsx['id'] as String;
    if (jsx['name'] != null) {
      name = jsx['name'] as String;
    }

    return OPDChoice(id: id, name: name);
  }
}

enum OctoconPollType {
  vote,
  choice;

  static OctoconPollType fromString(String str) {
    switch (str) {
      case "vote":
        return vote;
      case "choice":
        return choice;
    }

    return vote;
  }

  @override
  String toString() {
    return name;
  }
}

class OPDVoteData implements OctoconPollData {
  final bool allowVeto;
  final List<OPDVoteEntry> responses;

  OPDVoteData({required this.allowVeto, required this.responses});

  @override
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> resp = [];

    for (var entry in responses) {
      resp.add(entry.toJson());
    }

    return {"allow_veto": allowVeto, "responses": resp};
  }

  factory OPDVoteData.fromJson(Map<String, dynamic> jsx) {
    bool veto = false;
    List<OPDVoteEntry> resps = [];

    if (jsx['allow_veto'] != null) veto = jsx['allow_veto'] as bool;
    if (jsx['responses'] != null) {
      List<Map<String, dynamic>> resp =
          jsx['responses'] as List<Map<String, dynamic>>;

      for (var entry in resp) {
        resps.add(OPDVoteEntry.fromJson(entry));
      }
    }

    return OPDVoteData(allowVeto: veto, responses: resps);
  }
}

class OPDVoteEntry {
  final int alterId; // alter_id
  final String comment;
  final OPDVote vote;

  OPDVoteEntry({
    required this.alterId,
    required this.comment,
    required this.vote,
  });

  Map<String, dynamic> toJson() {
    return {"alter_id": alterId, "comment": comment, "vote": vote.toString()};
  }

  factory OPDVoteEntry.fromJson(Map<String, dynamic> jsx) {
    int alterId = 0;
    String comment = "";
    OPDVote vote = OPDVote.yes;

    if (jsx['alter_id'] != null) alterId = jsx['alter_id'] as int;
    if (jsx['comment'] != null) comment = jsx['comment'] as String;
    if (jsx['vote'] != null) vote = OPDVote.fromString(jsx['vote'] as String);

    return OPDVoteEntry(alterId: alterId, comment: comment, vote: vote);
  }
}

enum OPDVote {
  yes,
  no,
  abstain,
  veto;

  @override
  String toString() {
    return name;
  }

  static OPDVote fromString(String value) {
    switch (value) {
      case "yes":
        return yes;
      case "Yes":
        return yes;
      case "no":
        return no;
      case "No":
        return no;
      case "abstain":
        return abstain;
      case "Abstain":
        return abstain;
      case "veto":
        return veto;
      case "Veto":
        return veto;
    }

    return yes;
  }
}

class OctoconTag {
  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime insertedAt; // inserted_at
  final DateTime updatedAt; //updated_at
  final OctoconSecurityLevel securityLevel; //security_level
  final List<int> alters;
  final String parentTagId; // parent_tag_id

  OctoconTag({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.insertedAt,
    required this.updatedAt,
    required this.securityLevel,
    required this.alters,
    required this.parentTagId,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "name": name,
      "description": description,
      "color": color,
      "inserted_at": insertedAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "security_level": securityLevel.toString(),
      "alters": alters,
      "parent_tag_id": parentTagId.toString(),
    };
  }

  factory OctoconTag.fromJson(Map<String, dynamic> jsx) {
    String id = UUID_ZERO;
    String name = "";
    String description = "";
    String color = "#000000";
    DateTime insertedAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    OctoconSecurityLevel securityLevel = OctoconSecurityLevel.private;
    List<int> alters = [];
    String parentTagId = UUID_ZERO;

    if (jsx['id'] != null) {
      id = jsx['id'] as String;
    }

    if (jsx['name'] != null) {
      name = jsx['name'] as String;
    }

    if (jsx['description'] != null) {
      description = jsx['description'] as String;
    }

    if (jsx['color'] != null) {
      color = jsx['color'] as String;
    }
    if (jsx['inserted_at'] != null) {
      insertedAt = DateTime.parse(jsx['inserted_at'] as String);
    }

    if (jsx['updated_at'] != null) {
      updatedAt = DateTime.parse(jsx['updated_at'] as String);
    }

    if (jsx['alters'] != null) {
      if ((jsx['alters'] as List<dynamic>).isEmpty) {
        alters = [];
      } else {
        for (int val in jsx['alters']) {
          alters.add(val);
        }
      }
    }

    if (jsx['parent_tag_id'] != null) {
      parentTagId = jsx['parent_tag_id'];
    }

    return OctoconTag(
      id: id,
      name: name,
      description: description,
      color: color,
      insertedAt: insertedAt,
      updatedAt: updatedAt,
      securityLevel: securityLevel,
      alters: alters,
      parentTagId: parentTagId,
    );
  }
}
