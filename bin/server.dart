// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:libac_dart/argparse/Args.dart';
import 'package:libac_dart/argparse/Parser.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/octocon_format.dart';

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
  print("Switchboard Server");
  print("Version 1.0.032226+1642\n\n");

  print("\n> Loading argument parser...");
  Arguments arg = ArgumentParser.parse(args);
  if (arg.hasArg("sql")) {
    state.useSQL = arg.getBool("sql");
  }

  if (arg.hasArg("mdb_host")) {
    state.mariaDBHost = arg.getArg("mdb_host")!.getValue() as String;
  }

  if (arg.hasArg("mdb_user")) {
    state.mariaDBUser = arg.getArg("mdb_user")!.getValue() as String;
  }

  if (arg.hasArg("mdb_pass")) {
    state.mariaDBPass = arg.getArg("mdb_pass")!.getValue() as String;
  }

  if (arg.hasArg("mdb_db")) {
    state.mariaDBName = arg.getArg("mdb_db")!.getValue() as String;
  }

  if (arg.hasArg("token")) {
    state.botToken = arg.getArg("token")!.getValue() as String;
  }

  // Determine storage backend
  if (!state.useSQL) {
    print("> Data Storage Backend Selected!");
    print(">> NBT");

    //storage.backend = StorageNBT();

    // Schedule the repeating task
    state.flushTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (state.terminating) {
        timer.cancel();
      }
    });
  } else {
    print("> Storage will use SQL");
    print(">> SQL");

    //storage.backend = StorageSQL();
  }

  print("> Searching for test.json");
  File testFile = File("test.json");

  if (testFile.existsSync()) {
    print("Attempting to import test octocon data to switchboard format...");

    String dataJs = testFile.readAsStringSync();
    OctoconData data = OctoconData.fromJson(dataJs);

    print(">> SAVING USER DATA TO PERSISTENT STORAGE");
    await data.commitToStorage();
  }

  state.flushTimer!.cancel();
  state.terminating = true;
  return 0;
}
