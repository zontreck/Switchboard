namespace LibSwitchboard;

public class NetworkInterface
{
    public static async Task<S2CServerVersionPacket> GetServerVersion(string apiServer)
    {
        HttpClient client = new HttpClient();

        var reply = await client.GetAsync($"{apiServer}/version");
        string replyData = await reply.Content.ReadAsStringAsync();
        return S2CServerVersionPacket.Decode(replyData);
    }
}
