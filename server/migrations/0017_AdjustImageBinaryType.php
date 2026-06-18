<?php

return function($conn) {
    $conn->query("ALTER TABLE `Avatars` CHANGE `ImageBinary` `ImageBinary` LONGBLOB NOT NULL;");
    $conn->query("ALTER TABLE `Images` CHANGE `ImageBinary` `ImageBinary` LONGBLOB NOT NULL;");
}

?>