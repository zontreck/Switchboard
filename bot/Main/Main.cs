
using LibSwitchboard;
using LibSwitchboard.Args;
using NetCord;
using NetCord.Gateway;
using NetCord.Logging;
using NetCord.Rest;
using NetCord.Services;
using NetCord.Services.ApplicationCommands;
using NetCord.Services.ComponentInteractions;

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

    var response = await NetworkInterface.GetServerVersion(GlobalConsts.OfficialServer);
    print($"Server version: {response.data.product}/{response.data.version}");
    var testResponse = await NetworkInterface.GetServerVersion(GlobalConsts.OfficialTestServer);
    print($"Test server version: {response.data.product}/{response.data.version}");

    print($"Switchboard Discord Bot Version: {GlobalConsts.Version}");

    // Two args need parsing: token, botpsk
    // Token is the Discord bot token.
    ArgumentBuilder bldr = new ArgumentBuilder();
    bldr.withStringArgument("token", required: true, value: "Discord Token");
    bldr.withBooleanArgument("docker", required: false, value: false);
    bldr.withBooleanArgument("help", required: false, value: false);

    Arguments defaults = bldr.Build();


    Arguments user = ArgumentParser.Parse(args);
    if (user.HasArg("help") || !user.HasArg("token"))
    {
      print(ArgumentHelpers.GenerateHelpMessage(new List<IArgument>(defaults.GetAllArguments()), "switchboard --token []  (OPTIONAL PARAMETERS)"));
      return 1;
    }
    MemoryState ms = MemoryState.Instance;
    ms.DiscordToken = user.GetArgument("token").GetValue() as string;
    if (user.HasArg("docker")) ms.DockerEnv = true;

    print("Loaded provided values...");
    print($"Data Directory: {DataStore.GetDataPath()}");
    if (ms.DockerEnv)
    {
      print(">> Running under docker");
    }

    GatewayClient client = new(new BotToken(ms.DiscordToken), new GatewayClientConfiguration()
    {
      Logger = new ConsoleLogger(),
      Intents = GatewayIntents.AllNonPrivileged | GatewayIntents.GuildUsers | GatewayIntents.MessageContent
    });

    var asm = typeof(Program).Assembly;

    ApplicationCommandService<ApplicationCommandContext> appCommands = new();
    ApplicationCommandService<UserCommandContext> userCommands = new();
    ComponentInteractionService<ModalInteractionContext> modalInteractions = new();
    ComponentInteractionService<ButtonInteractionContext> buttonInts = new();

    ApplicationCommandServiceManager manager = new();
    manager.AddService(appCommands);
    manager.AddService(userCommands);

    appCommands.AddModules(asm);
    userCommands.AddModules(asm);
    modalInteractions.AddModules(asm);
    buttonInts.AddModules(asm);


    client.InteractionCreate += async interaction =>
    {
      var result = await (interaction switch
      {
        SlashCommandInteraction sci => appCommands.ExecuteAsync(new ApplicationCommandContext(sci, client)),
        UserCommandInteraction uci => userCommands.ExecuteAsync(new UserCommandContext(uci, client)),
        ModalInteraction mi => modalInteractions.ExecuteAsync(new ModalInteractionContext(mi, client)),
        ButtonInteraction bi => buttonInts.ExecuteAsync(new ButtonInteractionContext(bi, client)),
        _ => throw new Exception("Invalid interaction")
      });


      if (result is not IFailResult res) return;

      try
      {
        await interaction.SendResponseAsync(InteractionCallback.Message(res.Message));
      }
      catch
      {

      }
    };

    await manager.RegisterCommandsAsync(client.Rest, client.Id);


    await client.StartAsync(new PresenceProperties(UserStatusType.Online)
    {
      Activities = [new UserActivityProperties($"v{GlobalConsts.Version}", UserActivityType.Playing)]
    });

    await Task.Delay(-1);
    return 0;
  }
}
