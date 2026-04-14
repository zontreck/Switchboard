<?php

return function($conn) {
    $conn->query("ALTER TABLE `Images` ADD FOREIGN KEY (`OwnerID`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>