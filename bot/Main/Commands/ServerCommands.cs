
using NetCord.Rest;
using NetCord.Services;
using NetCord.Services.ApplicationCommands;

namespace switchboard.Commands;

[SlashCommand("server", "API Server Management")]
public class ServerCommandModule : ApplicationCommandModule<ApplicationCommandContext>
{
    /// <summary>
    /// Global Server Command Module - Only accessible to app developers. Those active developers are listed in the Global Contants file.
    /// </summary>
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

    /// <summary>
    /// User Server Commands module - updates the preferences for the invoking user only.
    /// </summary>
    [SubSlashCommand("user", "Update or set your own Switchboard API URL")]
    public class USCModule : ApplicationCommandModule<ApplicationCommandContext>
    {
        [SubSlashCommand("clear", "Go back to the default server settings")]
        public async Task clear()
        {
            // Reset the server url for the command sender to defaults
            if (DataStore.Memory.UserServerPreference.ContainsKey(Context.User.Id))
            {
                DataStore.Memory.UserServerPreference.Remove(Context.User.Id);
                DataStore.Memory.saveToFile();
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
                {
                    Content = "Your server preference has been reverted to the default server url.",
                    Flags = NetCord.MessageFlags.Ephemeral
                }));
            }
            else
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
                {
                    Content = "Your server preference is already the default.",
                    Flags = NetCord.MessageFlags.Ephemeral
                }));
            }
        }

        [SubSlashCommand("official", "Set your preferred server to the official server.")]
        public async Task official()
        {
            DataStore.Memory.UserServerPreference[Context.User.Id] = GlobalConsts.OfficialServer;
            DataStore.Memory.saveToFile();
            await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
            {
                Content = "Your server preference has been updated to the Official Server",
                Flags = NetCord.MessageFlags.Ephemeral
            }));
        }

        [SubSlashCommand("test", "Set your preferred server to the official test server.")]
        public async Task test()
        {
            DataStore.Memory.UserServerPreference[Context.User.Id] = GlobalConsts.OfficialTestServer;
            DataStore.Memory.saveToFile();
            await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
            {
                Content = "Your server preference has been updated to the Official Test Server",
                Flags = NetCord.MessageFlags.Ephemeral
            }));
        }

        [SubSlashCommand("custom", "Set your preferred server to a custom server.")]
        public async Task custom(string url)
        {
            DataStore.Memory.UserServerPreference[Context.User.Id] = url;
            DataStore.Memory.saveToFile();
            await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
            {
                Content = "Your server preference has been updated to a custom server.\n# Disclaimer\n\nWe **cannot** support custom features on a custom server without those features having been sent to us for implementation. If you are the owner of this custom server, please send us your changes for integration.",
                Flags = NetCord.MessageFlags.Ephemeral
            }));
        }
    }

    /// <summary>
    /// Discord Guild Server Command Module - updates the preferences for a entire guild. Can only be used by somebody with the manage server permission.
    /// </summary>
    [RequireUserPermissions<ApplicationCommandContext>(NetCord.Permissions.ManageGuild)]
    [SubSlashCommand("guild", "Update or set guild preferred server overrides for the API Server")]
    public class DGSCModule : ApplicationCommandModule<ApplicationCommandContext>
    {
        [RequireUserPermissions<ApplicationCommandContext>(NetCord.Permissions.ManageGuild)]
        [SubSlashCommand("clear", "Remove the guild API server preference")]
        public async Task clear()
        {
            if (DataStore.Memory.GuildServerPreference.ContainsKey(Context.Guild?.Id ?? 0))
            {
                DataStore.Memory.GuildServerPreference.Remove(Context.Guild.Id);
                DataStore.Memory.saveToFile();
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("Your discord server's preferred Switchboard API Server has been cleared. You are now back on the official defaults."));
            }
            else
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("Your discord server is already using the official default server."));
            }
        }

        [RequireUserPermissions<ApplicationCommandContext>(NetCord.Permissions.ManageGuild)]
        [SubSlashCommand("official", "Update or set guild preference for API Server")]
        public async Task official()
        {
            if (Context.Guild == null)
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("This command must be invoked from within a discord server that you have the Manage Server permission in."));
                return;
            }
            DataStore.Memory.GuildServerPreference[Context.Guild.Id] = GlobalConsts.OfficialServer;
            DataStore.Memory.saveToFile();
            await Context.Interaction.SendResponseAsync(InteractionCallback.Message("Your discord server's preferred Switchboard API Server has been set to the official server."));
        }

        [RequireUserPermissions<ApplicationCommandContext>(NetCord.Permissions.ManageGuild)]
        [SubSlashCommand("test", "Update or set guild preference for API Server")]
        public async Task test()
        {
            if (Context.Guild == null)
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("This command must be invoked from within a discord server that you have the Manage Server permission in."));
                return;
            }
            DataStore.Memory.GuildServerPreference[Context.Guild.Id] = GlobalConsts.OfficialTestServer;
            DataStore.Memory.saveToFile();
            await Context.Interaction.SendResponseAsync(InteractionCallback.Message("Your discord server's preferred Switchboard API Server has been set to the official test server."));
        }

        [RequireUserPermissions<ApplicationCommandContext>(NetCord.Permissions.ManageGuild)]
        [SubSlashCommand("custom", "Update or set guild preference for API Server")]
        public async Task custom(string url)
        {
            if (Context.Guild == null)
            {
                await Context.Interaction.SendResponseAsync(InteractionCallback.Message("This command must be invoked from within a discord server that you have the Manage Server permission in."));
                return;
            }
            DataStore.Memory.GuildServerPreference[Context.Guild.Id] = url;
            DataStore.Memory.saveToFile();
            await Context.Interaction.SendResponseAsync(InteractionCallback.Message("Your discord server's preferred Switchboard API Server has been set to the official test server."));
        }
    }
}