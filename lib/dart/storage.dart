import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/exceptions.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:synchronized/synchronized.dart';

class NetworkCache {
  String path;
  DateTime requestTime;
  dynamic responseData;

  bool isStale() {
    return DateTime.now().difference(requestTime).inMinutes > 5;
  }

  NetworkCache({
    required this.path,
    required this.requestTime,
    required this.responseData,
  });
}

class NetworkCaches {
  static Map<String, NetworkCache> registry = {};

  /// To be used by any methods that would change server-side data, to force refresh on next call.
  static void invalidate() {
    registry.clear();
  }
}

/// Here, we will have a packet system to send and receive data.
/// If a packet has been tested using a testsuite, and it worked, it will have been turned into a Packet here.
class NetworkInterface {
  static final lock = Lock();

  /// Retrieval of a cache object, if present.
  ///
  /// [fn] The function's name by which the object would be stored.
  static NetworkCache? getCache(String fn) {
    if (NetworkCaches.registry.containsKey(fn)) {
      NetworkCache fnCache = NetworkCaches.registry[fn]!;
      if (fnCache.isStale()) {
        NetworkCaches.registry.remove(fn);
      } else {
        print("Cache hit for ${fn}");
        return fnCache;
      }
    }

    return null;
  }

  /// Insert a cache object, which caches a server's response.
  static void setCache(String fn, dynamic response) {
    NetworkCaches.registry[fn] = NetworkCache(
      path: fn,
      requestTime: DateTime.now(),
      responseData: response,
    );
  }

  static Future<S2CServerVersionPacket> getServerVersion() async {
    return await lock.synchronized(() async {
      var cached = getCache("getServerVersion");
      if (cached != null) {
        return S2CServerVersionPacket.decode(
          typeCorrectJson(cached.responseData),
        );
      }
      Dio dio = Dio();
      dio.options.contentType = "application/json";
      var reply = await dio.get("${getAPIServerURL()}/version");

      print(reply.data);
      setCache("getServerVersion", reply.data);

      return S2CServerVersionPacket.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CUserPacket> putNewUser(
    String username,
    String password,
  ) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      dio.options.contentType = "application/json";
      var reply = await dio.put(
        "${getAPIServerURL()}/user/$username",
        data: {"auth": Hashing.md5Hash(password)},
      );

      print(reply.data);

      // Deserialize the make new user packet
      S2CUserPacket response = S2CUserPacket.decode(
        typeCorrectJson(reply.data),
      );
      NetworkCaches.invalidate();

      return response;
    });
  }

