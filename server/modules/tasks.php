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

function sanityCheckUserFields($userid) {
    // This function will check if default fields exist, then create them if not.
    foreach ($DEFAULT_USER_FIELDS as $value) {
        // Create the default fields for the specified user.
        if(fieldExists($userid, $value["Type"])) {
            continue;
        }

        $fieldID = gen_uuid();
        $dfStmt = $DB->prepare("INSERT INTO `Fields` (`User`, `ID`, `FieldName`, `FieldType`, `SortOrder`) VALUES (?,?,?,?, ?);");
        $dfStmt->bind_param("sssii", $userid, $fieldID, $value["Name"], $value["Type"], $value["Order"]);
        $dfStmt->execute();
        $dfStmt->close();
        $DB->commit();
    }
}

function getFieldIDForUser($userID, $fieldType) {
    $stmt = $DB->prepare("SELECT * FROM `Fields` WHERE `User` = ? AND `FieldType` = ?;");
    $stmt->bind_param("si", $userID, $fieldType);
    $stmt->execute();
    $res = $stmt->get_result();
    if($res->num_rows == 0) {
        return null_uuid();
    }

    $row = $res->fetch_assoc();
    return $row['ID'];
}

function fieldExists($userID, $type) {
    return getFieldIDForUser($userID, $type) != null_uuid();
}

?>