<?php


return function($conn) {
    $conn->query("ALTER TABLE `Avatars` DROP PRIMARY KEY, DROP INDEX `AlterId`, ADD PRIMARY KEY (`AlterId`);");
    $conn->query("ALTER TABLE `Images` DROP PRIMARY KEY, DROP INDEX `ImageID`, ADD PRIMARY KEY (`ImageID`);");
}

?>