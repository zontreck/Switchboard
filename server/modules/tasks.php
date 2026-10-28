<?php


function pruneAudit() {

    $DB = get_DB("switchboard");
    // First, figure out the exact time for prune.
    $now = time();
    $oneDay = (60*60*24);
    $yesterday = time()-$oneDay;
    $pruneStmt = $DB->prepare("DELETE FROM `Audit` WHERE Timestamp < ?;");
    $pruneStmt->bind_param("i", $yesterday);
    $pruneStmt->execute();
    $pruneResult = $pruneStmt->get_result();
    $rows=$pruneResult->num_rows;

    $pruneStmt->close();
    $DB->commit();
    return $rows;
}

function prune_accessTokens() {

    $pruneStmt = $DB->prepare("DELETE FROM `Access` WHERE Expire < ?;");
    $pruneStmt->bind_param("i", $now);
    $pruneStmt->execute();
    $pruneResult = $pruneStmt->get_result();
    $rows = $pruneResult->num_rows;

    $pruneStmt->close();
    $DB->commit();
    $DB->close();

    return $rows;
}



function executeCronJobs() {
    $audit = pruneAudit();
    $accessTokens = prune_accessTokens();


    return array(
        "audit" => $audit,
        "access" => $accessTokens
    );
}

?>