import json;

class Response:
    id: str = "";
    success: bool = False;
    type: str = "";
    reason: str | None = None;
    path: str = "";

    def __init__(self):
        pass

    def encode(self) -> dict:
        return {"id": self.id, "success": self.success, "type": self.type, "reason": self.reason, "path": self.path};

    def decode(self, encoded:dict):
        self.id = encoded["id"];
        self.success = encoded["success"];
        self.type = encoded["type"];
        self.path = encoded["path"];
        if(encoded.__contains__("reason")):
            if(encoded["reason"] is None):
                self.reason = None;
            else:
                self.reason = encoded["reason"];
        return;