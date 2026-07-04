<?php

return function($conn){
    $conn->query("ALTER TABLE `Folders` ADD `Color` VARCHAR(16) NOT NULL AFTER `Modified`;");
    $conn->query("ALTER TABLE `Folders` ADD `Description` TEXT NULL AFTER `Color`;");
}

?>