<?php

return function ($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS Alters (User VARCHAR(64) UNIQUE, ID VARCHAR(64) UNIQUE, Name VARCHAR(255), Avatar VARCHAR(64), SubID int, ParentID VARCHAR(64));");
    // User, ID, Name, Avatar, SubID, ParentID

    $conn->query("ALTER TABLE `Alters` ADD PRIMARY KEY(`User`);");
}

?>