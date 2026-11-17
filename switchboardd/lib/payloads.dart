import 'package:libac_dart/utils/Hashing.dart';
import 'package:switchboardd/consts.dart';
import 'package:switchboardd/users.dart';

class BasicResponse {
  bool Success = false;
  String Path = "/";
  String Method = "GET";
  String ID = UUID_ZERO;
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
    ID = js['id'] ?? UUID_ZERO;
    Reason = js['reason'] ?? "";
  }

  /// Encode universal response fields.
  Map<String, dynamic> encode() {
    return {
      "success": Success,
      "path": Path,
      "type": Method,
      "id": ID,
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
        ID: UUID_ZERO,
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
      super(ID: "", Success: true, Method: "", Reason: "", Path: "") {
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
      super(ID: "", Success: false, Path: "", Method: "", Reason: "") {
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
  String id;
  String rootFolder;
  List<Field> fields;

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
      id = "",
      rootFolder = "",
      fields = [],
      super(ID: "", Path: "", Success: false, Method: "", Reason: "") {
    decode(js);

    user = js['user'];
    displayName = js['displayName'];
    alterCount = js['alter_count'];
    accountLevel = js['level'];
    id = js['id'];
    rootFolder = js['root_folder'];
    List<Map<String, dynamic>> lst = js['fields'];
    fields = [];
    for (var field in lst) {
      fields.add(Field.fromJson(field));
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

class Field {
  String fieldID;
  String fieldName;
  int fieldType;
  int sortOrder;

  Field({
    required this.fieldID,
    required this.fieldName,
    required this.fieldType,
    required this.sortOrder,
  });

  Map<String, dynamic> encode() {
    return {
      "id": fieldID,
      "name": fieldName,
      "type": fieldType,
      "order": sortOrder,
    };
  }

  factory Field.fromJson(Map<String, dynamic> js) {
    return Field(
      fieldID: js['id'],
      fieldName: js['name'],
      fieldType: js['type'],
      sortOrder: js['order'],
    );
  }
}

class ServerUser {
  String username;
  String userID;
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
