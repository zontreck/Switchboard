
using NetCord.Services.ApplicationCommands;

[SlashCommand("server", "API Server Management")]
public class ServerCommandModule : ApplicationCommandModule<ApplicationCommandContext>
{
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