<?php


return function($conn) {
    $conn->query("ALTER TABLE `Access` ADD Expire int not null default 0 AFTER TokenFlags;");
    $conn->query("ALTER TABLE `Access` ADD IssuedAt int not null default 0 AFTER Expire;");
}

?>