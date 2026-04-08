<?php

return function($conn) {
    // This migration will require generating new user IDs for all users in the database after adding the table.
    
    $conn->query("ALTER TABLE `users` ADD `ID` VARCHAR(64) AFTER `DisplayName`;");

    $res = $conn->query("SELECT * FROM users;");
    while($row = $res->fetch_assoc()) {
        $conn->query("UPDATE users SET ID='".gen_uuid()."' WHERE UserName='".$row['UserName']."';");
    }
}

?>