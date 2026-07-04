<?php

return function($conn) {
    try {
        $conn->query("ALTER TABLE `Folders` DROP FOREIGN KEY `FK_Folders_Parent`;");
    }catch(Exception $E) {}

    $conn->query("ALTER TABLE `Folders` ADD CONSTRAINT `FK_Folders_Parent` FOREIGN KEY (`ParentFolder`) REFERENCES `Folders`(`ID`) ON DELETE SET NULL ON UPDATE CASCADE;")
}

?>