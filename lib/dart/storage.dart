import 'package:dio/dio.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/privacyPolicy.dart';

class NetworkInterface {
  // Here, we will have a packet system to send and receive data.
  // If a packet has been tested using a testsuite, and it worked, it will have been turned into a Packet here.
  static Future<S2CServerVersionPacket> getServerVersion() async {
    Dio dio = Dio();
    var reply = await dio.get("${getAPIServerURL()}/version");

    return S2CServerVersionPacket.deserialize(reply.data);
  }
}

/**
 * This is the most basic form of a packet, containing the information on how to send and receive only. 
 */
abstract class Packet {}

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

  static S2CServerVersionPacket deserialize(Map<String, dynamic> js) {
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

class User {
  UUID ID;
  String Name;
  String DisplayName;
  int AccountFlags;
}
