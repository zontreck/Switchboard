<?php

return function ($conn) {
    $conn->query("ALTER TABLE `Audit` CHANGE `RequestHeaders` `RequestHeaders` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL;");
}

?>