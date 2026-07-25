using System.Reflection.PortableExecutable;
using DSharpPlus.Commands;
using DSharpPlus.Entities;

public class LinkCommand
{
    [Command("link")]
    public static async ValueTask ExecuteAsync(CommandContext ctx)
    {
        // This implementation is not intended to be the final version, it is a test to design the UI layout that pops up for the user.
        await ctx.DeferResponseAsync();

        // Show the user a pop up interaction, this will be so that we can generate a code and show it to the user.
        // The user is instructed to put in the code to the app, and return the confirmation code from their app to complete pairing.
        // Normally these codes will be generated on the backend. However, for this test, we will just supply the code: XXXXX-XX

        // The code is normally alphanumeric, uppercase only. As such, all user input will be forced to uppercase.

        DiscordModalBuilder mdl = new DiscordModalBuilder();
        mdl.WithTitle("Link To Switchboard");
        mdl.AddTextDisplay("Your linking code is: XXXXX-XX\nPlease input this code into the app, then provide the confirmation code to finish linking the Switchboard Proxy Bot.\n\n");
        mdl.AddTextInput(new DiscordTextInputComponent("confirm_code", max_length: 8, style: DiscordTextInputStyle.Short), "Enter the confirmation code from the app");

        DiscordMessageBuilder msg = new();
        msg.AddTextDisplayComponent("Click the provided button to initiate linking...");
        msg.AddActionRowComponent([new DiscordButtonComponent(DiscordButtonStyle.Primary, "start_link", "Link Switchboard")]);

        await ctx.EditResponseAsync(msg);
    }
}