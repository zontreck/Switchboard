<?php

$DEBUG = true;

$VERSION = "0.1.0+0617261739";

$DEFAULT_USER_FIELDS = array(
                            array(
                                "Name" => "Description",
                                "Type" => -1,
                                "Order" => 0
                            ),
                            array(
                                "Name" => "Color",
                                "Type" => -2,
                                "Order" => 1
                            )
                        );

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
header("Expires: 0", true);
header("Cache-Control: max-age=0, no-store, no-cache, must-revalidate, proxy-revalidate", true);

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
    try {
        $STMT->execute();

    }catch(Exception $E) {
        $payload="payload too long to cache";
        $STMT->execute();
    }
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

    case "/cron": {
        // Execute recurring cron tasks, such as checking for expired content in the database and cleaning it up.
        header("Content-Type: text/plain");
        echo("System Switchboard Server v/$VERSION (PHP)\n> Cron task script invoked.\n\n");

        echo("> Processing audit log prune...\n");
        $DB = get_DB("switchboard");
        // First, figure out the exact time for prune.
        $now = time();
        $oneDay = (60*60*24);
        $yesterday = time()-$oneDay;
        $pruneStmt = $DB->prepare("DELETE FROM `Audit` WHERE Timestamp < ?;");
        $pruneStmt->bind_param("i", $yesterday);
        $pruneStmt->execute();
        $pruneResult = $pruneStmt->get_result();
        echo("> Pruned ".$pruneResult->num_rows." entries from audit log\n");
        $pruneStmt->close();
        $DB->commit();

        echo("> Processing access token prune...\n");
        $pruneStmt = $DB->prepare("DELETE FROM `Access` WHERE Expire < ?;");
        $pruneStmt->bind_param("i", $now);
        $pruneStmt->execute();
        $pruneResult = $pruneStmt->get_result();
        echo("> Pruned ".$pruneResult->num_rows." entries from access token registry.\n");
        $pruneStmt->close();
        $DB->commit();

        $DB->close();
        die("\n\nFinished with all tasks"); // Currently, no task logic exists here.
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
                    $stmt = $DB->prepare("SELECT * FROM users WHERE UserName=?;");
                    $stmt->bind_param("s", $username);
                    $stmt->execute();
                    $R = $stmt->get_result();
                    
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
                    $userid = gen_uuid();

                    $stmt = $DB->prepare("INSERT INTO users (UserName, PasswordSalt, PasswordHash, DisplayName, ID) VALUES (?,?,?,?, ?);");

                    $stmt->bind_param("sssss", $username, $Salt, $Hash, $username, $userid);
                    $stmt->execute();
                    $stmt->close();

                    $DB->commit();

                    $success=true;
                    $reason="User created";

                    foreach ($DEFAULT_USER_FIELDS as $value) {
                        // Create the default fields for the specified user.
                        $fieldID = gen_uuid();
                        $dfStmt = $DB->prepare("INSERT INTO Fields (User, ID, FieldName, FieldType, Order) VALUES (?,?,?,?, ?);");
                        $dfStmt->bind_param("sssi", $userid, $fieldID, $value["Name"], $value["Type"], $value["Order"]);
                        $dfStmt->execute();
                        $dfStmt->close();
                        $DB->commit();
                    }

                    $data = array(
                        "user" => $username,
                        "displayName" => $username,
                        "alter_count" => 0,
                        "level" => 1,
                        "id" => $userid,
                        "fields" => null // I am lazy, and do not feel like iterating over this. We'll just have the user send a request.
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
                    $fetchStmt = $DB->prepare("SELECT * FROM users WHERE UserName=?;");
                    $fetchStmt->bind_param("s", $username);
                    $fetchStmt->execute();
                    $resp = $fetchStmt->get_result();

                    if($resp->num_rows == 0) {
                        $success = false;
                        $reason = "No such user";
                        break;
                    }
                    $row = $resp->fetch_assoc();
                    $alterFetch = $DB->prepare("SELECT * FROM Alters WHERE User=?;");
                    $alterFetch->bind_param("s", $row['ID']);
                    $alterFetch->execute();
                    $alters = $alterFetch->get_result();


                    $fieldsFetch = $DB->prepare("SELECT * FROM Fields WHERE User=?;");
                    $fieldsFetch->bind_param("s", $row['ID']);
                    $fieldsFetch->execute();
                    $fields = $fieldsFetch->get_result();

                    $fieldData = array();
                    while($fRow = $fields->fetch_assoc()) {
                        array_push($fieldData, array(
                            "id" => $fRow['ID'],
                            "type" => $fRow['FieldType'],
                            "name" => $fRow['FieldName'],
                            "order" => $fRow['SortOrder']
                        ));
                    }

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
                            "level" => $row['AccountLevel'],
                            "fields" => array()
                        );
                        break;
                    }

                    $data = array(
                        "user" => $row['UserName'],
                        "displayName" => $row['DisplayName'],
                        "alter_count" => $alterCount,
                        "level" => $row['AccountLevel'],
                        "id" => $row['ID'],
                        "fields" => $fieldData
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

    case preg_match('#^/alters(?:/([^/]+))?$#', $route, $matches) === 1: {

        $DB = get_DB("switchboard");
        $packet = json_decode(file_get_contents("php://input"), true);

        $userid = $matches[1] ?? null; // null if /alters was requested without a username
        
        $auth = get_Authorization();
        $AuthReply = ValidateSAT($auth);


        $reason = "";

        $success=false;
        $data = array(
            "userid" => $userid
        );

        if($userid == null) {
            $userid = $AuthReply->UserID;
        }

        $headers = apache_request_headers();
        $SkipAlters = $headers["x-sb-skip"];
        $AlterCount = $headers['x-sb-count'];

        switch($request) {
            case "GET": {

                if(!$AuthReply->Success) {
                    $success = false;
                    $reason = "Not Logged In";
                    break;
                }


                
                // TODO: Bind permissions to alters, so that alters have a permission group set to them, changeable by the user, but the Permission Group will allow setting which friends can view what alters, or how much info can be shown
                // 
                // For now, We'll use Flags to determine public or private status
                $rres=null;
                if($AlterCount == -1) {
                    $stmt = $DB->prepare("SELECT * FROM Alters WHERE User='$userid';");
                    $stmt->bind_param("s", $userid);
                    $stmt->execute();
                    $rres = $stmt->get_result();
                } else {
                    $stmt = $DB->prepare("SELECT * FROM Alters WHERE User=? LIMIT ? OFFSET ?;");
                    $stmt->bind_param("sii", $userid, $AlterCount, $SkipAlters);
                    $stmt->execute();
                    $rres = $stmt->get_result();
                }

                if($rres->num_rows < $AlterCount) {
                    header("X-SB-Done: 1");
                    $reason = "DONE";
                }
                $diffUser = !($userid == $AuthReply->UserID);

                $count = 0;
                $alters = array();
                while($row = $rres->fetch_assoc()) {
                    $count++;
                    $flags = $row['Flags'];
                    if(($flags & 2) == 2 && $diffUser) {
                        // Hidden Alter
                        // TODO: Adjust this section to check against a Permission Group
                        continue;
                    }
                    array_push($alters, array(
                        "user" => $row['User'],
                        "id" => $row['ID'],
                        "name" => $row['Name'],
                        "avatar_url" => $row['Avatar'],
                        "fields" => base64_encode($row['Fields']), // This is a CompoundTag. We need to base64 encode for transport.
                        "subid" => $row['SubID'],
                        "parent" => $row['ParentID'],
                        "flags" => $row['Flags']
                    ));
                }

                $success = true;
                header("X-SB-Count: $count");
                $data['count'] = $count;
                $data['alters'] = $alters;
                break;
            }
        }

        die(json_encode(array(
            "success" => $success,
            "reason" => $reason,
            "type" => $request,
            "path" => $route,
            "id" => $ID,
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
                "id" => $reply->UserID
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
                $id = $reply->UserID;

                // Delete the old token and insert the new one
                //$DB->query("DELETE FROM Access WHERE Token='".$reply->Token."';");
                $stmt = $DB->prepare("INSERT INTO Access (User, Token, TokenScope, TokenFlags, Expire, IssuedAt) VALUES (?,?,?,?,?,?);");
                $stmt->bind_param("ssiiii", $id, $token, $reply->Scope, $reply->Flags, $expire, $iss);
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

    case preg_match('#^/images(?:/([^/]+))?$#', $route, $matches) === 1: {

        $DB = get_DB("switchboard");
        $packet = json_decode(file_get_contents("php://input"), true);

        $imgid = $matches[1] ?? null; // null if /user was requested without a username
        
        $reason = "";
        if($imgid == null) {
            $success=  false;
        }
        $success=false;
        $data = null;

        switch($request) {
            case "GET": {
                // Retrieve image from database, return proper content type.
                $res = $DB->query("SELECT * FROM Images WHERE ImageID='$imgid';");
                if($res->num_rows == 0) {
                    http_response_code(404);
                    header("Content-Type: text/html", true);

                    die("<h2>Content not found</h2>");
                }
                $success=true;
                header("Content-Type: image/webp");

                $row = $res->fetch_assoc();
                header("X-SB-CreatedAt: ".$row['Timestamp']);
                die($row['ImageBinary']);
                break;
            }
            case "POST": {
                // Insert new, but not overwrite.
                $SBAuth = get_Authorization();
                $SBAuth = ValidateSAT($SBAuth);

                if($imgid != "new") {
                    $success=false;
                    $reason = "Cannot post to a image ID, you must use the /images/new endpoint.";
                    break;
                }

                // Get the user ID from the authorization response.
                $UserID = "";
                if($SBAuth->Success) {
                    $UserID = $SBAuth->UserID;
                }

                $XIMGID = gen_uuid();
                $data = array(
                    "img" => $XIMGID
                );

                $rawImage = base64_decode($packet["image"]);
                if ($rawImage === false) {
                    throw new Exception("Invalid base64");
                }

                if (!function_exists('imagewebp')) {
                    throw new Exception("WebP not supported on this server");
                }

                $Image = imagecreatefromstring($rawImage);
                if ($Image === false) {
                    throw new Exception("Invalid image data");
                }
                imagepalettetotruecolor($Image);
                imagealphablending($Image, true);
                imagesavealpha($Image, true);

                // Convert image to webp
                ob_start();
                imagewebp($Image, quality: 100);
                $ImgWebP = ob_get_clean();
                imagedestroy($Image);

                // Insert new image into the database
                $stmt = $DB->prepare("INSERT INTO `Images` (OwnerID, ImageID, ImageBinary, Timestamp) VALUES(?, ?, ?, ?);");
                $stmt->bind_param("ssbi", $UserID, $XIMGID, $null, time());
                $stmt->send_long_data(2, $ImgWebP);
                $stmt->execute();
                $stmt->close();

                $DB->commit();

                $success=true;

                
                break;
            }

            case "DELETE": {
                $SBAuth = ValidateSAT(get_Authorization());

                $UserID = $SBAuth->UserID;
                // Query the image data
                $res = $DB->query("SELECT * FROM Images WHERE ImageID='$imgid';");

                if($res->num_rows == 0) {
                    $success=false;
                    $reason = "No such image found";
                    break;
                }

                $row = $res->fetch_assoc();
                if($row['OwnerID'] == $UserID) {
                    // Authorized to delete own resource
                    $DB->query("DELETE FROM Images WHERE ImageID='$imgid';");
                    $success=true;
                    $reason = "Image deleted";
                } else {
                    $success=false;
                    $reason = "Resource Owner";
                }
                break;
            }

            case "PUT": {

                $SBAuth = ValidateSAT(get_Authorization());

                $UserID = $SBAuth->UserID;
                // Query the image data
                $res = $DB->query("SELECT * FROM Images WHERE ImageID='$imgid';");

                if($res->num_rows == 0) {
                    $success=false;
                    $reason = "No such image found";
                    break;
                }

                $row = $res->fetch_assoc();
                if($row['OwnerID'] == $UserID) {
                    // Authorized to replace own resource!
                    $imgData = base64_decode($packet['image']);
                    
                    $Image = imagecreatefromstring($imgData);
                    if ($Image === false) {
                        throw new Exception("Invalid image data");
                    }
                    imagepalettetotruecolor($Image);
                    imagealphablending($Image, true);
                    imagesavealpha($Image, true);

                    // Convert image to webp
                    ob_start();
                    imagewebp($Image, quality: 100);
                    $ImgWebP = ob_get_clean();
                    imagedestroy($Image);

                    $stmt = $DB->prepare("UPDATE Images SET ImageBinary=? WHERE ImageID=?;");
                    $stmt->bind_param("bs", $null, $imgid);
                    $stmt->send_long_data(0, $ImgWebP);
                    $stmt->execute();
                    $stmt->close();

                    $DB->commit();

                    $success=true;
                    $reason = "Image replaced";
                } else {
                    $success=false;
                    $reason = "Resource Owner";
                }
                break;
            }
            
        }


        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "type" => $request,
            "id" => $ID,
            "data" => $data
        )));
        break;
    }


    case preg_match('#^/avatar(?:/([^/]+))?$#', $route, $matches) === 1: {

        $DB = get_DB("switchboard");
        $packet = json_decode(file_get_contents("php://input"), true);

        $avatarid = $matches[1] ?? null; // null if /user was requested without a username
        
        $reason = "";
        if($imgid == null) {
            $success=  false;
        }
        $success=false;
        $data = null;

        $AuthHeader = get_Authorization();
        $AuthReply = ValidateSAT($AuthHeader);

        switch($request) {
            case "GET": {
                // Retrieve image from database, return proper content type.
                $stmt = $DB->prepare("SELECT * FROM Avatars WHERE AlterId=?;");
                $stmt->bind_param("s", $avatarid);
                $stmt->execute();
                $res = $stmt->get_result();

                if($res->num_rows == 0) {
                    // Unlike images, we want to return a not found placeholder here.
                    if(file_exists("placeholder_avatar.png")) {
                        $rawImage = file_get_contents("placeholder_avatar.png");
                        ob_start();

                        $Img = imagecreatefromstring($rawImage);
                        imagepalettetotruecolor($Img);
                        imagealphablending($Img, true);
                        imagesavealpha($Img, true);

                        imagewebp($Img, quality: 100);
                        $ImgWebP = ob_get_clean();
                        imagedestroy($Img);
                        header("Content-Type: image/webp");
                        die($ImgWebP);
                    }
                    http_response_code(404);
                    header("Content-Type: text/html", true);

                    die("<h2>Content not found</h2>");
                } else {
                    $row=$res->fetch_assoc();
                    $ImgWebP = $row['ImageBinary'];
                    header("Content-Type: image/webp");
                    die($ImgWebP);

                }
                $stmt->close();
                $success=true;
                header("Content-Type: image/webp");

                $row = $res->fetch_assoc();
                header("X-SB-CreatedAt: ".$row['Timestamp']);
                die($row['ImageBinary']);
                break;
            }
            case "POST": {
                // Insert or overwrite the avatar, if the current user has an alter with this ID.

                // Get the user ID from the authorization response.
                $UserID = "";
                if($AuthReply->Success) {
                    $UserID = $AuthReply->UserID;
                }

                $stmt = $DB->prepare("SELECT * FROM Alters WHERE ID=? AND User=?;");
                $stmt->bind_param("ss", $avatarid, $UserID);
                $stmt->execute();
                $qres = $stmt->get_result();
                $stmt->close();

                if($qres->num_rows == 0) {
                    $success=false;
                    $reason = "Unauthorized action";
                    break;
                }

                $rawImage = base64_decode($packet["image"]);
                if ($rawImage === false) {
                    throw new Exception("Invalid base64");
                }

                if (!function_exists('imagewebp')) {
                    throw new Exception("WebP not supported on this server");
                }

                $Image = imagecreatefromstring($rawImage);
                if ($Image === false) {
                    throw new Exception("Invalid image data");
                }
                imagepalettetotruecolor($Image);
                imagealphablending($Image, true);
                imagesavealpha($Image, true);
                // Convert image to webp
                ob_start();
                imagewebp($Image, quality: 100);
                $ImgWebP = ob_get_clean();
                imagedestroy($Image);

                // Insert new image into the database
                $stmt = $DB->prepare("REPLACE INTO `Avatars` (User, AlterId, ImageBinary, Timestamp) VALUES(?, ?, ?, ?);");
                $stmt->bind_param("ssbi", $UserID, $avatarid, $null, time());
                $stmt->send_long_data(2, $ImgWebP);
                $stmt->execute();
                $stmt->close();

                $DB->commit();

                $success=true;

                $stmt = $DB->prepare("UPDATE `Alters` SET `Avatar` = ? WHERE ID = ?;");
                $stmt->bind_param("ss", $avatarid, $avatarid);
                $stmt->execute();
                $stmt->close();

                
                break;
            }

            case "DELETE": {
                $SBAuth = ValidateSAT(get_Authorization());

                $UserID = $SBAuth->UserID;
                // Query the image data
                $res = $DB->query("SELECT * FROM Avatars WHERE AlterId='$avatarid';");

                if($res->num_rows == 0) {
                    $success=false;
                    $reason = "No such image found";
                    break;
                }

                $row = $res->fetch_assoc();
                if($row['User'] == $UserID) {
                    // Authorized to delete own resource
                    $DB->query("DELETE FROM Avatars WHERE AlterId='$avatarid';");
                    $success=true;
                    $reason = "Image deleted";
                } else {
                    $success=false;
                    $reason = "Resource Owner";
                }
                break;
            }
            
        }


        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "type" => $request,
            "reason" => $reason,
            "id" => $ID,
            "data" => $data
        )));
        break;
    }

    case preg_match('#^/alter(?:/([^/]+))?$#', $route, $matches) === 1: {

        $success=true;
        $DB = get_DB("switchboard");
        $packet = json_decode(file_get_contents("php://input"), true);

        $alterId = $matches[1] ?? null; // null if /alter was requested without a alter specified.
        
        $reason = "";
        if($alterId == null) {
            $success=  false;
        }
        $data = null;
        $SBAuth = ValidateSAT(get_Authorization());

        $res = $DB->query("SELECT * FROM Alters WHERE ID='$alterId';");

        if($res->num_rows == 0 ) {
            $success=false;
            $reason="No such alter";
        }

        $row = $res->fetch_assoc();

        if($SBAuth->UserID != $row['User'] && $res->num_rows != 0) { // This endpoint (/alter) requires you to be the one who 'owns' the alter being managed or retrieved.
            // Wrong Endpoint used.
            $success = false;
            $reason = "Access Denied";
        }
        if ($alterId == "new" && $request == "PUT") {
            $success=true;
            $reason = "";
        }

        if($success) {
            switch($request) {
                case "GET": {

                    // Populate the response
                    $reason = "Alter exists";
                    $data = array(
                        "user" => $row['User'],
                        "id" => $row['ID'],
                        "name" => $row['Name'],
                        "avatar_url" => $row['Avatar'],
                        "fields" => base64_encode($row['Fields']), // CompoundTag binary.
                        "subid" => (int) $row['SubID'],
                        "parent" => $row['ParentID'],
                        "flags" => (int) $row['Flags']
                    );
                    break;
                }

                case "PUT": {
                    $alter = $packet['alter'];
                    $alterId = gen_uuid();

                    $nFlags = 0;
                    $fieldBinary = base64_decode($alter['fields']);

                    $stmt = $DB->prepare("INSERT INTO Alters (User, ID, Name, Avatar, Fields, SubID, ParentID, Flags) VALUES (?, ?, ?, ?, ?, ?, ?, ?);");
                    $stmt->bind_param("ssssbisi", $SBAuth->UserID, $alterId, $alter['name'], $alter['avatar'], $null, $alter['subid'], $alter['parent'], $nFlags);
                    $stmt->send_long_data(4, $fieldBinary);
                    $stmt->execute();
                    $stmt->close();

                    $DB->commit();

                    $reason = "Alter created";
                    $data = array(
                        "id" => $alterId,
                        "user" => $SBAuth->UserID,
                        "name" => $alter['name'],
                        "avatar_url" => $alter['avatar'],
                        "fields" => base64_encode($fieldBinary),
                        "subid" => (int) $alter['subid'],
                        "parent" => $alter['parent'],
                        "flags" => 0
                    );
                    break;
                }

                case "DELETE": {
                    $stmt = $DB->prepare("DELETE FROM Alters WHERE User=? AND ID=?;");
                    $stmt->bind_param("ss", $SBAuth->UserID, $alterId);
                    $stmt->execute();
                    $stmt->close();

                    $DB->commit();

                    $reason = "Alter deleted";
                    $data = null;
                    break;
                }

                case "PATCH": {
                    $alter = $packet['alter'];

                    if (array_key_exists("fields", $alter)) {
                        $fieldData = base64_decode($alter['fields']);
                    } else {
                        $fieldData = $row['Fields'];
                    }

                    $name = $alter['name'] ?? $row['Name'];
                    $avatar = $alter['avatar'] ?? $row['Avatar'];
                    $subid = $alter['subid'] ?? $row['SubID'];
                    $parent = $alter['parent'] ?? $row['ParentID'];
                    $flags = $alter['flags'] ?? $row['Flags'];

                    // Placeholder variable for blob field
                    $null = null;

                    $stmt = $DB->prepare("
                        REPLACE INTO `Alters`
                        (User, ID, Name, Avatar, Fields, SubID, ParentID, Flags)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
                    ");

                    $stmt->bind_param(
                        "ssssbisi",
                        $SBAuth->UserID,
                        $alterId,
                        $name,
                        $avatar,
                        $null,
                        $subid,
                        $parent,
                        $flags
                    );

                    // Index is zero-based
                    $stmt->send_long_data(4, $fieldData);

                    $stmt->execute();
                    $stmt->close();

                    $DB->commit();

                    $reason = "Alter updated";
                    $data = null;
                    break;
                }

                default: {
                    $data = array();
                    break;
                }
            }
        }
        


        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "type" => $request,
            "reason" => $reason,
            "id" => $ID,
            "data" => $data
        )));
        break;
    }

    case "/fields": {

        $AuthHeader = get_Authorization();
        $AuthReply = ValidateSAT($AuthHeader);

        if(!$AuthReply->Success) {
            $success=false;
            $reason = "Not Logged In";
        } else {
            $DB = get_DB("switchboard");
            $stmt = $DB->prepare("SELECT * FROM Fields WHERE User=?;");
            $stmt->bind_param("s", $AuthReply->UserID);
            $success=true;
            $stmt->execute();
            $res = $stmt->get_result();

            $data = array();

            while($row = $res->fetch_assoc()) {
                array_push($data, array(
                    "id" => $row['ID'],
                    "name" => $row['FieldName'],
                    "type" => $row['FieldType'],
                    "order" => $row['SortOrder']
                ));
            }
        }
        


        die(json_encode(array(
            "success" => $success,
            "path" => $route,
            "type" => $request,
            "reason" => $reason,
            "id" => $ID,
            "data" => $data
        )));
        break;
    }

    case preg_match('#^/field(?:/([^/]+))?$#', $route, $matches) === 1: {
        $success=true;
        $DB = get_DB("switchboard");
        $packet = json_decode(file_get_contents("php://input"), true);
        $field = $matches[1] ?? null;
        $data = array();


        $AuthHeader = get_Authorization();
        $AuthReply = ValidateSAT($AuthHeader);
        if(!$AuthReply->Success) {
            $success=false;
            $reason = "Not Logged In";
        }else {

            if($field == null) {
                $success=  false;
                $reason = "Field must not be null";
            } else {
                switch($request) {
                    case "GET": {
                        // Retrieve the field for the current user.
                        // Retrieving for a different user requires using the /user/{id} endpoint.
                        $stmt = $DB->prepare("SELECT * FROM Fields WHERE User=? AND ID=?;");
                        $stmt->bind_param("ss", $AuthReply->UserID, $field);
                        $stmt->execute();
                        $res = $stmt->get_result();
                        $row = $res->fetch_assoc();
                        $data = array(
                            "id" => $row['ID'],
                            "type" => $row['FieldType'],
                            "name" => $row['FieldName'],
                            "order" => $row['SortOrder']
                        );
                        $stmt->close();
                        break;
                    }
                    case "DELETE": {
                        // Delete the field for the current user, if the field is not a system field.
                        $stmt = $DB->prepare("SELECT * FROM Fields WHERE User=? AND ID=?;");
                        $stmt->bind_param("ss", $AuthReply->UserID, $field);
                        $stmt->execute();
                        $res = $stmt->get_result();
                        $row = $res->fetch_assoc();

                        if($row['FieldType'] < 0) {
                            // System Row.
                            $success = false;
                            $reason = "Cannot delete a system field. It is required for proper functionality.";
                        } else {
                            $stmt = $DB->prepare("DELETE FROM Fields WHERE User=? AND ID=?;");
                            $stmt->bind_param("ss", $AuthReply->UserID, $field);
                            $stmt->execute();
                            $stmt->close();
                            $DB->commit();

                            $success=true;
                            $reason = "Field Deleted";
                        }

                        die(json_encode(array(
                            "id" => $ID,
                            "path" => $route,
                            "type" => $request,
                            "reason" => $reason,
                            "success" => $success
                        )));
                        break;
                    }

                    case "POST": {

                        if($field == "new") {
                            $field = gen_uuid();
                        } else {
                            $newField = false;
                        }
                        
                        // Update or add the field for the current user, if the field is not a system field.
                        $stmt = $DB->prepare("SELECT * FROM Fields WHERE User=? AND ID=?;");
                        $stmt->bind_param("ss", $AuthReply->UserID, $field);
                        $stmt->execute();
                        $res = $stmt->get_result();
                        if($res->num_rows == 0) {
                            $newField = true;
                        }else {
                            $row = $res->fetch_assoc();
                        }

                        if($row['FieldType'] < 0) $packet['type'] = $row['FieldType'];

                        $stmt = $DB->prepare("REPLACE INTO Fields (User, ID, FieldName, FieldType, SortOrder) VALUES (?, ?, ?, ?, ?);");
                        $stmt->bind_param("sssii", $AuthReply->UserID, $field, $packet['name'], $packet['type'], $packet['order']);
                        $stmt->execute();
                        $stmt->close();
                        $DB->commit();

                        $success=true;
                        $reason = "Field Updated";

                        $data = array(
                            "id" => $field,
                            "name" => $packet['name'],
                            "type" => $packet['type'],
                            "order" => $packet['order']
                        );
                        

                        die(json_encode(array(
                            "id" => $ID,
                            "path" => $route,
                            "type" => $request,
                            "reason" => $reason,
                            "success" => $success,
                            "data" => $data
                        )));
                        break;
                    }
                }
            }
        }



        die(json_encode(array(
            "id" => $ID,
            "success" => $success,
            "reason" => $reason,
            "path" => $route,
            "type" => $request,
            "data" => $data
        )));
        break;
    }

    case "/robots.txt": {
        header("Content-Type: text/plain");
        http_response_code(200);
        die("User-agent: *\nDisallow: /");
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