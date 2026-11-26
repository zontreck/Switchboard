import 'dart:convert';

import 'package:libac_dart/utils/Converter.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:mysql_dart/mysql_dart.dart';
import 'package:switchboardd/payloads.dart';

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
  static bool _blkRefresh = false;
  static void suspendRefresh() {
    _blkRefresh = true;
  }

  static void resumeRefresh() {
    _blkRefresh = false;
  }

  static bool get refreshSuspended => _blkRefresh;

  static void Function() onInvalidate = () {};

  /// To be used by any methods that would change server-side data, to force refresh on next call.
  static void invalidate() {
    if (refreshSuspended) {
      return;
    }
    registry.clear();
    onInvalidate();
  }
}

List<Map<String, dynamic>> defaultUserFields = [
  {"Name": "Description", "Type": -1, "Order": 0},
  {"Name": "Color", "Type": -2, "Order": 1},
  {"Name": "Pronouns", "Type": -3, "Order": 2},
];

Future<bool> usernameExists(MySQLConnectionPool pool, String username) async {
  await pool.withConnection((conn) async {
    var res = await conn.execute(
      "SELECT * FROM users WHERE `UserName` = :user",
      {"user": username},
      true,
    );
    if (res.numOfRows > 0) {
      return true;
    }
  });
  return false;
}

Future<void> insertNewUser(
  MySQLConnectionPool pool,
  String username,
  UUID userID,
  String passwordHash,
  String passwordSalt,
) async {
  await pool.withConnection((conn) async {
    await conn.execute(
      "INSERT INTO users (ID, UserName, PasswordHash, PasswordSalt, DisplayName) VALUES (:id, :username, :hash, :salt, :username);",
      {
        "id": userID.toString(),
        "username": username,
        "hash": passwordHash,
        "salt": passwordSalt,
      },
    );
  });
}

Future<void> sanityCheckUserFields(
  MySQLConnectionPool pool,
  UUID userID,
) async {
  await pool.withConnection((conn) async {
    for (var field in defaultUserFields) {
      if (await fieldExists(pool, userID, field["Type"])) {
        continue;
      }
      // Generate the field in the database.
      UUID fieldID = UUID.v4();

      await conn.execute(
        "INSERT INTO `Fields` (ID, User, FieldName, FieldType, SortOrder) VALUES (:id, :user, :name, :type, :order);",
        {
          "id": fieldID.toString(),
          "user": userID.toString(),
          "name": field["Name"],
          "type": field["Type"],
          "order": field["Order"],
        },
      );
    }
  });
}

Future<UUID> getFieldIDForUser(
  MySQLConnectionPool pool,
  UUID userID,
  int fieldType,
) async {
  await pool.withConnection((conn) async {
    var result = await conn.execute(
      "SELECT * FROM `Fields` WHERE `User` = :user AND `FieldType` = :type;",
      {"user": userID.toString(), "type": fieldType},
      true,
    );

    if (result.numOfRows == 0) return UUID.ZERO;

    var assoc = result.rows.first.assoc();
    return UUID.parse(assoc["ID"]);
  });

  return UUID.ZERO;
}

Future<bool> fieldExists(
  MySQLConnectionPool pool,
  UUID userID,
  int fieldType,
) async {
  return (await getFieldIDForUser(pool, userID, fieldType)) != UUID.ZERO;
}

Future<void> createNewFolder(
  MySQLConnectionPool pool,
  UUID userID,
  UUID folderID,
  String folderName,
  String? parentFolder,
  int createdAt,
  int lastModified,
) async {
  await pool.withConnection((conn) async {
    await conn.execute(
      "INSERT INTO `Folders` (ID, Name, ParentFolder, UserID, Created, Modified) VALUES (:id, :name, :parent, :user, :created, :mod);",
      {
        "id": folderID.toString(),
        "name": folderName,
        "parent": parentFolder,
        "user": userID.toString(),
        "created": createdAt,
        "mod": lastModified,
      },
    );
  });
}

Future<List<Field>> getAllUserFields(
  MySQLConnectionPool pool,
  UUID userID,
) async {
  List<Field> fields = [];
  await pool.withConnection((conn) async {
    var result = await conn.execute(
      "SELECT * FROM `Fields` WHERE `User` = :user;",
      {"user": userID.toString()},
      true,
    );

    await for (final row in result.rowsStream) {
      final assocRow = row.assoc();
      fields.add(
        Field(
          fieldID: UUID.parse(assocRow["ID"]),
          fieldName: assocRow["FieldName"],
          fieldType: assocRow["FieldType"],
          sortOrder: assocRow["SortOrder"],
        ),
      );
    }
  });

  return fields;
}

Future<int> getUserAccountLevel(MySQLConnectionPool pool, UUID userID) async {
  await pool.withConnection((conn) async {
    var res = await conn.execute("SELECT * FROM users WHERE ID=:id;", {
      "id": userID.toString(),
    }, true);
    await for (var row in res.rowsStream) {
      return row.assoc()["AccountLevel"];
    }
  });

  return 0;
}

