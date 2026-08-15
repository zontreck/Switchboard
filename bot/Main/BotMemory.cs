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
    /// This is used to control the backend. This is an admin code that needs to be set both here, and on the backend php server.
    /// </summary>
    public string PSK;

    /// <summary>
    /// Used to indicate where we find the persistent data files
    /// </summary>
    public bool DockerEnv;
}