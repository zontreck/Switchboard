<?php

return function($conn) {
    $conn->query("ALTER TABLE `users` CHANGE `ID` `ID` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL;");
    
    $conn->query("ALTER TABLE `Access` ADD CONSTRAINT `UID` FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}


?>