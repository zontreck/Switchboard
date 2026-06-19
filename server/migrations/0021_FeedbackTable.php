<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Feedback` (User VARCHAR (64), ID VARCHAR(64), Name VARCHAR(255), Type INT(11));");

    $conn->query("ALTER TABLE `Feedback` ADD PRIMARY KEY(`ID`);");
    $conn->query("ALTER TABLE `Feedback` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>