  static Future<S2CUserPacket> getUser(String username) async {
    return await lock.synchronized(() async {
      var cached = getCache("getUser${username}");
      if (cached != null) {
        return S2CUserPacket.decode(cached.responseData);
      }
      Dio dio = Dio();
      dio.options.contentType = "application/json";
      var reply = await dio.get("${getAPIServerURL()}/user/$username");

      print(reply.data);
      setCache("getUser$username", reply.data);

      return S2CUserPacket.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CAuthenticationResponse> authenticate(
    String username,
    String password,
  ) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";

      var reply = await dio.post(
        "${getAPIServerURL()}/auth/login",
        data: {"username": username, "auth": Hashing.md5Hash(password)},
      );

      print(reply.data);

      return S2CAuthenticationResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CAuthenticationCheckResponse> checkAuth() async {
    return await lock.synchronized(() async {
      MemoryState ms = MemoryState();
      Dio dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("${getAPIServerURL()}/auth/check");

      print(reply.data);

      return S2CAuthenticationCheckResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CAuthenticationRefreshResponse> refreshAuth() async {
    return await lock.synchronized(() async {
      MemoryState ms = MemoryState();
      Dio dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("${getAPIServerURL()}/auth/refresh");

      print(reply.data);
      return S2CAuthenticationRefreshResponse.decode(
        typeCorrectJson(reply.data),
      );
    });
  }

  static Future<S2CAltersResponse> requestAltersList(UUID? user) async {
    return await lock.synchronized(() async {
      var cached = getCache("requestAltersList");
      if (cached != null) {
        return S2CAltersResponse(alters: cached.responseData);
      }
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

        print(reply.data);
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

        S2CAltersPartialResponse partialAlters =
            S2CAltersPartialResponse.decode(typeCorrectJson(reply.data));

        allAlters.addAll(partialAlters.data.alters);
      }

      setCache("requestAltersList", allAlters);

      return S2CAltersResponse(alters: allAlters);
    });
  }

  // TODO: Make it possible to set a parent folder once folders are implemented.
  static Future<S2CAlterResponse> makeNewAlter(String name) async {
    return await lock.synchronized(() async {
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

      print(reply.data);
      NetworkCaches.invalidate();

      return S2CAlterResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CAlterResponse> getAlterByID(UUID id) async {
    return await lock.synchronized(() async {
      var cached = getCache("getAlter${id.toString()}");
      if (cached != null) {
        return S2CAlterResponse.decode(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("${getAPIServerURL()}/alter/${id.toString()}");

      print(reply.data);
      setCache("getAlter${id.toString()}", reply.data);

      return S2CAlterResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CFieldsResponse> getDataFields() async {
    return await lock.synchronized(() async {
      var cached = getCache("getDataFields");
      if (cached != null) {
        return S2CFieldsResponse.fromJson(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("${getAPIServerURL()}/fields");
      print(reply.data);
      setCache("getDataFields", reply.data);

      return S2CFieldsResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CFieldResponse> updateField(Field field) async {
    return await lock.synchronized(() async {
      // Construct a packet to update the field!
      Map<String, dynamic> payload = field.toJson();
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post(
        "${getAPIServerURL()}/field/${field.id.toString()}",
        data: payload,
      );

      print(reply.data);
      S2CFieldResponse sfr = S2CFieldResponse.decode(
        typeCorrectJson(reply.data),
      );
      NetworkCaches.invalidate();

      return sfr;
    });
  }

  static Future<S2CFieldResponse> getField(UUID fieldID) async {
    return await lock.synchronized(() async {
      var cached = getCache("getField${fieldID.toString()}");
      if (cached != null) {
        return S2CFieldResponse.decode(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get(
        "${getAPIServerURL()}/field/${fieldID.toString()}",
      );

      print(reply.data);
      S2CFieldResponse sfr = S2CFieldResponse.decode(
        typeCorrectJson(reply.data),
      );
      setCache("getField${fieldID.toString()}", reply.data);

      return sfr;
    });
  }

  static Future<S2CFieldResponse> newField(String name) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      Field newField = Field(
        id: UUID.ZERO,
        name: name,
        type: FieldType.PlainText,
        order: 999,
      );
      var reply = await dio.post(
        "${getAPIServerURL()}/field/new",
        data: newField.toJson(),
      );

      print(reply.data);
      NetworkCaches.invalidate();
      S2CFieldResponse sfr = S2CFieldResponse.decode(
        typeCorrectJson(reply.data),
      );

      return sfr;
    });
  }

  static Future<S2CLazyResponse> deleteField(UUID id) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete(
        "${getAPIServerURL()}/field/${id.toString()}",
      );
      NetworkCaches.invalidate();

      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CLazyResponse> updateAlter(Alter alter) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.patch(
        "${getAPIServerURL()}/alter/${alter.id.toString()}",
        data: {"alter": alter.encode()},
      );
      NetworkCaches.invalidate();

      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CLazyResponse> deleteAvatar(Alter alter) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete(
        "${getAPIServerURL()}/avatar/${alter.id.toString()}",
      );
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CLazyResponse> updateAvatar(
    Alter alter,
    String base64EncodedImage,
  ) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post(
        "${getAPIServerURL()}/avatar/${alter.id.toString()}",
        data: {"image": base64EncodedImage},
      );
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<bool> migrateAvatar(String url, UUID alterID) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      dio.options.responseType = ResponseType.bytes;

      var reply = await dio.get(
        url,
        options: Options(
          headers: {
            "User-Agent":
                "Switchboard/v${MemoryState.A.applicationVersion} client",
          },
        ),
      );

      var alterReply = await NetworkInterface.getAlterByID(alterID);

      var updateReply = await NetworkInterface.updateAvatar(
        alterReply.data!,
        base64Encoder.base64EncBytes(reply.data),
      );
      NetworkCaches.invalidate();

      return updateReply.success;
    });
  }

  static Future<S2CLazyResponse> wipeAccount() async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("${getAPIServerURL()}/wipe");
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Retrieve all fronters from the database.
  ///
  /// [history] Whether to obtain all history or only current fronters
  static Future<S2CFrontHistoryResponse> getFronters(bool history) async {
    return await lock.synchronized(() async {
      var cached = getCache("getFronters${history ? "history" : "active"}");
      if (cached != null) {
        return S2CFrontHistoryResponse.fromJson(
          typeCorrectJson(cached.responseData),
        );
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get(
        "${getAPIServerURL()}/fronting",
        data: {"history": history},
      );
      setCache("getFronters${history ? "history" : "active"}", reply.data);
      print(reply.data);

      return S2CFrontHistoryResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  /// Set an alter as currently fronting
  ///
  /// [alterID] The ID of the alter you wish to set as fronting
  static Future<S2CFrontResponse> setFronting(UUID alterID) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post(
        "${getAPIServerURL()}/fronting",
        data: {"alter": alterID.toString()},
      );
      NetworkCaches.invalidate();

      return S2CFrontResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  /// Inserts a fronter, usually from a data import
  ///
  /// [front] Contains the data to be inserted into the database.
  static Future<S2CLazyResponse> insertFronter(Front front) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.put(
        "${getAPIServerURL()}/fronting",
        data: front.toJson(),
      );
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Deletes a fronter
  ///
  /// [front] Fronter ID to be deleted
  static Future<S2CLazyResponse> deleteFronter(UUID front) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete(
        "${getAPIServerURL()}/fronting",
        data: {"id": front.toString()},
      );
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Remove a fronter from current front status
  ///
  /// [front] Fronter ID to update the end time for.
  static Future<S2CLazyResponse> unfrontFronter(UUID front) async {
    return await lock.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.patch(
        "${getAPIServerURL()}/fronting",
        data: {"id": front.toString()},
      );
      NetworkCaches.invalidate();
      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }
}

abstract class ResponsePacket {
  late UUID id;
  late String path;
  late String type;
  late String? reason;
  late bool success;
}

class S2CLazyResponse implements ResponsePacket {
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

  S2CLazyResponse({
    required this.id,
    required this.path,
    required this.reason,
    required this.success,
    required this.type,
  });

  factory S2CLazyResponse.decode(Map<String, dynamic> js) {
    S2CLazyResponse lz = S2CLazyResponse(
      id: UUID.ZERO,
      path: "",
      reason: "reason",
      success: false,
      type: "",
    );

    lz._decode(js);

    return lz;
  }

  void _decode(Map<String, dynamic> js) {
    id = UUID.parse(js['id'] ?? UUID.ZERO.toString());
    path = js['path'];
    reason = js['reason'];
    success = js['success'];
    type = js['type'];
  }

  Map<String, dynamic> encode() {
    return {
      "id": id,
      "path": path,
      "success": success,
      "reason": reason,
      "type": type,
    };
  }
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

class S2CServerVersionPacket extends S2CLazyResponse {
  ServerVersion data;

  S2CServerVersionPacket({
    required this.data,
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
  });

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);
    data = ServerVersion.deserialize(
      js['data'] ?? {"product": "null", "version": "null"},
    );
  }

  factory S2CServerVersionPacket.decode(Map<String, dynamic> js) {
    S2CServerVersionPacket svp = S2CServerVersionPacket(
      data: ServerVersion(product: "", version: "version"),
      id: UUID.ZERO,
      path: "path",
      reason: "",
      success: false,
      type: "type",
    );
    svp._decode(js);

    return svp;
  }

  @override
  Map<String, dynamic> encode() {
    Map<String, dynamic> enc = super.encode();

    enc.addAll({"data": data.encode()});
    return enc;
  }
}

class S2CUserPacket extends S2CLazyResponse {
  User? data;

  S2CUserPacket({
    required this.data,
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
  });

  @override
  Map<String, dynamic> encode() {
    Map<String, dynamic> enc = super.encode();

    enc.addAll({"data": data?.encode()});

    return enc;
  }

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);

    if (js['data'] != null) {
      data = User.deserialize(js['data']);
    }
  }

  factory S2CUserPacket.decode(Map<String, dynamic> js) {
    S2CUserPacket pkt = S2CUserPacket(
      data: null,
      id: UUID.ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
    );
    pkt._decode(js);

    return pkt;
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

class S2CAuthenticationResponse extends S2CLazyResponse {
  AuthReply data;

  S2CAuthenticationResponse({
    required this.data,
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
  });

  @override
  Map<String, dynamic> encode() {
    var enc = super.encode();
    enc.addAll({"data": data.encode()});

    return enc;
  }

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);

    data = AuthReply.decode(js['data']);
  }

  factory S2CAuthenticationResponse.decode(Map<String, dynamic> js) {
    S2CAuthenticationResponse auth = S2CAuthenticationResponse(
      data: AuthReply(token: "token", username: "username"),
      id: UUID.ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
    );
    auth._decode(js);

    return auth;
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
  ColorSys(-2),
  Pronouns(-3),
  Unknown(-9999),
  PlainText(0),
  Markdown(1),
  Color(2),
  Date(3),
  Number(4);

  const FieldType(int type) : _type = type;

  final int _type;

  static FieldType valueOf(int type) {
    if (Description._type == type) return Description;
    if (ColorSys._type == type) return ColorSys;
    if (Pronouns._type == type) return Pronouns;
    if (PlainText._type == type) return PlainText;
    if (Markdown._type == type) return Markdown;
    if (Color._type == type) return Color;
    if (Date._type == type) return Date;
    if (Number._type == type) return Number;

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
    }
  }
}

class Field {
  UUID id;
  String name;
  FieldType type;
  int order;

  Field({
    required this.id,
    required this.name,
    required this.type,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "name": name,
      "type": type.value(),
      "order": order,
    };
  }

  factory Field.fromJson(Map<String, dynamic> js) {
    UUID id = UUID.parse(js['id']);
    String name = js['name'];
    FieldType type = FieldType.valueOf(js['type']);
    int order = js['order'] ?? 0;

    return Field(id: id, name: name, type: type, order: order);
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
    if (!js.containsKey("path")) {
      throw InvalidServerResponseException(
        reason: "Response is not properly formatted",
      );
    }

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

class FieldData {
  UUID id;
  Map<String, dynamic> data = {};

  FieldData({required this.id, required this.data});

  Map<String, dynamic> toJson() {
    return {"id": id.toString(), "value": data};
  }

  factory FieldData.decode(Map<String, dynamic> js) {
    return FieldData(id: UUID.parse(js['id']), data: js['value']);
  }
}

class ChangeDetector {
  Function action = () {};
  dynamic _data;

  dynamic get value => _data;

  set data(dynamic value) {
    _data = value;
  }

  ChangeDetector(dynamic defaults) {
    _data = defaults;
    action.call();
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
  List<FieldData> fields;
  bool _stale = false;
  UUID fronterID = UUID.ZERO;

  void markStale() {
    _stale = true;
  }

  bool get stale => _stale;

  Future<void> pullUpdates() async {
    var reply = await NetworkInterface.getAlterByID(id);
    if (reply.success) {
      Alter alter = reply.data!;
      id = alter.id;
      user = alter.user;
      _stale = false;
      name = alter.name;
      avatarUrl = alter.avatarUrl;
      subid = alter.subid;
      parent = alter.parent;
      flags = alter.flags;
      fields = alter.fields;
    }
  }

  void onNewFieldData(FieldData data) {
    addOrUpdateField(data);
  }

  Alter({
    required this.id,
    required this.user,
    required this.name,
    required this.avatarUrl,
    required this.subid,
    required this.parent,
    required this.flags,
    required this.fields,
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
    };
  }

  factory Alter.decode(Map<String, dynamic> js) {
    if (!js.containsKey("subid")) {
      throw InvalidServerResponseException(reason: "Not alter formatted data");
    }
    List<dynamic> fieldsJs = [];
    try {
      var jsA = js['fields'];
      jsA ??= "eyJBIjogW119";

      var jsB = base64Encoder.base64Dec(jsA);
      var jsC = typeCorrectJsonDecode(jsB);
      fieldsJs = jsC["A"];
    } catch (A) {}

    var alter = Alter(
      id: UUID.parse(js['id']),
      user: UUID.parse(js['user']),
      name: js['name'],
      avatarUrl: js['avatar_url'],
      subid: js['subid'],
      parent: UUID.parse(js['parent']),
      flags: js['flags'],
      fields: decodeFields(fieldsJs),
    );

    return alter;
  }

  static List<FieldData> decodeFields(List<dynamic> js) {
    List<FieldData> fields = [];
    for (var entry in js) {
      fields.add(FieldData.decode(entry));
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

  FieldData getDataByFieldID(UUID id) {
    for (var field in fields) {
      if (field.id.toString() == id.toString()) return field;
    }

    return FieldData(id: id, data: {});
  }

  void addOrUpdateField(FieldData data) {
    int indx = -1;
    for (var field in fields) {
      if (field.id.toString() == data.id.toString()) {
        indx = fields.indexOf(field);
      }
    }

    if (indx == -1) {
      print("Add new fieldData: ${data.id.toString()}");
      fields.add(data);
    } else {
      print("Update field data at index $indx!");
      fields[indx].data = data.data;
    }

    sanityCheckFieldData();
  }

  void sanityCheckFieldData() {
    Set<String> seenIds = {};

    fields.removeWhere((field) {
      String id = field.id.toString();

      if (seenIds.contains(id)) {
        return true; // Remove duplicate
      }

      seenIds.add(id);
      return false; // Keep first instance
    });
  }

  Future<List<int>> getAlterColor() async {
    // Download all fields so we have the ID codes
    var reply = await NetworkInterface.getDataFields();
    List<Field> srvFields = reply.data;

    late Field targetField;

    for (var field in srvFields) {
      if (field.type == FieldType.ColorSys) {
        targetField = field;
      }
    }

    // Enumerate the data to find the field
    for (var data in fields) {
      if (data.id.toString() == targetField.id.toString()) {
        if (data.data["data"] == [0, 0, 0, 0]) return [];
        return data.data["data"];
      }
    }

    return [];
  }

  Future<bool> isFronting() async {
    var fronts = await NetworkInterface.getFronters(false);
    for (var fronter in fronts.data) {
      if (fronter.front.id.toString() == id.toString()) {
        fronterID = fronter.front.id;
        return true;
      }
    }

    return false;
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

class S2CFieldResponse extends S2CLazyResponse {
  Field data;

  S2CFieldResponse({
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
    required this.data,
  });

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);

    data = Field.fromJson(js['data']);
  }

  @override
  Map<String, dynamic> encode() {
    Map<String, dynamic> enc = super.encode();

    enc.addAll({"data": data.toJson()});

    return enc;
  }

  factory S2CFieldResponse.decode(Map<String, dynamic> js) {
    S2CFieldResponse sfr = S2CFieldResponse(
      id: UUID.ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
      data: Field(
        id: UUID.ZERO,
        name: "name",
        type: FieldType.Unknown,
        order: 0,
      ),
    );

    sfr._decode(js);

    return sfr;
  }
}

class Front {
  UUID id;
  int start;
  int end;

  Front({required this.id, required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {"alter": id.toString(), "start": start, "end": end};
  }

  factory Front.fromJson(Map<String, dynamic> js) {
    return Front(
      id: UUID.parse(js['alter'] ?? UUID.ZERO.toString()),
      start: js['start'] ?? 0,
      end: js['end'] ?? 0, // Might be null at times
    );
  }

  bool get currentFronter => end == 0;
}

class Fronter {
  UUID id;
  Front front;

  Fronter({required this.id, required this.front});

  Map<String, dynamic> toJson() {
    var M = front.toJson();
    M["id"] = id.toString();

    return M;
  }

  factory Fronter.fromJson(Map<String, dynamic> js) {
    return Fronter(id: UUID.parse(js['id']), front: Front.fromJson(js));
  }
}

class S2CFrontResponse extends S2CLazyResponse {
  Fronter data;
  S2CFrontResponse({
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
    required this.data,
  });

  @override
  Map<String, dynamic> encode() {
    var m = super.encode();
    m["data"] = data.toJson();

    return m;
  }

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);

    if (js.containsKey("data") && js['data'] != null) {
      data = Fronter.fromJson(js["data"]);
    }
  }

  factory S2CFrontResponse.fromJson(Map<String, dynamic> js) {
    S2CFrontResponse front = S2CFrontResponse(
      id: UUID.ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
      data: Fronter(
        id: UUID.ZERO,
        front: Front(id: UUID.ZERO, start: 0, end: 0),
      ),
    );

    front._decode(js);
    return front;
  }
}

class S2CFrontHistoryResponse extends S2CLazyResponse {
  List<Fronter> data;
  S2CFrontHistoryResponse({
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
    required this.data,
  });

  @override
  Map<String, dynamic> encode() {
    var m = super.encode();
    List<Map<String, dynamic>> dat = [];
    for (var fronter in data) {
      dat.add(fronter.toJson());
    }
    m["data"] = dat;

    return m;
  }

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);
    List<Map<String, dynamic>> datLst = js['data'] ?? [];

    data = [];
    for (var entry in datLst) {
      data.add(Fronter.fromJson(entry));
    }
  }

  factory S2CFrontHistoryResponse.fromJson(Map<String, dynamic> js) {
    S2CFrontHistoryResponse front = S2CFrontHistoryResponse(
      id: UUID.ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
      data: [],
    );

    front._decode(js);
    return front;
  }
}
