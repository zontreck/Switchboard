<?php

return function($conn) {
    $conn->query("ALTER TABLE `Audit` DROP `Timestamp`;");
    $conn->query("ALTER TABLE `Audit` ADD `Timestamp` INT NOT NULL AFTER `RequestData`;");
}

?>