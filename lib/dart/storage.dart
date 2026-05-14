import 'package:dio/dio.dart';
import 'package:libac_dart/nbt/NbtUtils.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/exceptions.dart';
import 'package:switchboard/dart/privacyPolicy.dart';

class NetworkInterface {
  // Here, we will have a packet system to send and receive data.
  // If a packet has been tested using a testsuite, and it worked, it will have been turned into a Packet here.
  static Future<S2CServerVersionPacket> getServerVersion() async {
    Dio dio = Dio();
    dio.options.contentType = "application/json";
    var reply = await dio.get("${getAPIServerURL()}/version");

    return S2CServerVersionPacket.deserialize(reply.data);
  }

  static Future<S2CUserPacket> putNewUser(
    String username,
    String password,
  ) async {
    Dio dio = Dio();
    dio.options.contentType = "application/json";
    var reply = await dio.put(
      "${getAPIServerURL()}/user/$username",
      data: {"auth": Hashing.md5Hash(password)},
    );

    // Deserialize the make new user packet
    S2CUserPacket response = S2CUserPacket.decode(reply.data);

    return response;
  }

  static Future<S2CUserPacket> getUser(String username) async {
    Dio dio = Dio();
    dio.options.contentType = "application/json";
    var reply = await dio.get("${getAPIServerURL()}/user/$username");

    return S2CUserPacket.decode(reply.data);
  }

  static Future<S2CAuthenticationResponse> authenticate(
    String username,
    String password,
  ) async {
    Dio dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";

    var reply = await dio.post(
      "${getAPIServerURL()}/auth/login",
      data: {"username": username, "auth": Hashing.md5Hash(password)},
    );

    return S2CAuthenticationResponse.decode(reply.data);
  }

  static Future<S2CAuthenticationCheckResponse> checkAuth() async {
    MemoryState ms = MemoryState();
    Dio dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

    var reply = await dio.get("${getAPIServerURL()}/auth/check");

    return S2CAuthenticationCheckResponse.decode(reply.data);
  }

  static Future<S2CAuthenticationRefreshResponse> refreshAuth() async {
    MemoryState ms = MemoryState();
    Dio dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

    var reply = await dio.get("${getAPIServerURL()}/auth/refresh");
    return S2CAuthenticationRefreshResponse.decode(reply.data);
  }

  static Future<S2CAltersResponse> requestAltersList(UUID? user) async {
    MemoryState ms = MemoryState();
    Dio dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

    bool keepRequesting = true;

    int skip = 0;
    int request = 50;

    List<Alter> allAlters = [];

    while (keepRequesting) {
      dio.options.headers["X-SB-Skip"] = "$skip";
      dio.options.headers["X-SB-Count"] = "$request";

      var reply = await dio.get(
        "${getAPIServerURL()}/alters${user == null ? '' : "/${user.toString()}"}",
      );
      // Check for the X-SB-Done header.
      if (reply.headers.value("X-SB-Done") == null) {
        // Increment by X-SB-Count
        skip += int.parse(reply.headers.value("X-SB-Count") ?? "0");
      } else {
        // This is the final iteration
        keepRequesting = false;
      }

      if (reply.data['success'] == false &&
          reply.data['reason'] == "Not Logged In") {
        // Login expired!
        // This should not be possible..
        // Throw a exception!
        ms.lastErrorRay = reply.data['id'];
        keepRequesting = false;
        print("Raw response: ${reply.data}");
        throw NotLoggedInException();
      }

      S2CAltersPartialResponse partialAlters = S2CAltersPartialResponse.decode(
        reply.data,
      );

      allAlters.addAll(partialAlters.data.alters);
    }

    return S2CAltersResponse(alters: allAlters);
  }

  // TODO: Make it possible to set a parent folder once folders are implemented.
  static Future<S2CAlterResponse> makeNewAlter(String name) async {
    Dio dio = Dio();
    MemoryState ms = MemoryState();

    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

    // Send the creation packet!
    var reply = await dio.put(
      "${getAPIServerURL()}/alter/new",
      data: {
        "alter": {
          "name": name,
          "parent": UUID.ZERO.toString(),
          "subid": 0,
          "avatar": UUID.ZERO.toString(),
        },
      },
    );

    return S2CAlterResponse.decode(reply.data);
  }

