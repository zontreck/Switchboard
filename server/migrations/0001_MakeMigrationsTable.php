<?php

return function($conn) {
    $conn->query("CREATE TABLE IF NOT EXISTS migrations(migration VARCHAR (255) UNIQUE);");
}

?>