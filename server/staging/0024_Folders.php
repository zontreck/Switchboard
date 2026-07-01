<?php

return function ($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Folders` (  `ID` varchar(64) NOT NULL,  `Name` varchar(255) NOT NULL,  `User` varchar(64) NOT NULL, `ParentFolder` VARCHAR(64) NOT NULL, `Created` bigint(20) NOT NULL,  `Modified` bigint(20) NOT NULL,  PRIMARY KEY (`ID`),  UNIQUE KEY `ID` (`ID`),  KEY `User` (`User`),  CONSTRAINT `Folders_ibfk_1` FOREIGN KEY (`User`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE));");

    $conn->query("CREATE TABLE `FolderEntries` (  `ID` varchar(64) NOT NULL,  `ParentFolder` varchar(64) NOT NULL,  `TargetFolder` varchar(64) DEFAULT NULL,  `IsLink` tinyint(1) NOT NULL DEFAULT 0,  PRIMARY KEY (`ID`),  KEY `ParentFolder` (`ParentFolder`),  KEY `FolderEntries_ibfk_3` (`TargetFolder`),  CONSTRAINT `FolderEntries_ibfk_1` FOREIGN KEY (`ID`) REFERENCES `Folders` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,  CONSTRAINT `FolderEntries_ibfk_2` FOREIGN KEY (`ParentFolder`) REFERENCES `Folders` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,  CONSTRAINT `FolderEntries_ibfk_3` FOREIGN KEY (`TargetFolder`) REFERENCES `Folders` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE); ");

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

        $stmt = $conn->prepare("INSERT INTO `Folders` (`ID`, `Name`, `User`, `Created`, `Modified`) VALUES (?,?,?,?,?);");
        $stmt->bind_param("sssii", $rootID, $rootName, $usr, $creationTime, $creationTime);
        $stmt->execute();
        $conn->commit();

        $stmt = $conn->prepare("INSERT INTO `FolderEntries` (`ID`, `ParentFolder`, `TargetFolder`, `IsLink`) VALUES (?, ?, ?, ?);");
        $stmt->bind_param("sssi", $rootID, $parentFolder, $targetFolder, $link);
        $stmt->execute();
        $conn->commit();
    }
}

?>