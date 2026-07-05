import 'package:mineral/mineral.dart';
import 'package:switchboard/dart/bot/Commands.dart';

class BotProvider extends Provider {
  Client _client;

  BotProvider(this._client) {
    _client..register<LinkCommand>(LinkCommand.new);
  }
}
