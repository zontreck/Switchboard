<?php

return function ($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS users(UserName VARCHAR (64) UNIQUE, PasswordSalt VARCHAR (255), PasswordHash VARCHAR(255), DisplayName VARCHAR(255));");
}


?>