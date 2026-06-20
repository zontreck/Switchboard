<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Feedback` (User VARCHAR (64) NOT NULL, ID VARCHAR(64) NOT NULL, Name VARCHAR(255) NOT NULL, Type INT(11) NOT NULL);");

    $conn->query("ALTER TABLE `Feedback` ADD PRIMARY KEY(`ID`);");
    $conn->query("ALTER TABLE `Feedback` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>