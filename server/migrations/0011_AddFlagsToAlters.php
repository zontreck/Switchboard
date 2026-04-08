<?php

return function($conn) {
    $conn->query("ALTER TABLE `Alters` ADD Flags int NOT NULL DEFAULT 0 AFTER `ParentID`;");
}

?>