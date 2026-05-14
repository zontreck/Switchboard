<?php

return function($conn) {
    $conn->query("ALTER TABLE `Fields` ADD `SortOrder` INT NOT NULL DEFAULT 0 AFTER `FieldType`;");
}

?>