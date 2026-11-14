import 'package:libac_dart/omv/types/constants.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:mysql_dart/mysql_dart.dart';

/// This file contains all instructions related to the migration system.
///
/// 1. Migrator class
/// 2. Migration subclasses
///
/// Criteria:
/// Migrations must be simple and easy to implement. They should not require
/// excessive effort to implement.

/// Base class for all database migrations.
abstract class Migration {
  /// A unique identifier for this migration.
  ///
  /// This should generally be a timestamp or another sortable identifier.
  String get migrationID;

  /// Executes the migration.
  Future<void> execute(MySQLConnection connection);
}

/// Creates the table used to track executed migrations.
class MIGCreateMigrationsTable implements Migration {
  @override
  String get migrationID => '0001_MakeMigrationsTable';

  @override
  Future<void> execute(MySQLConnection connection) async {
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS migrations (
        migration VARCHAR(255) NOT NULL UNIQUE PRIMARY KEY
      )
    ''');
  }
}

/// Initializes the database using the basic tables
///
/// NOTE: Migration history was squashed after the alpha build was stabilized.
class MIGInitializeDB implements Migration {
  @override
  Future<void> execute(MySQLConnection connection) async {
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `users` (
        `UserName` varchar(64) DEFAULT NULL, 
        `PasswordSalt` varchar(255) DEFAULT NULL, 
        `PasswordHash` varchar(255) DEFAULT NULL, 
        `DisplayName` varchar(255) DEFAULT NULL, 
        `ID` varchar(64) NOT NULL, 
        `AccountLevel` int(11) NOT NULL DEFAULT 1, 
        PRIMARY KEY (`ID`), 
        UNIQUE KEY `UserName` (`UserName`)) 
        ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Access` (  
        `User` varchar(64) DEFAULT NULL,  
        `Token` varchar(64) NOT NULL,  
        `TokenScope` int(11) NOT NULL DEFAULT 0,  
        `TokenFlags` int(11) NOT NULL DEFAULT 0,  
        `Expire` int(11) NOT NULL DEFAULT 0,  
        `IssuedAt` int(11) NOT NULL DEFAULT 0,  
        PRIMARY KEY (`Token`),  
        UNIQUE KEY `User` (`User`,`Token`),  
        CONSTRAINT `Access_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) 
        ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Alters` (  
        `User` varchar(64) NOT NULL,  
        `ID` varchar(64) NOT NULL,  
        `Name` varchar(255) DEFAULT NULL,  
        `Avatar` varchar(64) DEFAULT NULL,  
        `Fields` blob DEFAULT NULL,  
        `SubID` int(11) DEFAULT NULL,  
        `ParentID` varchar(64) DEFAULT NULL,  
        `Flags` int(11) NOT NULL DEFAULT 0,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `ID` (`ID`),  
        KEY `User` (`User`),  
        CONSTRAINT `Alters_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Audit` ( 
        `ID` varchar(64) NOT NULL,  
        `RequestType` varchar(12) DEFAULT NULL,  
        `RequestPath` varchar(255) DEFAULT NULL,  
        `RequestData` text DEFAULT NULL,  
        `RequestHeaders` text CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL, 
        `Timestamp` int(11) NOT NULL,  
        PRIMARY KEY (`ID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Avatars` (  
        `User` varchar(64) NOT NULL,  
        `AlterId` varchar(64) NOT NULL,  
        `ImageType` varchar(255) NOT NULL DEFAULT 'image/webp',  
        `ImageBinary` longblob NOT NULL,  
        `Timestamp` int(11) NOT NULL,  
        PRIMARY KEY (`AlterId`),  
        UNIQUE KEY `AlterId` (`AlterId`),  
        KEY `User` (`User`),  
        CONSTRAINT `Avatars_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,  
        CONSTRAINT `Avatars_ibfk_2` FOREIGN KEY (`AlterId`) REFERENCES `Alters` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Feedback` (  
        `User` varchar(64) NOT NULL,  
        `ID` varchar(64) NOT NULL,  
        `Name` varchar(255) NOT NULL,  
        `Type` int(11) NOT NULL,  
        `Status` int(11) NOT NULL DEFAULT 0, 
        `RootMessage` varchar(64) DEFAULT NULL, 
        `LastMessage` varchar(64) DEFAULT NULL,  
        `Created` int(11) NOT NULL,  
        `Updated` int(11) NOT NULL,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `ID` (`ID`),  
        KEY `User` (`User`),  
        CONSTRAINT `Feedback_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `FeedbackMessages` (  
        `ID` varchar(64) NOT NULL,  
        `Feedback` varchar(64) NOT NULL,  
        `User` varchar(64) NOT NULL,  
        `Message` text NOT NULL,  
        `Created` int(11) NOT NULL,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `ID` (`ID`),  
        KEY `User` (`User`),  
        KEY `Feedback` (`Feedback`),  
        CONSTRAINT `FeedbackMessages_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,  
        CONSTRAINT `FeedbackMessages_ibfk_2` FOREIGN KEY (`Feedback`) REFERENCES `Feedback` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Fields` (  
        `User` varchar(64) NOT NULL,  
        `ID` varchar(64) NOT NULL,  
        `FieldName` varchar(255) NOT NULL,  
        `FieldType` int(11) NOT NULL DEFAULT 1,  
        `SortOrder` int(11) NOT NULL DEFAULT 0,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `User` (`User`,`ID`),  
        CONSTRAINT `Fields_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Fronting` ( 
        `ID` varchar(64) NOT NULL,  
        `User` varchar(64) NOT NULL,  
        `AlterID` varchar(64) NOT NULL,  
        `StartTime` int(11) NOT NULL DEFAULT 0,  
        `EndTime` int(11) NOT NULL DEFAULT 0,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `ID` (`ID`),  
        KEY `User` (`User`),  
        KEY `AlterID` (`AlterID`),  
        CONSTRAINT `Fronting_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE, 
        CONSTRAINT `Fronting_ibfk_2` FOREIGN KEY (`AlterID`) REFERENCES `Alters` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS `Images` (  
        `OwnerID` varchar(64) NOT NULL,  
        `ImageID` varchar(64) NOT NULL,  
        `ImageType` varchar(255) NOT NULL DEFAULT 'image/webp', 
        `ImageBinary` longblob NOT NULL,  
        `Timestamp` int(11) NOT NULL,  
        PRIMARY KEY (`ImageID`),  
        UNIQUE KEY `ImageID` (`ImageID`), 
        KEY `OwnerID` (`OwnerID`),  
        CONSTRAINT `Images_ibfk_1` FOREIGN KEY (`OwnerID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ''');
  }

  @override
  String get migrationID => "0002_InitializeDB";
}

