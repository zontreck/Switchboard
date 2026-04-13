<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Images` (OwnerID VARCHAR(64), ImageID VARCHAR(64) UNIQUE NOT NULL, ImageType VARCHAR(255) NOT NULL DEFAULT 'image/webp', ImageBinary BLOB NOT NULL, Timestamp INT NOT NULL);");

    $conn->query("ALTER TABLE `Images` ADD PRIMARY KEY ('OwnerID');");
}

?>