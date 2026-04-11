<?php

return function($conn) {
    $conn->query("ALTER TABLE `Access` ADD CONSTRAINT `UID` FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}


?>