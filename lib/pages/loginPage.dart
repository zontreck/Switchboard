import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:switchboard/dart/storage.dart';
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

  _loginState();

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
                    FutureBuilder(
                      future: SwitchboardConsts.getPackageVersion(),
                      builder: (BCTX, AsyncSnapshot<String> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        } else {
                          return Text("Version ${snapshot.data}");
                        }
                      },
                    ),
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
                title: Text("R E G I S T E R"),
                leading: Icon(Icons.app_registration),
                onTap: () async {
                  Navigator.pushNamed(context, "/register");
                },
              ),
              ListTile(
                title: Text("P R I V A C Y  P O L I C Y"),
                leading: Icon(Icons.privacy_tip),
                onTap: () {
                  Navigator.pushNamed(context, "/privacy");
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(title: Text("Switchboard")),
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
        onPressed: () async {
          // Perform Login
          FocusManager.instance.primaryFocus?.unfocus();

          S2CAuthenticationResponse authReply =
              await NetworkInterface.authenticate(
                usernameController.text,
                passwordController.text,
              );

          if (!authReply.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "ERROR [${authReply.id}] Login failed for reason:\n${authReply.reason}",
                ),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (B) => AlertDialog(
                title: Text("Thanks!"),
                content: Text(
                  "The app is still in active development, your login succeeded, but there is nothing to do yet.\n\nThis build is mostly a build to get feedback about our UI design and what language changes need to be made to the various text elements.",
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Dismiss"),
                  ),
                ],
              ),
            );
          }
        },
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