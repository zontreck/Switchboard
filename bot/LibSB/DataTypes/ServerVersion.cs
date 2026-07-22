using Newtonsoft.Json;

[Serializable]
public class ServerVersion
{
    public string product;
    public string version;
    public ServerVersion(string product, string version)
    {
        this.product = product;
        this.version = version;
    }


    public string Encode()
    {
        return JsonConvert.SerializeObject(this);
    }

    public static ServerVersion Decode(string encoded)
    {
        return JsonConvert.DeserializeObject<ServerVersion>(encoded) ?? new ServerVersion("", "");
    }
}