<?php


return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS Fields (User VARCHAR (64) NOT NULL, ID VARCHAR(64) UNIQUE NOT NULL, FieldName VARCHAR(255) NOT NULL, FieldType int NOT NULL DEFAULT 1);");
    $conn->query("ALTER TABLE `Fields` ADD PRIMARY KEY(`ID`);");
    $conn->query("ALTER TABLE `Fields` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
    $conn->query("ALTER TABLE `Fields` ADD INDEX(`User`);");
    $conn->query("ALTER TABLE `Alters` ADD `Fields` BLOB NULL AFTER `Avatar`;");

    // Add default system fields to every user.
    $defFields = array(
        array(
            "Name" => "Description",
            "Type" => -1
        ),
        array(
            "Name" => "Color",
            "Type" => -2
        )
    ); 
    // As default fields change, migrations will be performed. For every new user account, at the time of creation it will read the list of default fields at that point in time.

    $res = $conn->query("SELECT * FROM users;");
    while($row = $res->fetch_assoc()) {
        foreach($defFields as $k) {

            $fieldID = gen_uuid();
            $dfStmt = $conn->prepare("INSERT INTO Fields (User, ID, FieldName, FieldType) VALUES (?, ?,?,?);");
            $dfStmt->bind_param("sssi", $row['ID'], $fieldID, $k["Name"], $k['Type']);
            $dfStmt->execute();
            $dfStmt->close();

            $conn->commit();
        }
    }

    $conn->commit();
}

?>