Future<ServerUser?> getServerUser(MySQLConnectionPool pool, UUID userID) async {
  await pool.withConnection((conn) async {
    var res = await conn.execute("SELECT * FROM users WHERE `ID` = :id;", {
      "id": userID.toString(),
    });

    await for (final row in res.rowsStream) {
      var assocRow = row.assoc();
      ServerUser user = ServerUser(
        username: assocRow["UserName"],
        userID: userID,
        accountLevel: assocRow["AccountLevel"],
        passwordHash: assocRow["PasswordHash"],
        passwordSalt: assocRow["PasswordSalt"],
        displayName: assocRow["DisplayName"],
      );

      return user;
    }
  });

  return null;
}

Future<ServerUser?> getServerUserByName(
  MySQLConnectionPool pool,
  String username,
) async {
  await pool.withConnection((conn) async {
    var res = await conn.execute(
      "SELECT * FROM users WHERE `UserName` = :name;",
      {"name": username},
    );

    if (res.numOfRows == 0) return null;

    await for (final row in res.rowsStream) {
      var assocRow = row.assoc();
      ServerUser user = ServerUser(
        username: assocRow["UserName"],
        userID: UUID.parse(assocRow['ID']),
        accountLevel: assocRow["AccountLevel"],
        passwordHash: assocRow["PasswordHash"],
        passwordSalt: assocRow["PasswordSalt"],
        displayName: assocRow["DisplayName"],
      );

      return user;
    }
  });

  return null;
}

Future<void> wipeAccount(MySQLConnectionPool pool, UUID userID) async {
  await pool.withConnection((conn) async {
    // Alters
    await conn.execute("DELETE FROM `Alters` WHERE `User`=:user;", {
      "user": userID.toString(),
    });

    // Avatars
    await conn.execute("DELETE FROM `Avatars` WHERE `User`=:user;", {
      "user": userID.toString(),
    });

    // Fields
    await conn.execute(
      "DELETE FROM `Fields` WHERE `User`=:user AND `FieldType` >= 0;",
      {"user": userID.toString()},
    );

    // Images
    await conn.execute("DELETE FROM `Images` WHERE `OwnerID`=:user;", {
      "user": userID.toString(),
    });

    // Fronting
    await conn.execute("DELETE FROM `Fronting` WHERE `User`=:user;", {
      "user": userID.toString(),
    });

    // FolderEntries
    await conn.execute("DELETE FROM `FolderEntries` WHERE `UserID`=:user;", {
      "user": userID.toString(),
    });

    // Folders
    await conn.execute(
      "DELETE FROM `Folders` WHERE `UserID`=:user AND `ParentFolder` IS NULL AND `Name` != 'root';",
      {"user": userID.toString()},
    );
    await conn.execute(
      "DELETE FROM `Folders` WHERE `UserID`=:user AND `ParentFolder` IS NOT NULL;",
      {"user": userID.toString()},
    );
  });
}

Future<void> updateUserPassword(
  MySQLConnectionPool pool,
  UUID user,
  String hash,
  String salt,
) async {
  await pool.withConnection((conn) async {
    await conn.execute(
      "UPDATE `users` SET `PasswordSalt` = :salt WHERE `ID` = :id;",
      {"salt": salt, "id": user.toString()},
    );
    await conn.execute(
      "UPDATE `users` SET `PasswordHash` = :hash WHERE `ID` = :id;",
      {"hash": hash, "id": user.toString()},
    );
  });
}

Future<List<ServerAlter>> getAlters(
  MySQLConnectionPool pool,
  UUID user, {
  int skip = 0,
  int count = 0,
  bool chunking = false,
}) async {
  // Get a list of alters from the server.
  await pool.withConnection((conn) async {
    IResultSet res;
    if (!chunking) {
      res = await conn.execute(
        "SELECT * FROM `Alters` WHERE `User` = :user ORDER BY SubID ASC;",
        {"user": user.toString()},
        true,
      );
    } else {
      res = await conn.execute(
        "SELECT * FROM `Alters` WHERE `User` = :user ORDER BY SubID ASC LIMIT :count OFFSET :skip;",
        {"user": user.toString(), "count": count, "skip": skip},
        true,
      );
    }

    // Iterate the result to generate the list of alters
    List<ServerAlter> ret = [];
    await for (final rw in res.rowsStream) {
      var row = rw.assoc();

      ServerAlter alter = ServerAlter(
        id: UUID.parse(row['ID']),
        user: UUID.parse(row['User']),
        name: row['Name'],
        avatarUrl: row['Avatar'],
        subid: row['SubID'],
        parent: UUID.parse(row['ParentID']),
        flags: row['Flags'],
        fields: ServerAlter.decodeFields(
          ServerAlter.parseFields(base64Encoder.base64Enc(row['Fields'])),
        ),
        proxyName: row['ProxyName'],
        proxies: json.decode(row['Proxies']),
      );

      ret.add(alter);
    }

    return ret;
  });

  return [];
}

Future<int> getAlterCount(MySQLConnectionPool pool, UUID user) async {
  await pool.withConnection((conn) async {
    var res = await conn.execute(
      "SELECT * FROM `Alters` WHERE `User` = :user;",
      {"user": user.toString()},
    );

    return res.numOfRows;
  });

  return 0;
}
