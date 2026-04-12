<?php

$DEBUG = true;

$VERSION = "0.1.041126+2121";

require_once("dbconfig.php");

if(defined("MAINTENANCE")) {
    header("Content-Type: application/json");
    die(json_encode(array(
        "result" => "fail",
        "maintenance" => true,
        "reason" => "The server is in maintenance mode. Try again later."
    )));
}

$route = $_GET['rt'] ?? '';
$request = $_SERVER['REQUEST_METHOD'];
$ID = gen_uuid(); // Session ID, can be used for tracing back errors

header("Content-Type: application/json", true);
header("Server: Switchboard/v".$VERSION, true);

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
    $payload = base64_decode($SAT);
    $jsonPayload = json_decode($payload, true);

    // Query the database to ensure SAT validity.
    $DB = get_DB("switchboard");

    $res = $DB->query("SELECT * FROM Access WHERE Token='".$jsonPayload['token']."';");

    if($res->num_rows == 0) {
        return new SATReply(false, 0, 0, "", "");
    }
    $row = $res->fetch_assoc();
    
    // Check the expiration now.
    $expire = $jsonPayload['expires'];
    $Scope = $row['TokenScope'];
    $Flags = $row['TokenFlags'];
    if(time() >= $expire) {
        $DB->query("DELETE FROM Access WHERE Token='".$jsonPayload['token']."';");
        return new SATReply(false, 0, 0, "", "");
    } else {
        return new SATReply(true, $Scope, $Flags, $row['User'], $row['Token']);
    }
}

function get_Authorization()
{
    $headers = apache_request_headers();
    if(isset($headers["X-SB-Auth"])) 
        return $headers["X-SB-Auth"];
    else return "XX";
}

function get_DB($dbname)
{
    global $HOST, $DBUSER, $DBPASS;

    $DB_Handle = new mysqli($HOST, $DBUSER, $DBPASS, $dbname);


    return $DB_Handle;
}


function gen_uuid()
{
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        // 32 bits for "time_low"
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),

        // 16 bits for "time_mid"
        mt_rand(0, 0xffff),

        // 16 bits for "time_hi_and_version",
        // four most significant bits holds version number 4
        mt_rand(0, 0x0fff) | 0x4000,

        // 16 bits, 8 bits for "clk_seq_hi_res",
        // 8 bits for "clk_seq_low",
        // two most significant bits holds zero and one for variant DCE1.1
        mt_rand(0, 0x3fff) | 0x8000,

        // 48 bits for "node"
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff)
    );
}

// SANITY CHECK
$db0 = get_DB("switchboard");

function runMigrations(mysqli $conn, string $dir = __DIR__ . '/migrations'): void
{
    if (!is_dir($dir)) {
        throw new Exception("Migration directory not found: $dir");
    }

    // Get migration files
    $files = array_filter(scandir($dir), function ($file) {
        return pathinfo($file, PATHINFO_EXTENSION) === 'php';
    });

    sort($files);

    // Check if migrations table exists
    $migrationsTableExists = false;
    $result = $conn->query("SHOW TABLES LIKE 'migrations'");
    if ($result && $result->num_rows > 0) {
        $migrationsTableExists = true;
    }

    // Load applied migrations
    $applied = [];

    if ($migrationsTableExists) {
        $result = $conn->query("SELECT migration FROM migrations");
        while ($row = $result->fetch_assoc()) {
            $applied[$row['migration']] = true;
        }
    }

    foreach ($files as $file) {
        $name = pathinfo($file, PATHINFO_FILENAME);
        $path = $dir . '/' . $file;


        // Skip if already applied
        if (isset($applied[$name])) {
            //echo "Skipping already applied migration: $name\n";
            continue;
        }

        // Bootstrap migrations table if needed
        if (!$migrationsTableExists) {
            //echo "Bootstrapping migrations table using: $file\n";

            $migration = require $path;

            if (is_callable($migration)) {
                $migration($conn);
            }

            $migrationsTableExists = true;

            // Mark this migration as applied
            $stmt = $conn->prepare("INSERT INTO migrations (migration) VALUES (?)");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $stmt->close();

            //echo "Migrations table created.\n";
            continue;
        }

        // Skip already applied
        if (isset($applied[$name])) {
            continue;
        }

        //echo "Applying migration: $name\n";

        try {
            $conn->begin_transaction();

            $migration = require $path;

            if (is_callable($migration)) {
                $migration($conn);
            }

            // Record migration
            $stmt = $conn->prepare("INSERT INTO migrations (migration) VALUES (?)");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $stmt->close();

            $conn->commit();

            //echo "Applied: $name\n";

        } catch (Throwable $e) {
            $conn->rollback();
            //echo "Failed: $name\n";
            throw $e;
        }
    }

    //echo "All migrations complete.\n";
}

