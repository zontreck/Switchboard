<?php

return function ($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS users(UserName VARCHAR (64) UNIQUE, PasswordSalt VARCHAR (255), PasswordHash VARCHAR(255), DisplayName VARCHAR(255), ID VARCHAR(64) NOT NULL, AccountLevel INT NOT NULL DEFAULT 1);");
    
    $conn->query("ALTER TABLE `users` ADD PRIMARY KEY(`UserName`);");
}


?>