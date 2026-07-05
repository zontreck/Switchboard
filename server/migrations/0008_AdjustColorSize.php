<?php

return function($conn) {
    $conn->query("ALTER TABLE `Folders` CHANGE `Color` `Color` VARCHAR(24) NOT NULL DEFAULT '[0,0,0,0]';");
}

?>