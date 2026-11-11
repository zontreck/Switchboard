<?php

function MakePasswordSalt() {
    return md5(time().":".md5(rand(0,255)));
}


function MakePasswordHash($pwd, $salt) {
    return md5($pwd.":".$salt);
}



function MakeSAT($Token, $Expire, $ISS) {
    return base64_encode(json_encode(array(
        "token" => $Token,
        "expires" => $Expire,
        "iss" => $ISS,
        "valid_for" => (60*60*24) // one day
    )));
}

class SATReply {
    public bool $Success;
    public int $Scope;
    public int $Flags;
    public string $UserID;
    public string $Token;

    public function __construct(bool $Success, int $Scope, int $Flags, string $UserID, string $Token) {
        $this->Success = $Success;
        $this->Scope = $Scope;
        $this->Flags = $Flags;
        $this->UserID = $UserID;
        $this->Token = $Token;
    }
}

function ValidateSAT($SAT) {
    global $impersonate, $impUser;
    if($impersonate) {
        return $impUser;
    }
    $payload = base64_decode($SAT);
    $jsonPayload = json_decode($payload, true);

    // Query the database to ensure SAT validity.
    $DB = get_DB("switchboard");

    $res = $DB->query("SELECT * FROM Access WHERE Token='".$jsonPayload['token']."';");

    if($res->num_rows == 0) {
        return new SATReply(false, 0, 0, "N/A/$payload", "No Such Token");
    }
    $row = $res->fetch_assoc();
    
    // Check the expiration now.
    $expire = $jsonPayload['expires'];
    $Scope = $row['TokenScope'];
    $Flags = $row['TokenFlags'];
    if(time() >= $expire && $row['Expire'] == $expire) {
        $DB->query("DELETE FROM Access WHERE Token='".$jsonPayload['token']."';");
        return new SATReply(false, 0, 0, "nan", "invalid");
    } else {
        return new SATReply(true, $Scope, $Flags, $row['User'], $row['Token']);
    }
}

function get_Authorization()
{
    $headers = apache_request_headers();
    foreach ($headers as $header => $value) {
        if(strtolower($header) == "x-sb-auth") {
            return $value;
        }
    }
    
    return "XX";
}


?>