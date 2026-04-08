<?php

return function($conn) {
    $conn->query("ALTER TABLE `users` ADD AccountLevel int NOT NULL DEFAULT 1 AFTER ID;");
}

?>