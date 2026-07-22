using DSharpPlus;
using DSharpPlus.Entities;
using LibSwitchboard;
using LibSwitchboard.Args;

namespace switchboard;

class Program
{
  static void print(string arg)
  {
    Console.WriteLine(arg);
  }
  static async Task<int> Main(string[] args)
  {

    print("  ██████  █     █░ ██▓▄▄▄█████▓ ▄████▄   ██░ ██  ▄▄▄▄    ▒█████   ▄▄▄       ██▀███  ▓█████▄ ");
    print("▒██    ▒ ▓█░ █ ░█░▓██▒▓  ██▒ ▓▒▒██▀ ▀█  ▓██░ ██▒▓█████▄ ▒██▒  ██▒▒████▄    ▓██ ▒ ██▒▒██▀ ██▌");
    print("░ ▓██▄   ▒█░ █ ░█ ▒██▒▒ ▓██░ ▒░▒▓█    ▄ ▒██▀▀██░▒██▒ ▄██▒██░  ██▒▒██  ▀█▄  ▓██ ░▄█ ▒░██   █▌");
    print("  ▒   ██▒░█░ █ ░█ ░██░░ ▓██▓ ░ ▒▓▓▄ ▄██▒░▓█ ░██ ▒██░█▀  ▒██   ██░░██▄▄▄▄██ ▒██▀▀█▄  ░▓█▄   ▌");
    print("▒██████▒▒░░██▒██▓ ░██░  ▒██▒ ░ ▒ ▓███▀ ░░▓█▒░██▓░▓█  ▀█▓░ ████▓▒░ ▓█   ▓██▒░██▓ ▒██▒░▒████▓ ");
    print("▒ ▒▓▒ ▒ ░░ ▓░▒ ▒  ░▓    ▒ ░░   ░ ░▒ ▒  ░ ▒ ░░▒░▒░▒▓███▀▒░ ▒░▒░▒░  ▒▒   ▓▒█░░ ▒▓ ░▒▓░ ▒▒▓  ▒ ");
    print("░ ░▒  ░ ░  ▒ ░ ░   ▒ ░    ░      ░  ▒    ▒ ░▒░ ░▒░▒   ░   ░ ▒ ▒░   ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ▒  ▒ ");
    print("░  ░  ░    ░   ░   ▒ ░  ░      ░         ░  ░░ ░ ░    ░ ░ ░ ░ ▒    ░   ▒     ░░   ░  ░ ░  ░ ");
    print("      ░      ░     ░           ░ ░       ░  ░  ░ ░          ░ ░        ░  ░   ░        ░    ");
    print("                               ░                      ░                              ░      ");

    print("\n\n");

    var response = await NetworkInterface.GetServerVersion();
    print($"Server version: {response.data.product}/{response.data.version}");
    print($"Switchboard Discord Bot Version: {GlobalConsts.Version}");

    // Two args need parsing: token, botpsk
    // PSK is used for administrative actions. 
    // Token is the Discord bot token.
    ArgumentBuilder bldr = new ArgumentBuilder();
    bldr.withStringArgument("token", required: true, value: "Discord Token");
    bldr.withStringArgument("botpsk", required: true, value: "Required PSK");
    bldr.withBooleanArgument("help", required: false, value: false);

    Arguments defaults = bldr.Build();


    Arguments user = ArgumentParser.Parse(args);
    if (user.HasArg("help") || !user.HasArg("token") || !user.HasArg("botpsk"))
    {
      print(ArgumentHelpers.GenerateHelpMessage(new List<IArgument>(defaults.GetAllArguments()), "switchboard --token [] --botpsk []"));
      return 1;
    }
    MemoryState ms = new MemoryState();
    ms.DiscordToken = user.GetArgument("token").GetValue() as string;
    ms.PSK = user.GetArgument("botpsk").GetValue() as string;

    print("Loaded provided values...");

    DiscordClient client = DiscordClientBuilder.CreateDefault(ms.DiscordToken, DiscordIntents.AllUnprivileged | DiscordIntents.GuildMembers | DiscordIntents.MessageContents).Build();
    await client.ConnectAsync(activity: new DiscordActivity($"v{GlobalConsts.Version}", DiscordActivityType.Playing), status: DiscordUserStatus.Online);



    while (true)
    {
      Thread.Sleep(1000);
    }

    return 0;
  }
}
