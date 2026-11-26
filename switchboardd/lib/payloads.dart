import 'dart:convert';

import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboardd/funcs.dart';
import 'package:switchboardd/users.dart';

class BasicResponse {
  bool Success = false;
  String Path = "/";
  String Method = "GET";
  UUID ID = UUID.ZERO;
  String Reason = "";

  BasicResponse({
    required this.Success,
    required this.Path,
    required this.Method,
    required this.ID,
    required this.Reason,
  });

  /// Decode universal response fields.
  void decode(Map<String, dynamic> js) {
    Success = js['success'] ?? false;
    Path = js['path'] ?? "/";
    Method = js['type'] ?? "GET";
    ID = UUID.parse(js['id']);
    Reason = js['reason'] ?? "";
  }

  /// Encode universal response fields.
  Map<String, dynamic> encode() {
    return {
      "success": Success,
      "path": Path,
      "type": Method,
      "id": ID.toString(),
      "reason": Reason,
    };
  }
}

class ServerPublicKeyResponse extends BasicResponse {
  String pemData = "";

  ServerPublicKeyResponse({
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
    required this.pemData,
  });

  /// Decode the response.
  ServerPublicKeyResponse.fromJson(Map<String, dynamic> js)
    : pemData = "",
      super(
        Success: false,
        Path: "/",
        Method: "GET",
        ID: UUID.ZERO,
        Reason: "",
      ) {
    super.decode(js);

    final data = js['data'] as Map<String, dynamic>;
    pemData = data['pubKey'] ?? "";
  }

  @override
  Map<String, dynamic> encode() {
    final result = super.encode();

    result['data'] = {"pubKey": pemData};

    return result;
  }
}

class ServerVersionResponse extends BasicResponse {
  String product;
  String version;
  String backendVersion;

