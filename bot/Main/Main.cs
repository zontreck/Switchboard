
using LibSwitchboard;
using LibSwitchboard.Args;
using Microsoft.Extensions.Logging;
using NetCord;
using NetCord.Gateway;
using NetCord.Logging;

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

    GatewayClient client = new(new BotToken(ms.DiscordToken), new GatewayClientConfiguration()
    {
      Logger = new ConsoleLogger(),
      Intents = GatewayIntents.AllNonPrivileged | GatewayIntents.GuildUsers | GatewayIntents.MessageContent
    });

    await client.StartAsync(new PresenceProperties(UserStatusType.Online)
    {
      Activities = [new UserActivityProperties($"v{GlobalConsts.Version}", UserActivityType.Playing)]
    });

    await Task.Delay(-1);
    return 0;
  }
}
