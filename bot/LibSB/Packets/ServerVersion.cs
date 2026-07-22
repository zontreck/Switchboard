using Newtonsoft.Json;

public class S2CServerVersionPacket : S2CLazyResponse
{
    public ServerVersion data;
    public S2CServerVersionPacket(string id, string type, string path, string? reason, bool success, ServerVersion data) : base(id, type, path, reason, success)
    {
        this.data = data;
    }

    public S2CServerVersionPacket() : base()
    {
        data = new ServerVersion("", "");
    }

    public override string Encode()
    {
        return JsonConvert.SerializeObject(this);
    }

    public static new S2CServerVersionPacket Decode(string encoded)
    {
        return JsonConvert.DeserializeObject<S2CServerVersionPacket>(encoded) ?? new S2CServerVersionPacket();
    }
}