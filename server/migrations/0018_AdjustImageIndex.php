<?php

return function($conn) {
    $conn->query("ALTER TABLE `switchboard`.`Avatars` DROP INDEX `AlterId`, ADD UNIQUE `AlterId` (`AlterId`, `User`) USING BTREE;");
    $conn->query("ALTER TABLE `switchboard`.`Images` DROP INDEX `ImageID`, ADD UNIQUE `ImageID` (`ImageID`, `OwnerID`) USING BTREE;");
}

?>