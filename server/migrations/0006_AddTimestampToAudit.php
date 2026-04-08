<?php

return function($conn) {
    $conn->query("ALTER TABLE `Audit` ADD `Timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `RequestData`;");
}

?>