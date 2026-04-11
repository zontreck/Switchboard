<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS Audit(ID VARCHAR(64) unique, RequestType VARCHAR(12), RequestPath VARCHAR(255), RequestData VARCHAR(255), Timestamp INT NOT NULL);");
    $conn->query("ALTER TABLE `Audit` ADD PRIMARY KEY(`id`);");
    $conn->query("ALTER TABLE `Audit` ADD INDEX(`Timestamp`);");
}

?>