  ServerVersionResponse({
    required this.product,
    required this.version,
    required this.backendVersion,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerVersionResponse.fromJson(Map<String, dynamic> js)
    : product = "",
      version = "",
      backendVersion = "",
      super(ID: UUID.ZERO, Success: true, Method: "", Reason: "", Path: "") {
    super.decode(js);

    product = js['product'] as String;
    version = js['version'] as String;
    backendVersion = js['backend'] as String;
  }

  @override
  Map<String, dynamic> encode() {
    var base = super.encode();
    base["data"] = {
      "product": product,
      "version": version,
      "backend": backendVersion,
    };

    return base;
  }
}

class ServerPolicyResponse extends BasicResponse {
  String termsOfService;
  String privacyPolicy;
  bool policiesEnabled;
  ServerPolicyResponse({
    required this.termsOfService,
    required this.privacyPolicy,
    required this.policiesEnabled,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerPolicyResponse.fromJson(Map<String, dynamic> js)
    : termsOfService = "",
      privacyPolicy = "",
      policiesEnabled = false,
      super(ID: UUID.ZERO, Success: false, Path: "", Method: "", Reason: "") {
    super.decode(js);

    policiesEnabled = js['enabled'];
    if (!policiesEnabled) return;
    termsOfService = js['tos'];
    privacyPolicy = js['privacy'];
  }

  @override
  Map<String, dynamic> encode() {
    var js = super.encode();
    if (policiesEnabled) {
      js['data'] = {"tos": termsOfService, "privacy": privacyPolicy};
    } else {
      js['data'] = {"enabled": false};
    }

    return js;
  }
}

class ServerUserResponse extends BasicResponse {
  String user;
  String displayName;
  int alterCount;
  int accountLevel;
  UUID id;
  UUID rootFolder;
  List<ServerField> fields;

  ServerUserResponse({
    required this.user,
    required this.displayName,
    required this.alterCount,
    required this.accountLevel,
    required this.id,
    required this.rootFolder,
    required this.fields,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerUserResponse.fromJson(Map<String, dynamic> js)
    : user = "",
      displayName = "",
      alterCount = 0,
      accountLevel = 0,
      id = UUID.ZERO,
      rootFolder = UUID.ZERO,
      fields = [],
      super(ID: UUID.ZERO, Path: "", Success: false, Method: "", Reason: "") {
    decode(js);

    user = js['user'];
    displayName = js['displayName'];
    alterCount = js['alter_count'];
    accountLevel = js['level'];
    id = UUID.parse(js['id']);
    rootFolder = UUID.parse(js['root_folder']);
    List<Map<String, dynamic>> lst = js['fields'];
    fields = [];
    for (var field in lst) {
      fields.add(ServerField.decode(field));
    }
  }

  @override
  Map<String, dynamic> encode() {
    var base = super.encode();
    List<Map<String, dynamic>> lst = [];
    for (var field in fields) {
      lst.add(field.encode());
    }

    base["data"] = {
      "user": user,
      "displayName": displayName,
      "alter_count": alterCount,
      "level": accountLevel,
      "id": id,
      "root_folder": rootFolder,
      "fields": lst,
    };

    return base;
  }
}

class ServerAuthenticationResponse extends BasicResponse {
  String username;
  String token;

  ServerAuthenticationResponse({
    required this.username,
    required this.token,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerAuthenticationResponse.fromJson(Map<String, dynamic> js)
    : username = "",
      token = "",
      super(Success: false, Path: "", Method: "", ID: UUID.ZERO, Reason: "") {
    decode(js);
    username = js['username'];
    token = js['token'];
  }

  @override
  Map<String, dynamic> encode() {
    var payload = super.encode();
    payload['data'] = {"username": username, "token": token};

    return payload;
  }
}

enum ServerFieldType {
  Description(-1),
  ColorSys(-2),
  Pronouns(-3),
  Unknown(-9999),
  PlainText(0),
  Markdown(1),
  Color(2),
  Date(3),
  Number(4),
  Boolean(5);

  const ServerFieldType(int type) : _type = type;

  final int _type;

  static ServerFieldType valueOf(int type) {
    if (Description._type == type) return Description;
    if (ColorSys._type == type) return ColorSys;
    if (Pronouns._type == type) return Pronouns;
    if (PlainText._type == type) return PlainText;
    if (Markdown._type == type) return Markdown;
    if (Color._type == type) return Color;
    if (Date._type == type) return Date;
    if (Number._type == type) return Number;
    if (Boolean._type == type) return Boolean;

    return Unknown;
  }

  int value() {
    return _type;
  }

  @override
  String toString() {
    switch (this) {
      case Description:
        return "Description (Markdown, System Field)";
      case ColorSys:
        return "Color (System Field)";
      case Pronouns:
        return "Pronouns (Plain Text, System Field)";
      case Unknown:
        return "Unknown Type";
      case PlainText:
        return "Plain Text";
      case Markdown:
        return "Text (Markdown)";
      case Color:
        return "Color";
      case Date:
        return "Date";
      case Number:
        return "Number";
      case Boolean:
        return "Boolean (Yes/No)";
    }
  }
}

class ServerField {
  UUID fieldID;
  String fieldName;
  ServerFieldType fieldType;
  int sortOrder;

  ServerField({
    required this.fieldID,
    required this.fieldName,
    required this.fieldType,
    required this.sortOrder,
  });

  Map<String, dynamic> encode() {
    return {
      "id": fieldID.toString(),
      "name": fieldName,
      "type": fieldType.value(),
      "order": sortOrder,
    };
  }

  static ServerField decode(Map<String, dynamic> js) {
    return ServerField(
      fieldID: UUID.parse(js['id']),
      fieldName: js['name'],
      fieldType: ServerFieldType.valueOf(js['type']),
      sortOrder: js['order'],
    );
  }
}

class ServerFieldsResponse extends BasicResponse {
  List<ServerField> fields;

  ServerFieldsResponse({
    required this.fields,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerFieldsResponse.fromJson(Map<String, dynamic> js)
    : fields = [],
      super(ID: UUID.ZERO, Reason: "", Success: false, Path: "", Method: "") {
    super.decode(js);

    fields = [];
    for (var entry in js['data']) {
      fields.add(ServerField.decode(entry));
    }
  }

  @override
  Map<String, dynamic> encode() {
    var ret = super.encode();
    List<Map<String, dynamic>> lst = [];
    for (var entry in fields) {
      lst.add(entry.encode());
    }

    ret['data'] = lst;

    return ret;
  }
}

class ServerUser {
  String username;
  UUID userID;
  int accountLevel;
  String passwordHash;
  String passwordSalt;
  String displayName;

  String getAccountLevelStr() {
    return getAccountLevel(accountLevel);
  }

  ServerUser({
    required this.username,
    required this.userID,
    required this.accountLevel,
    required this.passwordHash,
    required this.passwordSalt,
    required this.displayName,
  });

  bool authenticate(String hashedPassword) {
    bool res = Hashing.md5Hash("$hashedPassword:$passwordSalt") == passwordHash;

    if (res) {
      passwordHash = "";
      passwordSalt = "";
    }

    return res;
  }
}

class ServerFieldData {
  UUID id;
  Map<String, dynamic> data = {};

  ServerFieldData({required this.id, required this.data});

  Map<String, dynamic> toJson() {
    return {"id": id.toString(), "value": data};
  }

  static ServerFieldData decode(Map<String, dynamic> js) {
    return ServerFieldData(id: UUID.parse(js['id']), data: js['value']);
  }
}

class ServerAlter {
  UUID id;
  UUID user;
  String name;
  String avatarUrl;
  int subid;
  UUID parent;
  int flags;
  List<ServerFieldData> fields;
  String proxyName;
  List<String> proxies;

  ServerAlter({
    required this.id,
    required this.user,
    required this.name,
    required this.avatarUrl,
    required this.subid,
    required this.parent,
    required this.flags,
    required this.fields,
    required this.proxyName,
    required this.proxies,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id.toString(),
      "user": user.toString(),
      "name": name,
      "avatar_url": avatarUrl,
      "subid": subid,
      "parent": parent.toString(),
      "flags": flags,
      "fields": base64Encoder.base64Enc(json.encode({"A": encodeFields()})),
      "proxy_name": proxyName,
      "proxies": proxies,
    };
  }

  static List<dynamic> parseFields(dynamic js) {
    List<dynamic> fieldsJs = [];
    try {
      var jsA = js;
      jsA ??= "eyJBIjogW119";

      var jsB = base64Encoder.base64Dec(jsA);
      var jsC = typeCorrectJsonDecode(jsB);
      fieldsJs = jsC["A"];
    } catch (A) {}

    return fieldsJs;
  }

  static ServerAlter decode(Map<String, dynamic> js) {
    var fieldsJs = parseFields(js['fields']);
    List<dynamic> proxies = js['proxies'] ?? [];

    var alter = ServerAlter(
      id: UUID.parse(js['id']),
      user: UUID.parse(js['user']),
      name: js['name'],
      avatarUrl: js['avatar_url'],
      subid: js['subid'],
      parent: UUID.parse(js['parent']),
      flags: js['flags'],
      fields: decodeFields(fieldsJs),
      proxyName: js['proxy_name'] ?? "",
      proxies: proxies.isEmpty ? [] : proxies as List<String>,
    );

    return alter;
  }

  static List<ServerFieldData> decodeFields(List<dynamic> js) {
    List<ServerFieldData> fields = [];
    for (var entry in js) {
      fields.add(ServerFieldData.decode(entry));
    }

    return fields;
  }

  List<Map<String, dynamic>> encodeFields() {
    List<Map<String, dynamic>> ret = [];
    for (var entry in fields) {
      ret.add(entry.toJson());
    }

    return ret;
  }
}

class ServerAltersResponse extends BasicResponse {
  List<ServerAlter> alters = [];
  int alterCount;
  int totalAlters;
  bool done;

  ServerAltersResponse({
    required this.alters,
    required this.alterCount,
    required this.totalAlters,
    required this.done,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerAltersResponse.fromJs(Map<String, dynamic> js)
    : alters = [],
      alterCount = 0,
      totalAlters = 0,
      done = false,
      super(ID: UUID.ZERO, Success: false, Path: "", Method: "", Reason: "") {
    alters = [];
    alterCount = js['data']['count'];
    totalAlters = js['data']['total'];
    done = js['data']['done'];
    super.decode(js);

    for (var entry in js['data']['alters']) {
      alters.add(ServerAlter.decode(entry));
    }
  }

  @override
  Map<String, dynamic> encode() {
    var js = super.encode();
    List<Map<String, dynamic>> alterLst = [];

    for (var alter in alters) {
      alterLst.add(alter.encode());
    }

    js['data'] = {
      "count": alterCount,
      "total": totalAlters,
      "alters": alterLst,
      "done": done,
    };

    return js;
  }
}
