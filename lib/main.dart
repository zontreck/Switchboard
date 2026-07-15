import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:liquid_glass_widgets/liquid_glass_setup.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/sb.dart';

Future<void> main() async {
  MemoryState ms = MemoryState();
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  ms.applicationVersion = "0.3.1+0708261728";

  runApp(Phoenix(child: LiquidGlassWidgets.wrap(child: Switchboard())));
}
