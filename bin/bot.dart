// ignore_for_file: avoid_print

import 'dart:async';

import 'package:libac_dart/argparse/Args.dart';
import 'package:libac_dart/argparse/Parser.dart';
import 'package:mineral/mineral.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/bot/Providers.dart';

Future<int> main(List<String> args) async {
  MemoryState state = MemoryState();

  print("\n\n");

  print(
    "  ██████  █     █░ ██▓▄▄▄█████▓ ▄████▄   ██░ ██  ▄▄▄▄    ▒█████   ▄▄▄       ██▀███  ▓█████▄ ",
  );
  print(
    "▒██    ▒ ▓█░ █ ░█░▓██▒▓  ██▒ ▓▒▒██▀ ▀█  ▓██░ ██▒▓█████▄ ▒██▒  ██▒▒████▄    ▓██ ▒ ██▒▒██▀ ██▌",
  );
  print(
    "░ ▓██▄   ▒█░ █ ░█ ▒██▒▒ ▓██░ ▒░▒▓█    ▄ ▒██▀▀██░▒██▒ ▄██▒██░  ██▒▒██  ▀█▄  ▓██ ░▄█ ▒░██   █▌",
  );
  print(
    "  ▒   ██▒░█░ █ ░█ ░██░░ ▓██▓ ░ ▒▓▓▄ ▄██▒░▓█ ░██ ▒██░█▀  ▒██   ██░░██▄▄▄▄██ ▒██▀▀█▄  ░▓█▄   ▌",
  );
  print(
    "▒██████▒▒░░██▒██▓ ░██░  ▒██▒ ░ ▒ ▓███▀ ░░▓█▒░██▓░▓█  ▀█▓░ ████▓▒░ ▓█   ▓██▒░██▓ ▒██▒░▒████▓ ",
  );
  print(
    "▒ ▒▓▒ ▒ ░░ ▓░▒ ▒  ░▓    ▒ ░░   ░ ░▒ ▒  ░ ▒ ░░▒░▒░▒▓███▀▒░ ▒░▒░▒░  ▒▒   ▓▒█░░ ▒▓ ░▒▓░ ▒▒▓  ▒ ",
  );
  print(
    "░ ░▒  ░ ░  ▒ ░ ░   ▒ ░    ░      ░  ▒    ▒ ░▒░ ░▒░▒   ░   ░ ▒ ▒░   ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ▒  ▒ ",
  );
  print(
    "░  ░  ░    ░   ░   ▒ ░  ░      ░         ░  ░░ ░ ░    ░ ░ ░ ░ ▒    ░   ▒     ░░   ░  ░ ░  ░ ",
  );
  print(
    "      ░      ░     ░           ░ ░       ░  ░  ░ ░          ░ ░        ░  ░   ░        ░    ",
  );
  print(
    "                               ░                      ░                              ░      ",
  );

  print("\n\n");
  print("Switchboard Discord Bot");
  print("Version 0.3.1+0705261422\n\n");

  print("\n> Loading argument parser...");
  Arguments arg = ArgumentParser.parse(args);
  if (arg.hasArg("token")) {
    state.botToken = arg.getArg("token")!.getValue() as String;
  }
  if (arg.hasArg("botpsk")) {
    state.serverBotPSK = arg.getArg("botpsk")!.getValue() as String;
  }

  final client = ClientBuilder()
      .setIntent(Intent.allNonPrivileged)
      .registerProvider(BotProvider.new)
      .setToken(state.botToken)
      .build();

  await client.init();

  state.flushTimer!.cancel();
  state.terminating = true;
  return 0;
}
