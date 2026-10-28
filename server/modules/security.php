<?php

function MakePasswordSalt() {
    return md5(time().":".md5(rand(0,255)));
}


function MakePasswordHash($pwd, $salt) {
    return md5($pwd.":".$salt);
}

?>