

using NetCord;
using NetCord.Rest;
using NetCord.Services.ApplicationCommands;
using NetCord.Services.ComponentInteractions;

namespace switchboard.Commands;

public class LinkCommandModule : ApplicationCommandModule<ApplicationCommandContext>
{
    [SlashCommand("link", "Initiate the process of linking to Switchboard")]
    public async Task Link()
    {
        Guid guid = Guid.NewGuid();
        string idCode = guid.ToString().Substring(0, 6);
        guid = Guid.NewGuid();

        // TODO: Send the linking code to the Switchboard Backend, which the app will validate against.
        var modal = new ModalProperties($"linkmodal", "Link Switchboard Account");
        modal.AddComponents(new TextDisplayProperties($"Please NOTE: Do not share any Switchboard Codes with others, it will weaken the security of your account.\nYour code is: {idCode}\n\nInput this code into the Switchboard App to receive the confirmation code."), new LabelProperties("Confirmation Code", new TextInputProperties("tip:linkconf", TextInputStyle.Short)
        {
            Required = true,
            Placeholder = "0F0F0F"
        }));

        await Context.Interaction.SendResponseAsync(InteractionCallback.Modal(modal));

    }
}

public class LinkModal : ComponentInteractionModule<ModalInteractionContext>
{
    [ComponentInteraction("linkmodal")]
    public async Task HandleModal(string id)
    {
        // Verify the modal ID later...
        // Verify it exists on server, verify that the modal belongs to the discord user, then verify the confirmation code

        await Context.Interaction.SendResponseAsync(InteractionCallback.Message(new InteractionMessageProperties()
        {
            Content = "NOTE: This feature is not yet fully implemented.\nSuccess, your Discord account has been linked to Switchboard. You can now use the Proxy functionality.",
            Flags = MessageFlags.Ephemeral
        }));
    }
}
