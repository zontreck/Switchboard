import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libac_dart/utils/Hashing.dart';
import 'package:switchboard/dart/storage.dart';

class SBRegisterPage extends StatefulWidget {
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
      appBar: AppBar(title: Text("System Switchboard")),
      floatingActionButton:
          (agreeToPrivacy &&
              agreeToTOS &&
              usernameController.text.isNotEmpty &&
              passwordController.text.isNotEmpty &&
              passwordConfirmController.text.isNotEmpty &&
              passwordController.text == passwordConfirmController.text)
          ? ElevatedButton.icon(
              onPressed: () async {
                // do register
                S2CUserPacket usrPkt = await NetworkInterface.putNewUser(
                  usernameController.text,
                  passwordController.text,
                );

                if (usrPkt.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User Account Created!")),
                  );
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
            )
          : null,
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: AlignmentGeometry.center,
                child: Text("REGISTER", style: TextStyle(fontSize: 22)),
              ),
              Divider(),
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

              SizedBox(height: 25),
              Row(
                children: [
                  Checkbox(
                    value: agreeToPrivacy,
                    onChanged: (B) async {
                      agreeToPrivacy = B ?? false;
                      setState(() {});
                    },
                  ),
                  Text("I agree to the Privacy Policy"),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: agreeToTOS,
                    onChanged: (B) async {
                      agreeToTOS = B ?? false;
                      setState(() {});
                    },
                  ),
                  Text("I agree to the Terms of Service"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
