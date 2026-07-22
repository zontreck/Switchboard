from switchboard.libswitchboard.structures.types import ServerVersion
from switchboard.libswitchboard.networking.responses.lazy import S2CLazyResponse;

class S2CServerVersionResponse (S2CLazyResponse):
    data: ServerVersion;

    def encode(self) -> dict:
        s = super().encode();
        s["data": self.data.encode()];
        return s;


    def decode(self, encoded: dict):
        super().decode(encoded);
        return;