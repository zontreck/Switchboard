<?php


function invalid_endpoint(ServerReply $rep) {
    $rep->Reason = "Invalid Endpoint";

    return $rep->encode();
}

?>