  static Future<S2CAlterResponse> getAlterByID(UUID id) async {
    Dio dio = Dio();
    MemoryState ms = MemoryState();

    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

    var reply = await dio.get("${getAPIServerURL()}/alter/${id.toString()}");
    return S2CAlterResponse.decode(reply.data);
  }

  static Future<S2CFieldsResponse> getDataFields() async {
    Dio dio = Dio();
    MemoryState ms = MemoryState();

    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

    var reply = await dio.get("${getAPIServerURL()}/fields");
    return S2CFieldsResponse.fromJson(reply.data);
  }
}

abstract class ResponsePacket {
  late UUID id;
  late String path;
  late String type;
  late String? reason;
  late bool success;
}

class ServerVersion {
  String product;
  String version;

  ServerVersion({required this.product, required this.version});

  static ServerVersion deserialize(Map<String, dynamic> js) {
    return ServerVersion(
      product: js['product'] as String,
      version: js['version'] as String,
    );
  }

  Map<String, dynamic> encode() {
    return {"product": product, "version": version};
  }
}

class S2CServerVersionPacket implements ResponsePacket {
  ServerVersion data;

  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  S2CServerVersionPacket({
    required this.data,
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
  });

  factory S2CServerVersionPacket.deserialize(Map<String, dynamic> js) {
    if (!js.containsKey("reason")) {
      throw InvalidServerResponseException(
        reason:
            "The server response does not conform to the standard server packet response",
      );
    }

    return S2CServerVersionPacket(
      path: js['path'] ?? "",
      type: js['type'] ?? "",
      reason: js['reason'] ?? "",
      success: js['success'] ?? false,
      data: ServerVersion.deserialize(
        js['data'] ?? {"product": "null", "version": "null"},
      ),
      id: UUID.parse(js['id'] ?? UUID.ZERO.toString()),
    );
  }

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "type": type,
      "path": path,
      "reason": reason,
      "success": success,
      "data": data.encode(),
    };
  }
}

class S2CUserPacket implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  User? data;

  S2CUserPacket({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id.toString(),
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": data?.encode(),
    };
  }

  factory S2CUserPacket.decode(Map<String, dynamic> js) {
    UUID id = UUID.ZERO;
    if (!js.containsKey("success")) {
      throw InvalidServerResponseException(
        reason:
            "The response does not follow the standard Server response packet",
      );
    }

    id = UUID.parse(js['id']);
    String path = js['path'];
    String? reason = js['reason'];
    String type = js['type'];
    bool success = js['success'];
    User? data;
    if (js['data'] != null) {
      data = User.deserialize(js['data']);
    }

    return S2CUserPacket(
      id: id,
      path: path,
      reason: reason,
      success: success,
      type: type,
      data: data,
    );
  }
}

class User {
  UUID ID;
  String Name;
  String DisplayName;
  int AccountLevel;
  int AlterCount;
  int FetchTime;
  List<Field> Fields;

  User({
    required this.ID,
    required this.Name,
    required this.DisplayName,
    required this.AccountLevel,
    required this.AlterCount,
    required this.Fields,
  }) : FetchTime = TimeUtils.getUnixTimestamp();

  factory User.deserialize(Map<String, dynamic> js) {
    UUID idx = UUID.ZERO;
    if (js.containsKey("ID")) {
      idx = UUID.parse(js['ID']);
    }

    String username = "";
    if (js.containsKey("user")) {
      username = js['user'];
    }

    String displayName = "";
    if (js.containsKey("displayName")) {
      displayName = js['displayName'];
    }

    int alterCount = 0;
    if (js.containsKey("alter_count")) {
      alterCount = js['alter_count'] as int;
    }

    int accountLevel = 0;
    if (js.containsKey("level")) {
      accountLevel = js['level'];
    }
    List<Field> fields = [];
    if (js.containsKey("fields")) {
      List<dynamic> jsFields = js['fields'];
      for (var field in jsFields) {
        fields.add(Field.fromJson(field));
      }
    }

    return User(
      ID: idx,
      Name: username,
      DisplayName: displayName,
      AccountLevel: accountLevel,
      AlterCount: alterCount,
      Fields: fields,
    );
  }

