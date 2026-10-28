<?php


function logAudit($ID, $Type, $Path, $DBHandle) {
    $payload = file_get_contents("php://input");

    $STMT = $DBHandle->prepare("INSERT INTO Audit (ID, RequestType, RequestPath, RequestData, Timestamp, RequestHeaders) VALUES (?, ?, ?, ?, ?, ?);");
    $STMT->bind_param("ssssis", $ID, $Type, $Path, $payload, time(), json_encode(apache_request_headers()));
    try {
        $STMT->execute();

    }catch(Exception $E) {
        $payload="payload too long to cache";
        $STMT->execute();
    }
    $STMT->close();
    $DBHandle->commit();
}

?>