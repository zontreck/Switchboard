import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/api.dart';
import 'package:switchboard/dart/exceptions.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboardd/funcs.dart';
import 'package:switchboardd/network.dart';
import 'package:switchboardd/payloads.dart';
import 'package:synchronized/synchronized.dart';

/// Here, we will have a packet system to send and receive data.
/// If a packet has been tested using a testsuite, and it worked, it will have been turned into a Packet here.
class NetworkInterface {
  static final _lGetServerVersion = Lock();
  static final _lPutNewUser = Lock();
  static final _lGetUser = Lock();
  static final _lAuthenticate = Lock();
  static final _lCheckAuth = Lock();
  static final _lRefreshAuth = Lock();
  static final _lRequestAltersList = Lock();
  static final _lMakeNewAlter = Lock();
  static final _lGetAlterByID = Lock();
  static final _lGetDataFields = Lock();
  static final _lUpdateField = Lock();
  static final _lGetField = Lock();
  static final _lNewField = Lock();
  static final _lDeleteField = Lock();
  static final _lUpdateAlter = Lock();
  static final _lDeleteAvatar = Lock();
  static final _lUpdateAvatar = Lock();
  static final _lMigrateAvatar = Lock();
  static final _lWipeAccount = Lock();
  static final _lGetFronters = Lock();
  static final _lSetFronting = Lock();
  static final _lInsertFronter = Lock();
  static final _lDeleteFronter = Lock();
  static final _lUnfrontFronter = Lock();
  static final _lDeleteAlter = Lock();
  static final _lDeleteFolder = Lock();
  static final _lMakeFolder = Lock();
  static final _lChangePassword = Lock();
  static final _lUpdateFolder = Lock();
  static final _lAddFolderItem = Lock();
  static final _lGetFolderItem = Lock();
  static String _apiUrl = getMainServerURL();
  static String get apiServerURL => _apiUrl;
  static set apiServerURL(String value) {
    _apiUrl = value;
    NetworkCaches.invalidate();
  }

