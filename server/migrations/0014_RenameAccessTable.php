<?php

return function($conn){
    $conn->query("RENAME TABLE `AccessTokens` TO `Access`;");
}

?>