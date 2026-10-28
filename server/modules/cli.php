<?php

// Source - https://stackoverflow.com/a/933375
// Posted by Jordan S. Jones, modified by community. See post 'Timeline' for change history
// Retrieved 2026-10-28, License - CC BY-SA 3.0

function isCommandLineInterface()
{
    return (php_sapi_name() === 'cli');
}

?>