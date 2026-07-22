from libswitchboard.networking.response import Response;

class S2CLazyResponse(Response):
    def __init__(self):
        print("Lazy Response")