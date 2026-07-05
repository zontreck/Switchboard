import 'dart:async';

import 'package:mineral/mineral.dart';

class LinkCommand implements CommandDeclaration {
  Future<void> handle(ServerCommandContext ctx, CommandOptions options) async {
    final code = options.require<String>('code');
    await ctx.interaction.reply(builder: MessageBuilder.text("Please wait..."));
  }

  @override
  CommandDeclarationBuilder build() {
    return CommandDeclarationBuilder()
      ..setName("link")
      ..setDescription("Initiate linking of your discord account")
      ..addOption(
        Option.string(
          name: "code",
          description: "Linking authorization code",
          required: true,
        ),
      )
      ..setHandle(handle);
  }
}
