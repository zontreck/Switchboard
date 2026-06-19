<?php

return function($conn) {
    $defFields = array(
        array(
            "Name" => "Pronouns",
            "Type" => -3,
            "Order" => 9999
        ),
    ); 

    $res = $conn->query("SELECT * FROM users;");
    while($row = $res->fetch_assoc()) {
        foreach($defFields as $k) {

            $fieldID = gen_uuid();
            $dfStmt = $conn->prepare("INSERT INTO Fields (User, ID, FieldName, FieldType, SortOrder) VALUES (?, ?,?,?, ?);");
            $dfStmt->bind_param("sssi", $row['ID'], $fieldID, $k["Name"], $k['Type'], $k['Order']);
            $dfStmt->execute();
            $dfStmt->close();

            $conn->commit();
        }
    }

    $conn->commit();
}