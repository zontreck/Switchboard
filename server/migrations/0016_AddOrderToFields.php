<?php

return function($conn) {
    $conn->query("ALTER TABLE `Fields` ADD Order INT NOT NULL DEFAULT 0 AFTER `FieldType`;");
}

?>