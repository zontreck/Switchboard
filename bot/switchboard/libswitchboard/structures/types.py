import json;

class ServerVersion:
    product="";
    version = "";

    def __init__(self, product,version):
        self.product=product;
        self.version=version;

    def encode(self) -> dict:
        return {"product": self.product, "version": self.version};

    def decode(self,encoded: dict):
        self.product = encoded["product"];
        self.version = encoded["version"];