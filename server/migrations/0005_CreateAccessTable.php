<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Access` (User VARCHAR(64), Token VARCHAR(64) UNIQUE, TokenScope int NOT NULL DEFAULT 0, TokenFlags int NOT NULL DEFAULT 0, Expire INT NOT NULL DEFAULT 0, IssuedAt INT NOT NULL DEFAULT 0);");

    $conn->query("ALTER TABLE `Access` ADD PRIMARY KEY(`Token`);");
}

?>