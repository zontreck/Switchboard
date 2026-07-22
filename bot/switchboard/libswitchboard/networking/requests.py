from switchboard.libswitchboard.networking.responses.version import S2CServerVersionResponse;
import requests;
from switchboard.libswitchboard.globals import API_URL;

class NetworkInterface:
    def getServerVersion() -> S2CServerVersionResponse:
        resp=requests.get(API_URL + "/version");
        x = resp.json();
        print("debug: ");
        print(x);
        
        response = S2CServerVersionResponse();
        response.decode(x);
        return response;