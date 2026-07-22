import json;

class Response:
    id = "";
    success = False;
    type = "";
    reason = None;
    path = "";

    def __init__(self, id: str, success: bool, type: str, reason: str | None, path: str):
        self.id = id;
        self.success=success;
        self.type=type;
        self.reason=reason;
        self.path=path;

    def encode(self):
        return json.dumps(self);

    @staticmethod
    def decode(encoded):
        r=json.load(encoded);
        return Response(r["id"], r["success"], r["type"], r["reason"], r["path"]);