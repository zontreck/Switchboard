<?php

return function ($conn) {
    $conn->query("CREATE TABLE `Folders` (  `ID` varchar(64) NOT NULL,  `ParentFolder` varchar(64) DEFAULT NULL,  `Name` varchar(255) NOT NULL,  `UserID` varchar(64) NOT NULL,  `Created` bigint(20) NOT NULL,  `Modified` bigint(20) NOT NULL,  `Color` varchar(24) NOT NULL DEFAULT '[0,0,0,0]',  `Description` text DEFAULT NULL,  PRIMARY KEY (`ID`),  UNIQUE KEY `UK_Folder_Name` (`ParentFolder`,`Name`),  KEY `FK_Folders_User` (`UserID`),  CONSTRAINT `FK_Folders_Parent` FOREIGN KEY (`ParentFolder`) REFERENCES `Folders` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE,  CONSTRAINT `FK_Folders_User` FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE);");


    $conn->query("CREATE TABLE `FolderEntries` (  `ID` varchar(64) NOT NULL,  `FolderID` varchar(64) NOT NULL,  `Name` varchar(255) NOT NULL,  `EntryType` varchar(32) NOT NULL,  `TargetID` varchar(64) DEFAULT NULL,  `Created` bigint(20) NOT NULL,  `UserID` varchar(64) DEFAULT NULL,  PRIMARY KEY (`ID`),  UNIQUE KEY `UK_Entry_Name` (`FolderID`,`Name`),  KEY `FKUserID` (`UserID`),  CONSTRAINT `FKUserID` FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,  CONSTRAINT `FK_FolderEntries_Folder` FOREIGN KEY (`FolderID`) REFERENCES `Folders` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE);");

    $resUsers = $conn->query("SELECT * FROM users;");
    while($row = $resUsers->fetch_assoc()) {
        // Create the default ROOT folder for every user. 
        // Create folder
        $rootID = gen_uuid();
        $rootName = "root";
        $usr = $row['ID'];
        $parentFolder = null_uuid();
        $targetFolder = null_uuid();
        $link = FALSE;
        $creationTime = time();
        $color = "[0,0,0,0]";
        $description = "";

        $stmt = $conn->prepare("INSERT INTO `Folders` (`ID`, `ParentFolder`, `Name`, `UserID`, `Created`, `Modified`, `Color`, `Description`) VALUES (?, ?, ?, ?, ?, ?, ?, ?);");
        $stmt->bind_param("ssssii", $rootID, $null, $rootName, $usr, $creationTime, $creationTime, $color, $description);
        $stmt->execute();
        $conn->commit();
    }

    // Folders support is now enabled on the database, and all existing users have been updated!
}

?>