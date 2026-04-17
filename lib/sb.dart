import 'package:flutter/material.dart';
import 'package:libacflutter/Constants.dart';

class Switchboard extends StatelessWidget {
  const Switchboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Switchboard",
      theme: ThemeData.dark(),
      routes: {"/": (ctx) => SBHomeTest()},
    );
  }
}

class SBLoginPage extends StatefulWidget {
  SBLoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _loginState();
  }
}

class _loginState extends State<SBLoginPage> {
  _loginState();

  @override
  void didChangeDependencies() {
    // we must try to load or refresh the authentication

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class SBHomeTest extends StatelessWidget {
  const SBHomeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("System Switchboard"),
        backgroundColor: LibACFlutterConstants.TITLEBAR_COLOR,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: ListView(
          children: [
            Dismissible(
              key: Key("K1"),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {},
              confirmDismiss: (direction) async {
                return false;
              },
              background: Container(
                color: Colors.lightBlueAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_circle_up_rounded),
              ),
              child: ListTile(
                title: Text("Test 1"),
                shape: Border.all(color: Colors.white),
              ),
            ),
            Text(""),
            Dismissible(
              key: Key("K2"),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {},
              confirmDismiss: (direction) async {
                return false;
              },
              background: Container(
                color: Colors.lightBlueAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_circle_up_rounded),
              ),
              child: ListTile(
                title: Text("Test 2"),
                shape: Border.all(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
