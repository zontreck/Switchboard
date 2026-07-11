import 'package:flutter/material.dart';
import 'package:switchboard/dart/storage.dart';

class SBRegisterPage extends StatefulWidget {
  const SBRegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SBRegister();
  }
}

class _SBRegister extends State<SBRegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  bool agreeToPrivacy = false;
  bool agreeToTOS = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("REGISTER", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          if (!((usernameController.text.isNotEmpty &&
              passwordController.text.isNotEmpty &&
              passwordConfirmController.text.isNotEmpty &&
              passwordController.text == passwordConfirmController.text))) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "ERROR: You must fill out the username field, and ensure both passwords match.",
                ),
              ),
            );
            return;
          }
          // do register
          S2CLazyResponse usrPkt = await NetworkInterface.putNewUser(
            usernameController.text,
            passwordController.text,
          );

          if (usrPkt.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("User Account Created!")));
            Navigator.pop(context);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("ERROR ${usrPkt.reason}"),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        label: Text("Register Account"),
        icon: Icon(Icons.app_registration_rounded),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "NOTE: By registering an account with us, you must agree to both our Terms of Service, as well as our Privacy Policy. We promise, the terms of both are fairly simple, and respect your rights as a user of our product.",
              ),

              Divider(),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Username",
                ),
              ),
              SizedBox(height: 10),

              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),

              TextField(
                controller: passwordConfirmController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password Confirmation",
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