/// Creates the folders support tables and migrates existing users accordingly
class MIGFolders implements Migration {
  @override
  Future<void> execute(MySQLConnection connection) async {
    await connection.execute('''
      CREATE TABLE `Folders` (  
        `ID` varchar(64) NOT NULL,  
        `ParentFolder` varchar(64) DEFAULT NULL,  
        `Name` varchar(255) NOT NULL,  
        `UserID` varchar(64) NOT NULL,  
        `Created` bigint(20) NOT NULL,  
        `Modified` bigint(20) NOT NULL,  
        `Color` varchar(24) NOT NULL DEFAULT '[0,0,0,0]',  
        `Description` text DEFAULT NULL,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `UK_Folder_Name` (`ParentFolder`,`Name`),  
        KEY `FK_Folders_User` (`UserID`),  
        CONSTRAINT `FK_Folders_Parent` FOREIGN KEY (`ParentFolder`) REFERENCES `Folders` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE,  
        CONSTRAINT `FK_Folders_User` FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE);
    ''');

    await connection.execute('''
      CREATE TABLE `FolderEntries` (  
        `ID` varchar(64) NOT NULL,  
        `FolderID` varchar(64) NOT NULL,  
        `Name` varchar(255) NOT NULL,  
        `EntryType` varchar(32) NOT NULL,  
        `TargetID` varchar(64) DEFAULT NULL,  
        `Created` bigint(20) NOT NULL,  
        `UserID` varchar(64) DEFAULT NULL,  
        PRIMARY KEY (`ID`),  
        UNIQUE KEY `UK_Entry_Name` (`FolderID`,`Name`),  
        KEY `FKUserID` (`UserID`),  
        CONSTRAINT `FKUserID` FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,  
        CONSTRAINT `FK_FolderEntries_Folder` FOREIGN KEY (`FolderID`) REFERENCES `Folders` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE);
    ''');

    final users = await connection.execute("SELECT * FROM `users`;");
    for (ResultSetRow row in users.rows) {
      final rootID = UUID.generate(4).toString();
      final rootName = "root";
      final rowAssoc = row.assoc();
      final userID = rowAssoc["ID"];
      final parentFolder = NULL_KEY;
      final creationTime = TimeUtils.getUnixTimestamp();
      final color = "[0,0,0,0]";
      final description = "";

      await connection.execute(
        '''
        INSERT INTO `Folders` (`ID`, `ParentFolder`, `Name`, `UserID`, `Created`, `Modified`, `Color`, `Description`) VALUES (:ID, :Parent, :Name, :UID, :Created, :Mod, :Color, :Desc);
      ''',
        {
          "ID": rootID,
          "Parent": parentFolder,
          "Name": rootName,
          "UID": userID,
          "Created": creationTime,
          "Mod": creationTime,
          "Color": color,
          "Desc": description,
        },
      );
    }
  }

