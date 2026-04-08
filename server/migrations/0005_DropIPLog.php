<?php


return function ($conn) {
    $conn->query("ALTER TABLE `Audit` DROP `IP`;");
}

?>