  /// Retrieval of a cache object, if present.
  ///
  /// [fn] The function's name by which the object would be stored.
  static NetworkCache? getCache(String fn) {
    if (NetworkCaches.registry.containsKey(fn)) {
      NetworkCache fnCache = NetworkCaches.registry[fn]!;
      if (fnCache.isStale()) {
        NetworkCaches.registry.remove(fn);
      } else {
        print("Cache hit for $fn");
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

  static Future<ServerVersionResponse> getServerVersion() async {
    return await _lGetServerVersion.synchronized(() async {
      var cached = getCache("getServerVersion");
      if (cached != null) {
        return ServerVersionResponse.fromJson(
          typeCorrectJson(cached.responseData),
        );
      }
      Dio dio = Dio();
      dio.options.contentType = "application/json";
      var reply = await dio.get("$apiServerURL/version");

      print(reply.data);
      setCache("getServerVersion", reply.data);

      return ServerVersionResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  static Future<ServerUserResponse> putNewUser(
    String username,
    String password,
  ) async {
    return await _lPutNewUser.synchronized(() async {
      Dio dio = Dio();
      dio.options.contentType = "application/json";
      var reply = await dio.put(
        "$apiServerURL/user/$username",
        data: {"auth": Hashing.md5Hash(password)},
      );

      print(reply.data);

      // Deserialize the make new user packet
      var response = ServerUserResponse.fromJson(typeCorrectJson(reply.data));
      NetworkCaches.invalidate();

      return response;
    });
  }

  static Future<S2CUserPacket> getUser(String username) async {
    return await _lGetUser.synchronized(() async {
      var cached = getCache("getUser$username");
      if (cached != null) {
        return S2CUserPacket.decode(cached.responseData);
      }
      Dio dio = Dio();
      dio.options.contentType = "application/json";
      dio.options.headers["Authorization"] = MemoryState.A.authenticationToken;

      var reply = await dio.get(
        "$apiServerURL/user${username.isNotEmpty ? "/$username" : ""}",
      );

      print(reply.data);
      setCache("getUser$username", reply.data);

      return S2CUserPacket.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<ServerAuthenticationResponse> authenticate(
    String username,
    String password,
  ) async {
    return await _lAuthenticate.synchronized(() async {
      Dio dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";

      var reply = await dio.post(
        "$apiServerURL/auth/login",
        data: {"username": username, "auth": Hashing.md5Hash(password)},
      );

      print(reply.data);
      MemoryState.A.username = username;

      return ServerAuthenticationResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  static Future<BasicResponse> checkAuth() async {
    return await _lCheckAuth.synchronized(() async {
      MemoryState ms = MemoryState();
      Dio dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["Authorization"] = ms.authenticationToken;

      var reply = await dio.get("$apiServerURL/auth/check");

      print(reply.data);

      BasicResponse br = BasicResponse(
        Success: false,
        Path: "Path",
        Method: "Method",
        ID: UUID.ZERO,
        Reason: "Reason",
      );
      br.decode(typeCorrectJson(reply.data));

      return br;
    });
  }

  static Future<S2CAuthenticationRefreshResponse> refreshAuth() async {
    return await _lRefreshAuth.synchronized(() async {
      MemoryState ms = MemoryState();
      Dio dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("$apiServerURL/auth/refresh");

      print(reply.data);
      return S2CAuthenticationRefreshResponse.decode(
        typeCorrectJson(reply.data),
      );
    });
  }

  static Future<S2CAltersResponse> requestAltersList(String? user) async {
    return await _lRequestAltersList.synchronized(() async {
      var cached = getCache("requestAltersList${user ?? ""}");
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
          "$apiServerURL/alters${user == null ? '?skip=$skip&count=$request' : "/${user.toString()}"}?skip=$skip&count=$request",
        );

        print(reply.data);
        // Check for the X-SB-Done header.
        print(reply.headers);
        bool isDone = reply.data["data"]?["done"];
        if (!isDone) {
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
        } else {
          ms.lastErrorRay = "";
        }

        S2CAltersPartialResponse partialAlters =
            S2CAltersPartialResponse.decode(typeCorrectJson(reply.data));
        if (reply.headers.value("X-SB-Count") == null) {
          skip += partialAlters.data.count;
        }

        allAlters.addAll(partialAlters.data.alters);
      }

      setCache("requestAltersList", allAlters);

      return S2CAltersResponse(alters: allAlters);
    });
  }

  // TODO: Make it possible to set a parent folder once folders are implemented.
  static Future<S2CAlterResponse> makeNewAlter(String name) async {
    return await _lMakeNewAlter.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      // Send the creation packet!
      var reply = await dio.put(
        "$apiServerURL/alter/new",
        data: {
          "alter": {
            "name": name,
            "parent": UUID_ZERO,
            "subid": 0,
            "avatar": UUID_ZERO,
          },
        },
      );

      print(reply.data);
      NetworkCaches.invalidate();

      return S2CAlterResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CAlterResponse> getAlterByID(String id) async {
    return await _lGetAlterByID.synchronized(() async {
      var cached = getCache("getAlter${id.toString()}");
      if (cached != null) {
        return S2CAlterResponse.decode(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("$apiServerURL/alter/${id.toString()}");

      print(reply.data);
      setCache("getAlter${id.toString()}", reply.data);

      return S2CAlterResponse.decode(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CFieldsResponse> getDataFields() async {
    return await _lGetDataFields.synchronized(() async {
      var cached = getCache("getDataFields");
      if (cached != null) {
        return S2CFieldsResponse.fromJson(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("$apiServerURL/fields");
      print(reply.data);
      setCache("getDataFields", reply.data);

      return S2CFieldsResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  static Future<S2CFieldResponse> updateField(ServerField field) async {
    return await _lUpdateField.synchronized(() async {
      // Construct a packet to update the field!
      Map<String, dynamic> payload = field.encode();
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post(
        "$apiServerURL/field/${field.fieldID.toString()}",
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

  static Future<S2CFieldResponse> getField(String fieldID) async {
    return await _lGetField.synchronized(() async {
      var cached = getCache("getField${fieldID.toString()}");
      if (cached != null) {
        return S2CFieldResponse.decode(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("$apiServerURL/field/${fieldID.toString()}");

      print(reply.data);
      S2CFieldResponse sfr = S2CFieldResponse.decode(
        typeCorrectJson(reply.data),
      );
      setCache("getField${fieldID.toString()}", reply.data);

      return sfr;
    });
  }

  /// Create a new field
  ///
  /// [name] The name to give the new field.
  static Future<S2CFieldResponse> newField(String name) async {
    return await _lNewField.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      ServerField newField = ServerField(
        fieldID: UUID.ZERO,
        fieldName: name,
        fieldType: ServerFieldType.PlainText,
        sortOrder: 999,
      );
      var reply = await dio.post(
        "$apiServerURL/field/new",
        data: newField.encode(),
      );

      print(reply.data);
      NetworkCaches.invalidate();
      S2CFieldResponse sfr = S2CFieldResponse.decode(
        typeCorrectJson(reply.data),
      );

      return sfr;
    });
  }

  /// Delete a field by ID from the server
  ///
  /// [id] The field's ID to delete. Must be owned by the currently logged in user.
  static Future<S2CLazyResponse> deleteField(String id) async {
    return await _lDeleteField.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete("$apiServerURL/field/${id.toString()}");
      NetworkCaches.invalidate();

      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Update alter details on the server.
  ///
  /// [alter] The alter to update
  static Future<S2CLazyResponse> updateAlter(Alter alter) async {
    return await _lUpdateAlter.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      if (alter.encode().isEmpty) {
        alter.encode();
        throw Exception(
          "FATAL: Encoded alter is blank, something went horribly wrong",
        );
      }

      var reqData = {"alter": alter.encode()};

      if (reqData["alter"] == null) {
        alter.encode();
        throw Exception(
          "FATAL: Alter is null in encoded stream, something went horribly wrong",
        );
      }

      var reply = await dio.patch(
        "$apiServerURL/alter/${alter.id.toString()}",
        data: reqData,
      );
      NetworkCaches.invalidate();

      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Request deletion of the avatar for an alter
  ///
  /// [alter] The alter to remove the profile picture for
  static Future<S2CLazyResponse> deleteAvatar(Alter alter) async {
    return await _lDeleteAvatar.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete(
        "$apiServerURL/avatar/${alter.id.toString()}",
      );
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Update the avatar image for the alter
  ///
  /// [alter] The alter to update
  /// [base64EncodedImage] The raw image data encoded as base64
  static Future<S2CLazyResponse> updateAvatar(
    Alter alter,
    String base64EncodedImage,
  ) async {
    return await _lUpdateAvatar.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post(
        "$apiServerURL/avatar/${alter.id.toString()}",
        data: {"image": base64EncodedImage},
      );

      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Migrates an avatar image from one hosting service to our own.
  ///
  /// [url] The URL to migrate
  /// [alterID] The alter ID to store the image for
  static Future<bool> migrateAvatar(String url, String alterID) async {
    return await _lMigrateAvatar.synchronized(() async {
      Dio dio = Dio();
      dio.options.responseType = ResponseType.bytes;

      var reply = await dio.get(
        url,
        options: Options(
          headers: {
            "User-Agent":
                "Switchboard/v${MemoryState.A.applicationVersion} client",
          },
          receiveDataWhenStatusError: true,
        ),
      );
      if (reply.statusCode != 200) {
        return false;
      }

      var alterReply = await NetworkInterface.getAlterByID(alterID);

      var updateReply = await NetworkInterface.updateAvatar(
        alterReply.data!,
        base64Encoder.base64EncBytes(reply.data),
      );
      NetworkCaches.invalidate();

      return updateReply.success;
    });
  }

  /// Wipe the user account, erasing all data except the account itself.
  static Future<S2CLazyResponse> wipeAccount() async {
    return await _lWipeAccount.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.get("$apiServerURL/wipe");
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Retrieve all fronters from the database.
  ///
  /// [history] Whether to obtain all history or only current fronters
  static Future<S2CFrontHistoryResponse> getFronters(bool history) async {
    return await _lGetFronters.synchronized(() async {
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

      var reply = await dio.get("$apiServerURL/fronting?history=$history");
      setCache("getFronters${history ? "history" : "active"}", reply.data);
      print(reply.data);

      return S2CFrontHistoryResponse.fromJson(typeCorrectJson(reply.data));
    });
  }

  /// Set an alter as currently fronting
  ///
  /// [alterID] The ID of the alter you wish to set as fronting
  static Future<S2CFrontResponse> setFronting(String alterID) async {
    return await _lSetFronting.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post(
        "$apiServerURL/fronting",
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
    return await _lInsertFronter.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.put("$apiServerURL/fronting", data: front.toJson());
      NetworkCaches.invalidate();
      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Deletes a fronter
  ///
  /// [front] Fronter ID to be deleted
  static Future<S2CLazyResponse> deleteFronter(String front) async {
    return await _lDeleteFronter.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete(
        "$apiServerURL/fronting",
        data: {"id": front.toString()},
      );
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Remove a fronter from current front status
  ///
  /// [alter] Fronter ID to update the end time for.
  static Future<S2CLazyResponse> unfrontFronter(String alter) async {
    return await _lUnfrontFronter.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.patch(
        "$apiServerURL/fronting",
        data: {"id": alter.toString()},
      );
      NetworkCaches.invalidate();
      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Permanently delete a requested alter
  ///
  /// [alter] Alter ID to be permanently deleted. (Must be your own)
  static Future<S2CLazyResponse> deleteAlter(String alter) async {
    return await _lDeleteAlter.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete("$apiServerURL/alter/$alter");

      NetworkCaches.invalidate();
      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Renames a folder/entry
  ///
  /// [id] The item to rename
  /// [name] New name for the item
  /// [isFolder] Whether the item is a folder, or a Item
  static Future<S2CLazyResponse> updateFolderItem(
    String id,
    String name,
    bool isFolder,
    String color,
    String desc,
  ) async {
    return await _lUpdateFolder.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.patch(
        "$apiServerURL/folders",
        data: {
          "id": id,
          "name": name,
          "folder": isFolder ? 1 : 0,
          "color": color,
          "desc": desc,
        },
      );
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Deletes a folder/entry
  ///
  /// [id] The item to delete
  /// [isFolder] Whether the item is a folder, or a Item
  static Future<S2CLazyResponse> deleteFolderItem(
    String id,
    bool isFolder,
  ) async {
    return await _lDeleteFolder.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.delete(
        "$apiServerURL/folders",
        data: {"id": id, "folder": isFolder ? 1 : 0},
      );
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Creates a folder.
  /// NOTE: The folder will not have a parent by default. It will need to be moved to the root folder, or it's destination in a subsequent call after you have the new ID.
  ///
  /// [name] Folder name to generate
  static Future<S2CFolderReply> createFolder(String name) async {
    return await _lMakeFolder.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.post("$apiServerURL/folders", data: {"name": name});
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CFolderReply.decode(typeCorrectJson(reply.data));
    });
  }

  /// Add a folder or item to the contents of a folder
  ///
  /// [id] The ID to be added as an item
  /// [parent] The containing folder
  /// [name] Name of the item. (For folders, MUST match the folder name.)
  /// [isFolder] Indicate whether the type of item is a Folder.
  /// [isAlter] Indicate whether the type of item is an alter.
  /// [isAvatar] Indicates whether the type of item is an avatar image.
  /// [isImage] Indicates whether the type of item is an Image.
  static Future<S2CLazyResponse> addToFolderContents(
    String id,
    String parent,
    String name,
    bool isFolder,
    bool isAlter,
    bool isAvatar,
    bool isImage,
  ) async {
    return await _lAddFolderItem.synchronized(() async {
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      String type = "x-sb/unknown";

      if (isFolder) {
        type = "sb/folder";
      } else if (isAlter) {
        type = "sb/alter";
      } else if (isAvatar) {
        type = "sb/avatar";
      } else if (isImage) {
        type = "sb/img";
      }

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var reply = await dio.put(
        "$apiServerURL/folders",
        data: {
          "id": id,
          "name": name,
          "type": type,
          "parent": parent,
          "folder": isFolder ? 1 : 0,
        },
      );
      print(reply.data);
      NetworkCaches.invalidate();

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }

  /// Add a folder or item to the contents of a folder
  ///
  /// [id] The ID to be added as an item
  /// [rootOnly] Indicates to the server if we only want the root folder. Useful when you do not know the RootFolderID
  static Future<S2CFolderReply> getFolderOrItem(
    String id,
    bool rootOnly,
  ) async {
    return await _lGetFolderItem.synchronized(() async {
      var cached = getCache("getFolderOrItem${rootOnly ? "root" : id}");
      if (cached != null) {
        return S2CFolderReply.decode(typeCorrectJson(cached.responseData));
      }
      Dio dio = Dio();
      MemoryState ms = MemoryState();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = ms.authenticationToken;

      var q = {"id": id, "root": rootOnly ? 1 : 0};
      var qStr = base64Encoder.base64Enc(json.encode(q));

      var reply = await dio.get("$apiServerURL/folders?q=$qStr");
      print(reply.data);

      setCache("getFolderOrItem${rootOnly ? "root" : id}", reply.data);

      return S2CFolderReply.decode(typeCorrectJson(reply.data));
    });
  }

  /// Change the account password
  static Future<S2CLazyResponse> updatePassword(String newPassword) async {
    return await _lChangePassword.synchronized(() async {
      String MD5Hash = Hashing.md5Hash(newPassword);
      Dio dio = Dio();

      dio.options.headers["Content-Type"] = "application/json";
      dio.options.headers["X-SB-Auth"] = MemoryState.A.authenticationToken;

      var reply = await dio.post(
        "$apiServerURL/auth/password",
        data: {"auth": MD5Hash},
      );

      print(reply.data);

      return S2CLazyResponse.decode(typeCorrectJson(reply.data));
    });
  }
}

class XSBType {
  bool isFolder;
  bool isAlter;
  bool isAvatar;
  bool isImage;

  XSBType._({
    required this.isAlter,
    required this.isAvatar,
    required this.isFolder,
    required this.isImage,
  });

  String toJson() {
    if (isFolder) return "sb/folder";
    if (isAlter) return "sb/alter";
    if (isAvatar) return "sb/avatar";
    if (isImage) return "sb/img";

    return "x-sb/unknown";
  }

  factory XSBType.fromTypeString(String type) {
    switch (type) {
      case "sb/folder":
        {
          return XSBType._(
            isAlter: false,
            isAvatar: false,
            isFolder: true,
            isImage: false,
          );
        }
      case "sb/alter":
        {
          return XSBType._(
            isAlter: true,
            isAvatar: false,
            isFolder: false,
            isImage: false,
          );
        }
      case "sb/avatar":
        {
          return XSBType._(
            isAlter: false,
            isAvatar: true,
            isFolder: false,
            isImage: false,
          );
        }
      case "sb/img":
        {
          return XSBType._(
            isAlter: false,
            isAvatar: false,
            isFolder: false,
            isImage: true,
          );
        }
      default:
        {
          return XSBType._(
            isAlter: false,
            isAvatar: false,
            isFolder: false,
            isImage: false,
          );
        }
    }
  }
}

abstract class ResponsePacket {
  late String id;
  late String path;
  late String type;
  late String? reason;
  late bool success;
}

class S2CLazyResponse implements ResponsePacket {
  @override
  String id;

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
      id: UUID_ZERO,
      path: "",
      reason: "reason",
      success: false,
      type: "",
    );

    lz._decode(js);

    return lz;
  }

  void _decode(Map<String, dynamic> js) {
    id = js['id'] ?? UUID_ZERO;
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

class S2CUserPacket extends S2CLazyResponse {
  ClientUser? data;

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
      data = ClientUser.deserialize(js['data']);
    }
  }

  factory S2CUserPacket.decode(Map<String, dynamic> js) {
    S2CUserPacket pkt = S2CUserPacket(
      data: null,
      id: UUID_ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
    );
    pkt._decode(js);

    return pkt;
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
  String id;

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
      id: js['id'],
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
  String id;

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
      id: js['id'],
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: PartialAlters.decode(js['data']),
    );
  }
}

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

class S2CFieldsResponse implements ResponsePacket {
  @override
  String id;

  @override
  String path;

  @override
  String? reason;

  @override
  bool success;

  @override
  String type;

  List<ServerField> data;

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
      fieldJs.add(field.encode());
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

    List<ServerField> fieldList = [];
    for (var entry in js['data']) {
      fieldList.add(ServerField.decode(entry));
    }

    return S2CFieldsResponse(
      id: js['id'],
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: fieldList,
    );
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

class Alter extends ServerAlter {
  bool _stale = false;

  Alter({
    required super.id,
    required super.user,
    required super.name,
    required super.avatarUrl,
    required super.subid,
    required super.parent,
    required super.flags,
    required super.fields,
    required super.proxyName,
    required super.proxies,
  });

  factory Alter.decode(Map<String, dynamic> js) {
    var x = ServerAlter.decode(js);

    return Alter(
      id: x.id,
      user: x.user,
      name: x.name,
      avatarUrl: x.avatarUrl,
      subid: x.subid,
      parent: x.parent,
      flags: x.flags,
      fields: x.fields,
      proxyName: x.proxyName,
      proxies: x.proxies,
    );
  }

  void markStale() {
    _stale = true;
  }

  bool get stale => _stale;

  Future<void> pullUpdates() async {
    if (!stale) return;
    var reply = await NetworkInterface.getAlterByID(super.id.toString());
    if (reply.success) {
      Alter alter = reply.data!;
      super.id = alter.id;
      super.user = alter.user;
      _stale = false;
      super.name = alter.name;
      super.avatarUrl = alter.avatarUrl;
      super.subid = alter.subid;
      super.parent = alter.parent;
      super.flags = alter.flags;
      super.fields = alter.fields;
      super.proxyName = alter.proxyName;
      super.proxies = alter.proxies;
      await isFronting();
    }
  }

  Future<String> getPronouns() async {
    var reply = await NetworkInterface.getDataFields();
    for (var field in reply.data) {
      if (field.fieldType == ServerFieldType.Pronouns) {
        for (var entry in fields) {
          if (entry.id.toString() == field.fieldID.toString()) {
            return entry.data["data"];
          }
        }
      }
    }

    return "";
  }

  void onNewFieldData(ServerFieldData data) {
    addOrUpdateField(data);
  }

  /// This helper function determines if the proper URL is to the Switchboard CDN, or a external network.
  String getAvatarURL() {
    String url = avatarUrl.startsWith("http")
        ? avatarUrl
        : "${NetworkInterface.apiServerURL}/avatar/${id.toString()}";

    return url;
  }

  /// This helper function determines if the proper URL is to the Switchboard CDN, or a external network.
  static String makeAvatarURL(String input) {
    String url = input.startsWith("http")
        ? input
        : "${NetworkInterface.apiServerURL}/avatar/$input";

    return url;
  }

  ServerFieldData getDataByFieldID(UUID id) {
    for (var field in fields) {
      if (field.id.toString() == id.toString()) return field;
    }

    return ServerFieldData(id: id, data: {});
  }

  void addOrUpdateField(ServerFieldData data) {
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
    List<ServerField> srvFields = reply.data;

    late ServerField targetField;

    for (var field in srvFields) {
      if (field.fieldType == ServerFieldType.ColorSys) {
        targetField = field;
      }
    }

    // Enumerate the data to find the field
    for (var data in fields) {
      if (data.id.toString() == targetField.fieldID.toString()) {
        if (data.data["data"] == [0, 0, 0, 0]) return [];
        return data.data["data"];
      }
    }

    return [];
  }

  Future<Fronter> isFronting() async {
    var fronts = await NetworkInterface.getFronters(false);
    for (var fronter in fronts.data) {
      if (fronter.front.alterId.toString() == id.toString()) {
        return fronter;
      }
    }

    return Fronter(
      id: UUID_ZERO,
      front: Front(alterId: id.toString(), start: 0, end: 0),
    );
  }
}

class S2CAltersResponse {
  final List<Alter> alters;

  S2CAltersResponse({required this.alters});
}

class S2CAlterResponse implements ResponsePacket {
  @override
  String id;

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
      id: js['id'],
      path: js['path'],
      reason: js['reason'],
      success: js['success'],
      type: js['type'],
      data: Alter.decode(js['data'] ?? {}),
    );
  }
}

class S2CFieldResponse extends S2CLazyResponse {
  ServerField data;

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

    data = ServerField.decode(js['data']);
  }

  @override
  Map<String, dynamic> encode() {
    Map<String, dynamic> enc = super.encode();

    enc.addAll({"data": data.encode()});

    return enc;
  }

  factory S2CFieldResponse.decode(Map<String, dynamic> js) {
    S2CFieldResponse sfr = S2CFieldResponse(
      id: UUID_ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
      data: ServerField(
        fieldID: UUID.ZERO,
        fieldName: "name",
        fieldType: ServerFieldType.Unknown,
        sortOrder: 0,
      ),
    );

    sfr._decode(js);

    return sfr;
  }
}

class Front {
  String alterId;
  int start;
  int end;

  Front({required this.alterId, required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {"alter": alterId, "start": start, "end": end};
  }

  factory Front.fromJson(Map<String, dynamic> js) {
    return Front(
      alterId: js['alter'] ?? UUID_ZERO,
      start: js['start'] ?? 0,
      end: js['end'] ?? 0, // Might be null at times
    );
  }

  bool get currentFronter => end == 0 && start > 0;
}

class Fronter {
  String id;
  Front front;

  Fronter({required this.id, required this.front});

  Map<String, dynamic> toJson() {
    var M = front.toJson();
    M["id"] = id.toString();

    return M;
  }

  factory Fronter.fromJson(Map<String, dynamic> js) {
    return Fronter(id: js['id'], front: Front.fromJson(js));
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
      id: UUID_ZERO,
      path: "path",
      reason: "reason",
      success: false,
      type: "type",
      data: Fronter(
        id: UUID_ZERO,
        front: Front(alterId: UUID_ZERO, start: 0, end: 0),
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
      id: UUID_ZERO,
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

class FolderEntry {
  String name;
  String id;
  XSBType type;
  String target;
  DateTime created;

  FolderEntry({
    required this.name,
    required this.created,
    required this.id,
    required this.target,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type.toJson(),
      "target": target,
      "created": created,
    };
  }

  factory FolderEntry.decode(Map<String, dynamic> js) {
    return FolderEntry(
      name: js['name'],
      created: TimeUtils.parseTimestamp(js['created']),
      id: js['id'],
      target: js['target'],
      type: XSBType.fromTypeString(js['type']),
    );
  }
}

class Folder {
  String id;
  String name;
  DateTime created;
  DateTime modified;
  String color;
  String desc;
  List<FolderEntry> contents;

  Folder({
    required this.id,
    required this.name,
    required this.created,
    required this.modified,
    required this.color,
    required this.desc,
    required this.contents,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsx = [];
    for (var entry in contents) {
      jsx.add(entry.toJson());
    }

    return {
      "id": id,
      "name": name,
      "created": created,
      "modified": modified,
      "color": color,
      "desc": desc,
      "contents": contents,
    };
  }

  factory Folder.decode(Map<String, dynamic> js) {
    List<FolderEntry> entries = [];
    for (var entry in js['contents']) {
      entries.add(FolderEntry.decode(entry));
    }

    return Folder(
      id: js['id'],
      name: js['name'],
      created: TimeUtils.parseTimestamp(js['created']),
      modified: TimeUtils.parseTimestamp(js['modified']),
      color: js['color'],
      desc: js['desc'] ?? "",
      contents: entries,
    );
  }
}

class S2CFolderReply extends S2CLazyResponse {
  Folder data;
  S2CFolderReply({
    required super.id,
    required super.path,
    required super.reason,
    required super.success,
    required super.type,
    required this.data,
  });

  @override
  Map<String, dynamic> encode() {
    var rep = super.encode();
    rep.addAll({"data": data.toJson()});

    return rep;
  }

  @override
  void _decode(Map<String, dynamic> js) {
    super._decode(js);

    data = Folder.decode(js['data']);
  }

  factory S2CFolderReply.decode(Map<String, dynamic> js) {
    S2CFolderReply reply = S2CFolderReply(
      id: UUID_ZERO,
      path: "",
      reason: "reason",
      success: false,
      type: "type",
      data: Folder(
        id: UUID_ZERO,
        name: "name",
        created: DateTime.now(),
        modified: DateTime.now(),
        color: "",
        desc: "",
        contents: [],
      ),
    );

    reply._decode(js);

    return reply;
  }
}
