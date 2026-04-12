<?php

return function($conn) {
    $conn->query("ALTER TABLE `Alters` ADD FOREIGN KEY (`User`) REFERENCES `users`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;");
}

?>