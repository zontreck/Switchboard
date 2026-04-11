<?php

return function ($conn) {
    $conn->query("ALTER TABLE `Access` DROP PRIMARY KEY;");
    $conn->query("ALTER TABLE `Access` ADD PRIMARY KEY(`Token`);");
}

?>