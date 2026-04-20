import 'package:dio/dio.dart';
import 'package:libac_dart/nbt/impl/ListTag.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/MemoryState.dart';
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
      "${getAPIServerURL()}/user/${username}",
      data: {"auth": Hashing.md5Hash(password)},
    );

    // Deserialize the make new user packet
    S2CUserPacket response = S2CUserPacket.decode(reply.data);

    return response;
  }

  static Future<S2CUserPacket> getUser(String username) async {
    Dio dio = Dio();
    dio.options.contentType = "application/json";
    var reply = await dio.get("${getAPIServerURL()}/user/${username}");

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

      S2CAltersPartialResponse partialAlters = S2CAltersPartialResponse.decode(
        reply.data,
      );

      allAlters.addAll(partialAlters.data.alters);
    }

    return S2CAltersResponse(alters: allAlters);
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
      "data": data?.encode() ?? null,
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
    User? data = null;
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

class InvalidServerResponseException implements Exception {
  String reason;
  InvalidServerResponseException({required this.reason});

  @override
  String toString() {
    return reason;
  }
}

class User {
  UUID ID;
  String Name;
  String DisplayName;
  int AccountLevel;
  int AlterCount;
  int FetchTime;

  User({
    required this.ID,
    required this.Name,
    required this.DisplayName,
    required this.AccountLevel,
    required this.AlterCount,
  }) : this.FetchTime = TimeUtils.getUnixTimestamp();

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

    return User(
      ID: idx,
      Name: username,
      DisplayName: displayName,
      AccountLevel: accountLevel,
      AlterCount: alterCount,
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
    if (!js.containsKey("subid"))
      throw InvalidServerResponseException(reason: "Not alter formatted data");

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
}

class S2CAltersResponse {
  final List<Alter> alters;

  S2CAltersResponse({required this.alters});
}
