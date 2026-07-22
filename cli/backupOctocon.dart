import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:switchboard/dart/octocon_format.dart';

Future<int> main(List<String> args) async {
  // We need to load the file in the args, and save both it, and the Octocon backup file.
  String file = args.join(" ");
  if (file == "") {
    file = "octocon_tara.json";
  }
  File handle = File(file);

  print("> Reading octocon export located in file: $file\n");

  String rawContents = await handle.readAsString();
  OctoconData data = OctoconData.fromJson(rawContents);

  print("Creating output directory tree...\n\n");
  Directory outputs = Directory("output");
  if (outputs.existsSync()) {
    await outputs.delete(recursive: true);
  }
  await outputs.create();

  print("> Writing backup file\n");
  File js = File("output/octo.json");
  await js.writeAsString(json.encode(data.toJson()));

  Directory imgs = Directory("output/avatars");
  await imgs.create();

  Dio dio = Dio();

  for (var alter in data.alters) {
    print("> Processing alter ${alter.name}\n");
    print("> Downloading image...\n");
    Directory avatarImg = Directory("output/avatars/${alter.id}");

    if (alter.avatarURL == "") continue;

    await avatarImg.create(recursive: true);
    await dio.download(
      alter.avatarURL,
      "output/avatars/${alter.id}/${alter.id}.webp",
    );
  }

  print("> DONE\n\n");

  return 0;
}
