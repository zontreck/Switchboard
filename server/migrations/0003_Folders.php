<?php

return function ($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS Folders (    ID            VARCHAR(64) PRIMARY KEY,    ParentFolder    VARCHAR(64) NULL,    Name            VARCHAR(255) NOT NULL,    UserID          VARCHAR(64) NOT NULL, Created         BIGINT NOT NULL,    Modified        BIGINT NOT NULL,    CONSTRAINT FK_Folders_Parent        FOREIGN KEY (ParentFolder)        REFERENCES Folders(ID),    CONSTRAINT FK_Folders_User        FOREIGN KEY (UserID)        REFERENCES users(ID)        ON DELETE CASCADE        ON UPDATE CASCADE,    UNIQUE KEY UK_Folder_Name (ParentFolder, Name));");


    $conn->query("CREATE TABLE IF NOT EXISTS FolderEntries (    ID            VARCHAR(64) PRIMARY KEY,    FolderID      VARCHAR(64) NOT NULL,    Name            VARCHAR(255) NOT NULL,    EntryType       VARCHAR(32) NOT NULL,    TargetID      VARCHAR(64) NOT NULL,    Created         BIGINT NOT NULL,    CONSTRAINT FK_FolderEntries_Folder        FOREIGN KEY (FolderID)        REFERENCES Folders(ID)        ON DELETE CASCADE        ON UPDATE CASCADE,    UNIQUE KEY UK_Entry_Name (FolderID, Name));");

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

        $stmt = $conn->prepare("INSERT INTO `Folders` (`ID`, `ParentFolder`, `Name`, `UserID`, `Created`, `Modified`) VALUES (?, ?, ?, ?, ?, ?);");
        $stmt->bind_param("ssssii", $rootID, $null, $rootName, $usr, $creationTime, $creationTime );
        $stmt->execute();
        $conn->commit();
    }

    // Folders support is now enabled on the database, and all existing users have been updated!
}

?>