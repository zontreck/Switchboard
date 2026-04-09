<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `AccessTokens` (User VARCHAR(64), Token VARCHAR(64) UNIQUE, TokenScope int NOT NULL DEFAULT 0, TokenFlags int NOT NULL DEFAULT 0);");

    $conn->query("ALTER TABLE `AccessTokens` ADD PRIMARY KEY(`User`);");
}

?>