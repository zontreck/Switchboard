namespace LibSwitchboard;

public class NetworkInterface
{
    public static async Task<S2CServerVersionPacket> GetServerVersion()
    {
        HttpClient client = new HttpClient();

        var reply = await client.GetAsync($"{GlobalConsts.BaseAPIURL}/version");
        string replyData = await reply.Content.ReadAsStringAsync();
        return S2CServerVersionPacket.Decode(replyData);
    }
}
