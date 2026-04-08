<?php

return function($conn) {
    $conn->query("ALTER TABLE `Audit` ADD INDEX(`Timestamp`);");
}

?>