  @override
  String get migrationID => "0003_Folders";
}

/// Add necessary data fields for proxy info to alters
class MIGProxyInfo implements Migration {
  @override
  Future<void> execute(MySQLConnection connection) async {
    await connection.execute('''
      ALTER TABLE `Alters` ADD ProxyName VARCHAR(64) NOT NULL DEFAULT '' AFTER Flags;
    ''');

    await connection.execute('''
      ALTER TABLE `Alters` ADD Proxies TEXT NULL AFTER ProxyName;
    ''');
  }

  @override
  String get migrationID => "0004_AddProxyInfoToAlters";
}

/// Handles database migrations.
class Migrator {
  /// Register migrations here, in execution order.
  static final List<Migration> _migrations = [
    MIGCreateMigrationsTable(),
    MIGInitializeDB(),
    MIGFolders(),
    MIGProxyInfo(),
  ];

  /// Executes all pending migrations.
  ///
  /// Checks which migrations have already been executed and runs any
  /// migrations that are missing from the database.
  static Future<void> performMigrations(MySQLConnection connection) async {
    // Ensure the migration tracking table exists before checking migrations.
    await _migrations.first.execute(connection);

    for (final migration in _migrations.skip(1)) {
      final alreadyRun = await _migrationAlreadyRun(
        connection,
        migration.migrationID,
      );

      if (alreadyRun) {
        continue;
      }

      print("> Executing Migration: ${migration.migrationID}");
      await migration.execute(connection);

      await connection.execute(
        '''
        INSERT INTO migrations (migration)
        VALUES (:migration)
        ''',
        {'migration': migration.migrationID},
      );
    }
  }

  /// Checks whether a migration has already been executed.
  static Future<bool> _migrationAlreadyRun(
    MySQLConnection connection,
    String migrationID,
  ) async {
    final result = await connection.execute(
      '''
      SELECT migration
      FROM migrations
      WHERE migration = :migration
      LIMIT 1
      ''',
      {'migration': migrationID},
    );

    return result.rows.isNotEmpty;
  }
}
