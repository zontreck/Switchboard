<?php

return function($conn) {
    $conn->query("ALTER TABLE `Feedback` ADD `Status` INT (11) NOT NULL DEFAULT 0 AFTER Type;");
    $conn->query("ALTER TABLE `Feedback` ADD `RootMessage` VARCHAR(64) DEFAULT NULL AFTER `Status`;");
    $conn->query("ALTER TABLE `Feedback` ADD `LastMessage` VARCHAR(64) DEFAULT NULL AFTER `RootMessage`;");
    $conn->query("ALTER TABLE `Feedback` ADD `Created` INT(11) NOT NULL AFTER `LastMessage`;");
    $conn->query("ALTER TABLE `Feedback` ADD `Updated` INT(11) NOT NULL AFTER `Created`;");


    $conn->query("CREATE TABLE IF NOT EXISTS `FeedbackMessages` (ID VARCHAR(64) NOT NULL, Feedback VARCHAR(64) NOT NULL, User VARCHAR(64) NOT NULL, Message TEXT NOT NULL, Created INT(11) NOT NULL, Primary KEY (`ID`));");

    $conn->query("ALTER TABLE `FeedbackMessages` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
    $conn->query("ALTER TABLE `FeedbackMessages` ADD FOREIGN KEY (`Feedback`) REFERENCES `Feedback`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
    $conn->query("ALTER TABLE `Feedback` ADD FOREIGN KEY (`RootMessage`) REFERENCES `FeedbackMessages`(`ID`) ON DELETE SET NULL ON UPDATE CASCADE;");
    $conn->query("ALTER TABLE `Feedback` ADD FOREIGN KEY (`LastMessage`) REFERENCES `FeedbackMessages`(`ID`) ON DELETE SET NULL ON UPDATE CASCADE;");
}

?>