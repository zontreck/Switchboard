<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS migrations(migration VARCHAR (255) UNIQUE);");

    $conn->query("ALTER TABLE `migrations` ADD PRIMARY KEY(`migration`);");
}

?>