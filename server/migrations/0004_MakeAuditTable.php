<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS Audit(ID VARCHAR(64) unique, IP VARCHAR(32), RequestType VARCHAR(12), RequestPath VARCHAR(255), RequestData VARCHAR(255));");
    $conn->query("ALTER TABLE `Audit` ADD PRIMARY KEY(`id`);");
}

?>