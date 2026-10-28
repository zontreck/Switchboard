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


function getUsernameFromID($DB, $userID) {
    $ustmt = $DB->prepare("SELECT * FROM `users` WHERE `ID` = ?;");
    $ustmt->bind_param("s", $userID);
    $ustmt->execute();
    $res = $ustmt->get_result();
    $row = $res->fetch_assoc();
    $username = $row['UserName'];
    $ustmt->close();

    return $username;
}

function userIDExists($DB, $ID) {
    $stmt = $DB->prepare("SELECT * FROM `users` WHERE `ID`=?;");
    $stmt->bind_param("s", $ID);
    $stmt->execute();

    $res = $stmt->get_result();
    if($res->num_rows > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

function userNameExists($DB, $username) {
    $stmt = $DB->prepare("SELECT * FROM `users` WHERE `UserName`=?;");
    $stmt->bind_param("s", $username);
    $stmt->execute();

    $res = $stmt->get_result();
    if($res->num_rows > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}


function insertNewUser($DB, $username, $salt, $hash, $userID) {

    $stmt = $DB->prepare("INSERT INTO users (UserName, PasswordSalt, PasswordHash, DisplayName, ID) VALUES (?,?,?,?, ?);");

    $stmt->bind_param("sssss", $username, $salt, $hash, $username, $userID);
    $stmt->execute();
    $stmt->close();

    $DB->commit();
}

?>