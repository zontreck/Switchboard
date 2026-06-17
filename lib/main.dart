import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_setup.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/sb.dart';

Future<void> main() async {
  MemoryState ms = MemoryState();
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  ms.applicationVersion = "0.1.0+0617260921";

  runApp(LiquidGlassWidgets.wrap(child: Switchboard()));
}
