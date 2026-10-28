<?php



function get_DB($dbname)
{
    global $HOST, $DBUSER, $DBPASS;

    $DB_Handle = new mysqli($HOST, $DBUSER, $DBPASS, $dbname);


    return $DB_Handle;
}


?>