namespace switchboard;

class MemoryState
{
    private static readonly object lck = new object();
    private static MemoryState instance = null;
    private MemoryState()
    {

    }

    public static MemoryState Instance
    {
        get
        {
            lock (lck)
            {
                if (instance == null) instance = new();
                return instance;
            }
        }
    }
    /// <summary>
    /// This is the discord token used to login to discord's servers.
    /// </summary>
    public string DiscordToken;

    /// <summary>
    /// This is used to control the backend. This is a Access Token created within the app by a user with Administrator permissions. This token must have a scope of 80, and an expiry of Never. This token can be revoked later if it is ever leaked by the server's administrator.
    /// </summary>
    public string AccessToken;

    /// <summary>
    /// Used to indicate where we find the persistent data files
    /// </summary>
    public bool DockerEnv;
}