function logAudit($ID, $Type, $Path, $DBHandle) {
    $payload = file_get_contents("php://input");

    $STMT = $DBHandle->prepare("INSERT INTO Audit (ID, RequestType, RequestPath, RequestData, Timestamp, RequestHeaders) VALUES (?, ?, ?, ?, ?, ?);");
    $STMT->bind_param("ssssis", $ID, $Type, $Path, $payload, time(), json_encode(apache_request_headers()));
    $STMT->execute();
    $STMT->close();
    $DBHandle->commit();
}

runMigrations($db0);

logAudit($ID, $request, $route, $db0);

$db0->close();


switch($route) {
    case "/": {
        die(json_encode(array(
            "result"=> "FAIL",
            "type"=> $request,
            "path"=> $route,
            "id"=> $ID
        )));
        break;
    }
    
    // Handle /user or /user/{username}
    case preg_match('#^/user(?:/([^/]+))?$#', $route, $matches) === 1: {
        $DB = get_DB("switchboard");
        $packet = json_decode(file_get_contents("php://input"), true);

        $username = $matches[1] ?? null; // null if /user was requested without a username
        
        $reason = "";
        if($username == null) {
            $success=  false;
        }
        $success=false;
        $data = null;

        switch($request) {
            case "PUT": {
                if($username) {
                    // Check for an existing user.
                    $R = $DB->query("SELECT * FROM users where UserName='".$username."';");
                    if($R->num_rows != 0) {
                        $success=false;
                        $reason = "User exists";
                        break;
                    }
                    // Update user info
                    $HashedPwd = $packet['auth'];
                    if(isset($packet['authRaw']) && $DEBUG) {
                        $HashedPwd = md5($packet['authRaw']); // For security reasons, this is disabled when debug is turned off.
                        // We must enforce security in a production environment.
                    }
                    $Salt = md5(md5(time()).":".time().md5($HashedPwd));
                    $Hash = md5($HashedPwd.":".$Salt);

                    $stmt = $DB->prepare("INSERT INTO users (UserName, PasswordSalt, PasswordHash, DisplayName, ID) VALUES (?,?,?,?, ?);");

                    $stmt->bind_param("sssss", $username, $Salt, $Hash, $username, gen_uuid());
                    $stmt->execute();
                    $stmt->close();

                    $DB->commit();

                    $success=true;
                    $reason="User created";

                    $data = array(
                        "user" => $username,
                        "displayName" => $username,
                        "alter_count" => 0,
                        "level" => 1
                    );
                } else {
                    // Handle error: username missing
                    $success=false;
                    $reason = "Username required";
                }
                break;
            }

            case "GET": {
                if($username) {
                    // Fetch user info
                    $resp = $DB->query("SELECT * FROM users WHERE UserName='".$username."';");

                    if($resp->num_rows == 0) {
                        $success = false;
                        $reason = "No such user";
                        break;
                    }
                    $row = $resp->fetch_assoc();
                    $alters = $DB->query("SELECT * FROM Alters WHERE User='".$row['ID']."';");

                    $alterCount=0;
                    while($aRow = $alters->fetch_assoc()) {
                        if(($aRow['Flags'] & 1) == 1) { // 1 - Allow Tracking, Alter is tracked as part of the profile's alter count
                            $alterCount++;
                        }
                    }

                    $success=true;

                    if($row['AccountLevel'] == 0) {
                        $success = false;
                        $reason = "User is banned";
                    }

                    if($row['AccountLevel'] == 99) { // User is server administrator.
                        $reason = "ADMINISTRATOR";
                    }

                    if($row['AccountLevel'] == 100) {
                        // User is administrator and has set their profile to private
                        $reason = "ADMINISTRATOR";
                        $success=false;
                        $alterCount=0;
                        $data = array(
                            "user" => $row['UserName'],
                            "displayName" => $row['UserName'],
                            "alter_count" => 0, // This is hard coded for level 100, privacy enabled administrator. Additionally, the success flag is set to false for a level 100 user, to inform the client app to abort trying to look up this user any further. When the admin goes to login, it uses a different packet flow. This is the public facing insecure API.
                            "level" => $row['AccountLevel']
                        );
                        break;
                    }

                    $data = array(
                        "user" => $row['UserName'],
                        "displayName" => $row['DisplayName'],
                        "alter_count" => $alterCount,
                        "level" => $row['AccountLevel']
                    );

                } else {
                    $reason = "Username required";
                }
                break;
            }

            default: {
                $success=false;
                $reason = "Method Not Allowed";
                break;
            }
        }

        die(json_encode(array(
            "success" => $success,
            "user" => $username,
            "id" => $ID,
            "path"=>$route,
            "type" => $request,
            "reason" => $reason,
            "data" => $data
        )));

        break;
    }

    case "/auth/login": {
        $success = false;
        $data = array();
        
        // Only accepts handling via POST requests
        $packet = json_decode(file_get_contents("php://input"), true);

        $username = $packet['username'];
        $password = $packet['auth'];

        // Begin the authentication process
        // We will return either a success or a failure
        // 
        // If success, we'll return the authentication token that should be included in all future requests.
        // When the token gets near to expiration, we will automatically renew the token for the client.
        
        $DB = get_DB("switchboard");

        $res = $DB->query("SELECT * FROM users WHERE `UserName`='".$username."';");
        if($res->num_rows ==0){
            $success=false;
        } else {
            $row = $res->fetch_assoc();

            $Salt = $row['PasswordSalt'];
            $Hash = md5($password.":".$Salt);
            $UserID = $row['ID'];

            if($Hash == $row['PasswordHash']) {
                $success = true;

                // Generate a authentication token
                $Token = gen_uuid(); // NOTE: We do not invalidate previous auth tokens here. We yield to expirations. Once expired, they get flushed from database anyway.

                // Set token scope
                $Scope = 1; // User login by password
                $ISS = time();
                $Expire = $ISS + (60*60*24); // ONE DAY
                $Flags = 1; // Only usable for user login, not for automated bot actions. 
                
                // Push the token to the database
                $stmt = $DB->prepare("INSERT INTO Access (User, Token, TokenScope, TokenFlags, Expire, IssuedAt) VALUES (?, ?, ?, ?, ?, ?);");
                $stmt->bind_param("ssiiii", $UserID, $Token, $Scope, $Flags, $Expire, $ISS);
                $stmt->execute();
                $stmt->close();

                $DB->commit();


                // Make a Switchboard Access Token
                $SAT = MakeSAT($Token, $Expire, $ISS);

                $data['token'] = $SAT;
            } else {
                $success = false;
            }
        }

        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "reason" => $reason,
            "type" => $request,
            "id" => $ID,
            "data" => array (
                "username" => $username,
                "token" => $data['token']
            )
        )));

        break;
    }

    case "/auth/check": {
        $success = false;
        $auth = get_Authorization();

        $reply = ValidateSAT($auth);

        $success = $reply->Success;

        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "type" => $request,
            "id" => $ID,
            "data" =>  array(
                "id" => $reply['id']
            )
        )));

        break;
    }

    case "/auth/refresh": {
        $success = false;
        $packet = json_decode(file_get_contents("php://input"), true);

        $DB = get_DB("switchboard");
        $NewToken = "";

        $AuthHeader = get_Authorization();
        $reply = ValidateSAT($AuthHeader);
        if($reply->Success) {
            // Valid SAT. Now verify the token's scope and flags. In both instances it should just be a 1.
            if($reply->Scope == 1 && $reply->Flags == 1) {
                $success = true;
                // Make new token
                $token = gen_uuid();
                $iss = time();
                $expire = $iss + (60*60*24);
                $id = $reply->ID;

                // Delete the old token and insert the new one
                $DB->query("DELETE FROM Access WHERE Token='".$reply->Token."';");
                $stmt = $DB->prepare("INSERT INTO Access (User, Token, TokenScope, TokenFlags, Expire, IssuedAt) VALUES (?,?,?,?,?);");
                $stmt->bind_param("ssiiii", $id, $token, 1, 1, $expire, $iss);
                $stmt->execute();
                $stmt->close();

                $DB->commit();

                $NewToken = MakeSAT($token, $expire, $iss);
            }
        } else {
            $success = false;
            $NewToken = "";
        }

        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "id" => $ID,
            "type" => $request,
            "data" => array(
                "token" => $NewToken
            )
        )));

        break;
    }


    case "/version": {
        die(json_encode(array(
            "success" => true,
            "id" => $ID,
            "path" => $route,
            "type" => $request,
            "data" => array(
                "product" => "Switchboard API Server (PHP)",
                "version" => $VERSION
            )
        )));
    }

    default: {
        die(json_encode(array(
            "result"=> "FAIL",
            "type"=> $request,
            "path"=> $route,
            "id"=> $ID
        )));
        break;
    }
}

?>