import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_setup.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/website/about.dart';
import 'package:switchboard/pages/website/faq.dart';
import 'package:switchboard/pages/website/features.dart';
import 'package:switchboard/pages/website/home.dart';
import 'package:switchboard/pages/website/support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  MemoryState();
  setGlowColors(getPrideColors());

  runApp(LiquidGlassWidgets.wrap(child: SwitchboardWeb()));
}

class SwitchboardWeb extends StatefulWidget {
  static void Function() rebuild = () {
    print("Dummy rebuild function invoked too soon");
  };

  @override
  State<StatefulWidget> createState() {
    return _sbweb();
  }
}

class _sbweb extends State<SwitchboardWeb> {
  void rebuild() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    loadVersionCode();
    super.didChangeDependencies();
  }

  Future<void> loadVersionCode() async {
    MemoryState ms = MemoryState();
    ms.applicationVersion = await SwitchboardConsts.getPackageVersion();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SwitchboardWeb.rebuild = rebuild;
    return MaterialApp(
      theme: ThemeData.dark(), // hardcoded only for the main website
      title: "Switchboard",
      routes: {
        "/": (ctx) => SBWebHome(),
        "/features": (ctx) => SBWebFeatures(),
        "/support": (ctx) => SBWebSupportUs(),
        "/faq": (ctx) => SBWebFAQ(),
        "/about": (ctx) => SBWebAboutUs(),
      },
    );
  }
}
