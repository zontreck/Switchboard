
using NetCord.Rest;
using NetCord.Services;
using NetCord.Services.ApplicationCommands;
using switchboard;

[SlashCommand("server", "API Server Management")]
public class ServerCommandModule : ApplicationCommandModule<ApplicationCommandContext>
{
    [SubSlashCommand("global", "Update or set global bot settings.")]
    public class GSCModule : ApplicationCommandModule<ApplicationCommandContext>
    {
        [SubSlashCommand("clear", "Go back to defaults")]
        public async Task clear()
        {
            if (GlobalConsts.DeveloperIDs.Contains(Context.User.Id))
            {
                DataStore.Memory.GlobalURL = GlobalConsts.OfficialServer;
                DataStore.Memory.saveToFile();

                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("The default server URL has been set to the Official Server"));
            }
            else
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
                {
                    Content = "You do not have access to this command. It is restricted to developers of the bot.",
                    Flags = NetCord.MessageFlags.Ephemeral
                }));
            }
        }
        [SubSlashCommand("official", "Set server url to official")]
        public async Task official()
        {
            if (GlobalConsts.DeveloperIDs.Contains(Context.User.Id))
            {
                DataStore.Memory.GlobalURL = GlobalConsts.OfficialServer;
                DataStore.Memory.saveToFile();

                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("The default server URL has been set to the Official Server"));
            }
            else
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
                {
                    Content = "You do not have access to this command. It is restricted to developers of the bot.",
                    Flags = NetCord.MessageFlags.Ephemeral
                }));
            }
        }
        [SubSlashCommand("test", "Set server url to testing")]
        public async Task test()
        {
            if (GlobalConsts.DeveloperIDs.Contains(Context.User.Id))
            {
                DataStore.Memory.GlobalURL = GlobalConsts.OfficialTestServer;
                DataStore.Memory.saveToFile();

                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("The default server URL has been set to the Official Testing Server"));
            }
            else
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
                {
                    Content = "You do not have access to this command. It is restricted to developers of the bot.",
                    Flags = NetCord.MessageFlags.Ephemeral
                }));
            }
        }
    }
    [SubSlashCommand("user", "Update or set your own Switchboard API URL")]
    public class USCModule : ApplicationCommandModule<ApplicationCommandContext>
    {
        [SubSlashCommand("clear", "Go back to the default server settings")]
        public async Task clear()
        {
            // Reset the server url for the command sender to defaults

        }
    }
}