import 'package:dio/dio.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
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
      "${getAPIServerURL()}/user/new",
      data: {"user": username, "auth": Hashing.md5Hash(password)},
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
}

abstract class ResponsePacket {
  late UUID id;
  late String path;
  late String type;
  late String reason;
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
  String reason;

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
  String reason;

  @override
  bool success;

  @override
  String type;

  User data;

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
      "data": data.encode(),
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
    String reason = js['reason'];
    String type = js['type'];
    bool success = js['success'];
    User data = User.deserialize(js['data']);

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
