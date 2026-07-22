import json

from libswitchboard.structures.types import ServerVersion
from libswitchboard.networking.lazy import S2CLazyResponse;

class S2CServerVersionResponse (S2CLazyResponse):
    data=None;

    def __init__(self, data: ServerVersion):
        self.data=data;

    def encode(self):
        return json.dumps(self);

    @staticmethod
    def decode(encoded: str):
        dec = json.loads(s=encoded);
        return S2CServerVersionResponse(ServerVersion.decode(dec["data"]));