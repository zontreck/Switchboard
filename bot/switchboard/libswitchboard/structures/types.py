import json;

class ServerVersion:
    product="";
    version = "";

    def __init__(self, product,version):
        self.product=product;
        self.version=version;

    def encode(self):
        return json.dumps(self);

    @staticmethod
    def decode(encoded):
        rep=json.loads(s=encoded);

        return ServerVersion(rep["product"], rep["version"]);