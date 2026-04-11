<?php

return function ($conn) {
    $conn->query("ALTER TABLE `AccessTokens` DROP PRIMARY KEY;");
    $conn->query("ALTER TABLE `AccessTokens` ADD PRIMARY KEY(`Token`);");
}

?>