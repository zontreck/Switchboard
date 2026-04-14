<?php

return function($conn) {
    $conn->query("ALTER TABLE `Images` ADD CONSTRAINT `UID` FOREIGN KEY (`OwnerID`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>