using Newtonsoft.Json;

[Serializable]
public class S2CLazyResponse : Response
{
    public S2CLazyResponse(string id, string type, string path, string? reason, bool success)
    {
        this.id = id;
        this.type = type;
        this.path = path;
        this.reason = reason;
        this.success = success;
    }

    public S2CLazyResponse()
    {
        id = GlobalConsts.UUID_ZERO;
        type = "None";
        path = "/";
        reason = null;
        success = false;
    }

    public override string Encode()
    {
        return JsonConvert.SerializeObject(this);
    }

    public static S2CLazyResponse Decode(string encoded)
    {
        return JsonConvert.DeserializeObject<S2CLazyResponse>(encoded) ?? new S2CLazyResponse();
    }
}