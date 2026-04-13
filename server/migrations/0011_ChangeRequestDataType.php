<?php

return function($conn) {
    $conn->query("ALTER TABLE `Audit` CHANGE `RequestData` `RequestData` TEXT NULL DEFAULT NULL;");
}

?>