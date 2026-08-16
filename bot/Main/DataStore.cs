using Newtonsoft.Json;

namespace switchboard;
/**
* This holds all the bot's settings.
*/
public class DataStore
{
    private static PersistentMemory _memory = null;
    private static readonly object _lck = new();
    public static PersistentMemory Memory
    {
        get
        {
            lock (_lck)
            {
                if (_memory == null)
                {
                    _memory = PersistentMemory.loadFromFile();
                }
                return _memory;
            }
        }
    }
    public static string GetDataPath()
    {
        MemoryState ms = MemoryState.Instance;
        if (ms.DockerEnv)
        {
            return "/app/data";
        }
        else
        {
            return Path.Combine(Directory.GetCurrentDirectory(), "Data");
        }
    }

    public static void EnsureDataExists()
    {
        if (!Directory.Exists(GetDataPath()))
        {
            Directory.CreateDirectory(GetDataPath());
        }
    }

}

public class PersistentMemory
{
    public String GlobalURL = GlobalConsts.OfficialServer;
    public Dictionary<ulong, string> UserServerPreference = [];
    public Dictionary<ulong, string> GuildServerPreference = [];


    public void saveToFile()
    {
        // Save persistent memory to file at path: GetDataPath()/persist.json
        string js = Newtonsoft.Json.JsonConvert.SerializeObject(this, Newtonsoft.Json.Formatting.Indented);
        File.WriteAllText(Path.Combine(DataStore.GetDataPath(), "persist.json"), js);
    }

    public static PersistentMemory loadFromFile()
    {
        string path = Path.Combine(DataStore.GetDataPath(), "persist.json");
        if (!File.Exists(path))
        {
            return new();
        }
        string encoded = File.ReadAllText(path);
        return JsonConvert.DeserializeObject<PersistentMemory>(encoded) ?? new();
    }
}