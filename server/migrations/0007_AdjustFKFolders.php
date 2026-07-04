<?php

return function($conn) {
    $conn->query("ALTER TABLE `Folders` DROP FOREIGN KEY `FK_Folders_Parent`; ALTER TABLE `Folders` ADD CONSTRAINT `FK_Folders_Parent` FOREIGN KEY (`ParentFolder`) REFERENCES `Folders`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>