  Map<String, dynamic> encode() {
    return {
      "id": ID.toString(),
      "user": Name,
      "displayName": DisplayName,
      "alter_count": AlterCount,
      "level": AccountLevel,
    };
  }
}

class AuthReply {
  String? token;
  String? username;

  Map<String, dynamic> encode() {
    return {"username": username, "token": token};
  }

  AuthReply({required this.token, required this.username});
  factory AuthReply.decode(Map<String, dynamic> js) {
    if (!js.containsKey("token")) {
      throw InvalidServerResponseException(
        reason:
            "The data field does not conform to the Authentication Reply format",
      );
    }
    return AuthReply(token: js['token'], username: js['username']);
  }
}

class S2CAuthenticationResponse implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  AuthReply data;

  S2CAuthenticationResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": data.encode(),
    };
  }

  factory S2CAuthenticationResponse.decode(Map<String, dynamic> js) {
    // Deserialize the input data
    if (!js.containsKey("success")) {
      throw InvalidServerResponseException(
        reason:
            "The response from the server does not follow the standard response format.",
      );
    }

    return S2CAuthenticationResponse(
      id: UUID.parse(js['id']),
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: AuthReply.decode(js['data']),
    );
  }
}

class AuthCheck {
  UUID? id;

  Map<String, dynamic> encode() {
    return {"id": id};
  }

  AuthCheck({required this.id});

  factory AuthCheck.decode(Map<String, dynamic> js) {
    return AuthCheck(id: UUID.parse(js['id']));
  }
}

class S2CAuthenticationCheckResponse implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  AuthCheck data;

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": data.encode(),
    };
  }

  S2CAuthenticationCheckResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  factory S2CAuthenticationCheckResponse.decode(Map<String, dynamic> js) {
    return S2CAuthenticationCheckResponse(
      id: UUID.parse(js['id']),
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: AuthCheck.decode(js['data']),
    );
  }
}

class AuthRefresh {
  String? token;

  Map<String, dynamic> encode() {
    return {"token": token};
  }

  AuthRefresh({required this.token});

  factory AuthRefresh.decode(Map<String, dynamic> js) {
    return AuthRefresh(token: js['token']);
  }
}

class S2CAuthenticationRefreshResponse implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  AuthRefresh data;

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": data.encode(),
    };
  }

  S2CAuthenticationRefreshResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  factory S2CAuthenticationRefreshResponse.decode(Map<String, dynamic> js) {
    return S2CAuthenticationRefreshResponse(
      id: UUID.parse(js['id']),
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: AuthRefresh.decode(js['data']),
    );
  }
}

class S2CAltersPartialResponse implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  PartialAlters data;

  S2CAltersPartialResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id.toString(),
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": data.encode(),
    };
  }

  factory S2CAltersPartialResponse.decode(Map<String, dynamic> js) {
    return S2CAltersPartialResponse(
      id: UUID.parse(js['id']),
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: PartialAlters.decode(js['data']),
    );
  }
}

/**
 * {
 *  "id": uuid,
 * "path": /request/path
 * "reason": reason for error,
 * "success": boolean
 * "type": "POST/PUT/GET/DELETE/PATCH/etc",
 * "data": {
 *    "count": number of alters iterated,
 *    "alters": [
 *      
                        "user" => $row['User'],
                        "id" => $row['ID'],
                        "name" => $row['Name'],
                        "avatar_url" => $row['Avatar'],
                        "subid" => $row['SubID'],
                        "parent" => $row['ParentID'],
                        "flags" => $row['Flags']
 *    ]
 * }
 * }
 */
