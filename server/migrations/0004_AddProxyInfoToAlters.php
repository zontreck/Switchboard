<?php

return function($conn) {
    $conn->query("ALTER TABLE `Alters` ADD ProxyName VARCHAR(64) NOT NULL DEFAULT '' AFTER Flags;");
    $conn->query("ALTER TABLE `Alters` ADD Proxies TEXT NULL AFTER ProxyName;");
}

?>