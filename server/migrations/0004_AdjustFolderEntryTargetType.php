<?php

return function($conn) {
    $conn->query("ALTER TABLE `FolderEntries` CHANGE `TargetID` `TargetID` VARCHAR(64) NULL;");
}

?>