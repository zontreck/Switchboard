using LibSwitchboard;

namespace switchboard;

class Program
{
  static void print(string arg)
  {
    Console.WriteLine(arg);
  }
  static async Task Main(string[] args)
  {

    print("  ██████  █     █░ ██▓▄▄▄█████▓ ▄████▄   ██░ ██  ▄▄▄▄    ▒█████   ▄▄▄       ██▀███  ▓█████▄ ");
    print("▒██    ▒ ▓█░ █ ░█░▓██▒▓  ██▒ ▓▒▒██▀ ▀█  ▓██░ ██▒▓█████▄ ▒██▒  ██▒▒████▄    ▓██ ▒ ██▒▒██▀ ██▌");
    print(
      "░ ▓██▄   ▒█░ █ ░█ ▒██▒▒ ▓██░ ▒░▒▓█    ▄ ▒██▀▀██░▒██▒ ▄██▒██░  ██▒▒██  ▀█▄  ▓██ ░▄█ ▒░██   █▌"
    );
    print(
      "  ▒   ██▒░█░ █ ░█ ░██░░ ▓██▓ ░ ▒▓▓▄ ▄██▒░▓█ ░██ ▒██░█▀  ▒██   ██░░██▄▄▄▄██ ▒██▀▀█▄  ░▓█▄   ▌"
    );
    print(
      "▒██████▒▒░░██▒██▓ ░██░  ▒██▒ ░ ▒ ▓███▀ ░░▓█▒░██▓░▓█  ▀█▓░ ████▓▒░ ▓█   ▓██▒░██▓ ▒██▒░▒████▓ "
    );
    print(
      "▒ ▒▓▒ ▒ ░░ ▓░▒ ▒  ░▓    ▒ ░░   ░ ░▒ ▒  ░ ▒ ░░▒░▒░▒▓███▀▒░ ▒░▒░▒░  ▒▒   ▓▒█░░ ▒▓ ░▒▓░ ▒▒▓  ▒ "
    );
    print(
      "░ ░▒  ░ ░  ▒ ░ ░   ▒ ░    ░      ░  ▒    ▒ ░▒░ ░▒░▒   ░   ░ ▒ ▒░   ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ▒  ▒ "
    );
    print(
      "░  ░  ░    ░   ░   ▒ ░  ░      ░         ░  ░░ ░ ░    ░ ░ ░ ░ ▒    ░   ▒     ░░   ░  ░ ░  ░ "
    );
    print(
      "      ░      ░     ░           ░ ░       ░  ░  ░ ░          ░ ░        ░  ░   ░        ░    "
    );
    print(
      "                               ░                      ░                              ░      "
    );

    print("\n\n");

    var response = await NetworkInterface.GetServerVersion();
    print($"Server version: {response.data.product}/{response.data.version}");
    print("Switchboard Discord Bot Version: 0.4.0+0722261057");

    // Two args need parsing: token, botpsk
    // PSK is used for administrative actions. 
    // Token is the Discord bot token.
  }
}
