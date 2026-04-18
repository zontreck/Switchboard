import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:switchboard/globalHelpers.dart';

class SBLoginPage extends StatefulWidget {
  SBLoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _loginState();
  }
}

class _loginState extends State<SBLoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String version = "";

  _loginState();

  @override
  void initState() {
    SwitchboardConsts.getPackageVersion().then((R) async {
      version = R;
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // try to load or refresh the authentication

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.blueGrey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    Text("System Switchboard"),
                    Text("Version ${version}"),
                    Text(""),
                  ],
                ),
              ),
              ListTile(
                title: Text("A B O U T"),
                leading: Icon(Icons.info_outline),
                onTap: () async {
                  Navigator.pushNamed(context, "/about");
                },
              ),
              ListTile(
                title: Text("L O G I N"),
                leading: Icon(Icons.login),
                onTap: () async {
                  Navigator.pushReplacementNamed(context, "/");
                },
              ),
              ListTile(
                title: Text("R E G I S T E R"),
                leading: Icon(Icons.app_registration),
                onTap: () async {
                  Navigator.pushNamed(context, "/register");
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(title: Text("System Switchboard")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              Container(
                alignment: AlignmentGeometry.center,
                child: Text("LOGIN", style: TextStyle(fontSize: 22)),
              ),
              Divider(thickness: 1),
              Text(
                "You must login to Switchboard in order to use this application and service.\n\n* NOTE: Switchboard is not yet in a usable state. If you are currently testing, you will have been given login permissions by the development team. \n\nUntil the app is usable, we are making every effort to make it possible to migrate Ocotocon data as painlessly as possible.\n\n* Interested in joining the team? Message zontreck on Discord.",
              ),
              Divider(),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Username",
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {},
        label: Text("Login"),
        icon: Icon(Icons.login_outlined),
      ),
    );
  }
}
/*
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
*/