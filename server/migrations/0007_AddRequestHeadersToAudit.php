<?php


return function($conn) {
    $conn->query("ALTER TABLE `Audit` ADD RequestHeaders VARCHAR(255) NOT NULL DEFAULT '' AFTER RequestData;");

}

?>