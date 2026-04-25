<?php

return function($conn) {
    $conn->QUERY("ALTER TABLE `Alters` DROP PRIMARY KEY;");
    $conn->query("ALTER TABLE `Alters` ADD PRIMARY KEY (`ID`);");
}

?>