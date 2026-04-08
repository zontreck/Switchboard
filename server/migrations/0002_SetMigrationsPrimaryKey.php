<?php

return function($conn) {

    $conn->query("ALTER TABLE `migrations` ADD PRIMARY KEY(`migration`);");
}

?>