class PartialAlters {
  int count;
  List<Alter> alters;

  PartialAlters({required this.count, required this.alters});

  Map<String, dynamic> encode() {
    List<Map<String, dynamic>> tg = [];
    for (var alter in alters) {
      tg.add(alter.encode());
    }

    return {"count": count, "alters": tg};
  }

  factory PartialAlters.decode(Map<String, dynamic> js) {
    int count = js['count'];
    List<Alter> alters = [];

    List<dynamic> tmpalters = js['alters'];
    for (var entry in tmpalters) {
      alters.add(Alter.decode(entry));
    }

    return PartialAlters(count: count, alters: alters);
  }
}

enum FieldType {
  Description(-1),
  Color(-2),
  Unknown(-9999);

  const FieldType(int type) : this._type = type;

  final int _type;

  static FieldType valueOf(int type) {
    if (Description._type == type) return Description;
    if (Color._type == type) return Color;

    return Unknown;
  }

  int value() {
    return _type;
  }
}

class Field {
  UUID id;
  String name;
  FieldType type;

  Field({required this.id, required this.name, required this.type});

  Map<String, dynamic> toJson() {
    return {"id": id.toString(), "name": name, "type": type.value()};
  }

  factory Field.fromJson(Map<String, dynamic> js) {
    UUID id = UUID.parse(js['id']);
    String name = js['name'];
    FieldType type = FieldType.valueOf(js['type']);

    return Field(id: id, name: name, type: type);
  }
}

class S2CFieldsResponse implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  List<Field> data;

  S2CFieldsResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fieldJs = [];

    for (var field in data) {
      fieldJs.add(field.toJson());
    }

    return {
      "id": id.toString(),
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": fieldJs,
    };
  }

  factory S2CFieldsResponse.fromJson(Map<String, dynamic> js) {
    if (!js.containsKey("path"))
      throw new InvalidServerResponseException(
        reason: "Response is not properly formatted",
      );

    List<Field> fieldList = [];
    for (var entry in js['data']) {
      fieldList.add(Field.fromJson(entry));
    }

    return S2CFieldsResponse(
      id: UUID.parse(js['id']),
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: fieldList,
    );
  }
}

class Alter {
  UUID id;
  UUID user;
  String name;
  String avatarUrl;
  int subid;
  UUID parent;
  int flags;

  Alter({
    required this.id,
    required this.user,
    required this.name,
    required this.avatarUrl,
    required this.subid,
    required this.parent,
    required this.flags,
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
    };
  }

  factory Alter.decode(Map<String, dynamic> js) {
    if (!js.containsKey("subid")) {
      throw InvalidServerResponseException(reason: "Not alter formatted data");
    }

    return Alter(
      id: UUID.parse(js['id']),
      user: UUID.parse(js['user']),
      name: js['name'],
      avatarUrl: js['avatar_url'],
      subid: js['subid'],
      parent: UUID.parse(js['parent']),
      flags: js['flags'],
    );
  }

  /// This helper function determines if the proper URL is to the Switchboard CDN, or a external network.
  String getAvatarURL() {
    String url = avatarUrl.startsWith("http")
        ? avatarUrl
        : "${getAPIServerURL()}/avatar/${id.toString()}";

    return url;
  }

  /// This helper function determines if the proper URL is to the Switchboard CDN, or a external network.
  static String makeAvatarURL(String input) {
    String url = input.startsWith("http")
        ? input
        : "${getAPIServerURL()}/avatar/$input";

    return url;
  }
}

class S2CAltersResponse {
  final List<Alter> alters;

  S2CAltersResponse({required this.alters});
}

class S2CAlterResponse implements ResponsePacket {
  @override
  UUID id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  Alter? data;

  S2CAlterResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "path": path,
      "reason": reason,
      "success": success,
      "type": type,
      "data": data,
    };
  }

  factory S2CAlterResponse.decode(Map<String, dynamic> js) {
    return S2CAlterResponse(
      id: UUID.parse(js['id']),
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: Alter.decode(js['data'] ?? {}),
    );
  }
}
