import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:mysql_dart/mysql_dart.dart';
import 'package:switchboardd/consts.dart';
import 'package:switchboardd/payloads.dart';

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
