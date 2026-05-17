import 'package:flutter/material.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/sb.dart';

Future<void> main() async {
  MemoryState ms = MemoryState();

  ms.applicationVersion = "0.1.0+0517260938";

  runApp(Switchboard());
}
