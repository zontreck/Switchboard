<?php

class ServerReply {
    public bool $Success;
    public string $Reason;
    public string $Type;
    public string $Path;
    public string $ID;
    public array $Data;

    public function __construct() {
        $this->ID = gen_uuid();
        $this->Success=false;
        $this->Reason = "NIL";
        $this->Type = "NUL";
        $this->Path = "PTH";
        $this->Data=null;
    }

    public function encode() {
        $arr = array(
            "success" => $this->Success,
            "reason" => $this->Reason,
            "type" => $this->Type,
            "path" => $this->Path,
            "id" => $this->ID
        );

        if(!is_null($this->Data)) {
            $arr["data"] = $this->Data;
        }
        return json_encode($arr);
    }
}