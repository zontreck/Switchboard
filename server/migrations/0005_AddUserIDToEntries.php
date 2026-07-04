<?php

return function($conn){
    $conn->query("ALTER TABLE `FolderEntries` ADD `UserID` VARCHAR(64) AFTER `Modified`;");
    $conn->query("ALTER TABLE `FolderEntries` ADD CONSTRAINT FKUserID FOREIGN KEY (UserID) REFERENCES `users` (ID);");
}

?>