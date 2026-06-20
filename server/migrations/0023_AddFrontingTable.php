<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS `Fronting` (`ID` VARCHAR(64) NOT NULL, `User` VARCHAR(64) NOT NULL, `AlterID` VARCHAR(64) NOT NULL, `StartTime` INT(11) NOT NULL DEFAULT 0, `EndTime` INT(11) NOT NULL DEFAULT 0);");


    $conn->query("ALTER TABLE `Fronting` ADD PRIMARY KEY (`ID`);");
    $conn->query("ALTER TABLE `Fronting` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
    $conn->query("ALTER TABLE `Fronting` ADD FOREIGN KEY (`AlterID`) REFERENCES `Alters`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>