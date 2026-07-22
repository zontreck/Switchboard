[Serializable]
public abstract class Response
{
    public string id;
    public string path;
    public string type;
    public string? reason;
    public bool success;

    public abstract string Encode();
}