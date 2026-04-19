<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Avatars` (User VARCHAR(64), AlterId VARCHAR(64) UNIQUE NOT NULL, ImageType VARCHAR(255) NOT NULL DEFAULT 'image/webp', ImageBinary BLOB NOT NULL, Timestamp INT NOT NULL);");

    $conn->query("ALTER TABLE `Avatars` ADD PRIMARY KEY (`User`);");
    $conn->query("ALTER TABLE `Avatars` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>