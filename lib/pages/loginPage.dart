import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';

class SBLoginPage extends StatefulWidget {
  const SBLoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _loginState();
  }
}

class _loginState extends State<SBLoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  MemoryState ms = MemoryState();

  _loginState();

  @override
  void didChangeDependencies() {
    tryAuthToken();

    super.didChangeDependencies();
  }

  Future<void> tryAuthToken() async {
    // try to load or refresh the authentication
    MemoryState ms = MemoryState();
    ms.applicationVersion = await getPackageVersion();
    await getApplicationFont();
    try {
      await MobileAds.instance.initialize();
    } catch (E) {}

    getAuthToken().then((S) async {
      if (S == "") {
        // Not logged in, do nothing, just let the user log in.

        await getAppSettings();
        flushImageCaches(); // Just to quickly get it out of the way.
        setState(() {});

        if (ms.rememberMe) {
          // Obtain a new authentication token. Prefill the username and password fields with garbage.
          usernameController.text = "***********";
          passwordController.text = "************";
          setState(() {});

          S2CAuthenticationResponse auth = await NetworkInterface.authenticate(
            ms.username,
            ms.password,
          );
          if (!auth.success) {
            // password changed?
            // erase remembered settings, show snackbar Alert
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: Text(
                  "ALERT: Login failed. The stored username and password were denied by the server. If you believe this is an error, please contact the administrator. To try again, fully close and reopen the app.\nRequest ID: ${auth.id}",
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearMaterialBanners();
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            );

            usernameController.text = "";
            passwordController.text = "";
            setState(() {});
          } else {
            ms.authenticationToken = auth.data.token!;
            await setAuthToken(ms.authenticationToken);

            tryAuthToken();
          }
        }
      } else {
        usernameController.text = "******";
        passwordController.text = "************";
        flushImageCaches(); // Just to quickly get it out of the way.
        setState(() {});

        await getAppSettings();
        setState(() {});

        S2CAuthenticationRefreshResponse refresh =
            await NetworkInterface.refreshAuth();
        if (refresh.success) {
          setAuthToken(refresh.data.token!);
        } else {
          usernameController.text = "";
          passwordController.text = "";
          await setAuthToken("");
          setState(() {});
          if (ms.rememberMe) {
            tryAuthToken(); // Attempt to get a new token using the stored credentials, now that the auth token has been removed.
          }

          return;
        }

        var userReply = await NetworkInterface.getUser("");
        MemoryState.A.currentUser = userReply.data!;

        setState(() {});
        // Use new token and move on to the next screen.
        Navigator.pushReplacementNamed(context, "/account");
      }
    });
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
                      future: getPackageVersion(),
                      builder: (BCTX, AsyncSnapshot<String> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        } else {
                          return Text("Version ${snapshot.data}");
                        }
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text("About"),
                leading: Icon(Icons.info_outline),
                onTap: () async {
                  Navigator.pushNamed(context, "/about");
                },
              ),
              ListTile(
                title: Text("Register"),
                leading: Icon(Icons.app_registration),
                onTap: () async {
                  Navigator.pushNamed(context, "/register");
                },
              ),
              ListTile(
                title: Text("Privacy Policy"),
                leading: Icon(Icons.privacy_tip),
                onTap: () {
                  Navigator.pushNamed(context, "/privacy");
                },
              ),
              ListTile(
                title: Text("Terms of Service"),
                leading: Icon(Icons.privacy_tip),
                onTap: () {
                  Navigator.pushNamed(context, "/tos");
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("LOGIN", style: TextStyle(fontSize: 22)),

              Divider(thickness: 1),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              Text(
                "You must login to Switchboard in order to use this application and service.\n\n* NOTE: Switchboard is not yet in a usable state. If you are currently testing, you will have been given login permissions by the development team. \n\nUntil the app is usable, we are making every effort to make it possible to migrate Octocon data as painlessly as possible.\n\n* Interested in joining the team? Message zontreck on Discord.",
              ),

              FutureBuilder(
                future: NetworkInterface.getServerVersion(),
                builder: (bldr, snap) {
                  if (!snap.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    return Text(
                      "\nServer Version: ${snap.data!.data.product} / v${snap.data!.data.version}\nClient Version: ${ms.applicationVersion}",
                    );
                  }
                },
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
              SizedBox(height: 16),
              CheckboxListTile(
                value: ms.rememberMe,
                title: Text("Remember Me"),
                subtitle: Text(
                  "Remembers your username and password to sign you in automatically.\n(Caution)",
                ),
                onChanged: (B) async {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (B == null || ms.rememberMe) {
                    ms.rememberMe = false;
                    ms.username = "";
                    ms.password = "";

                    await setAppSettings();

                    setState(() {});
                  } else {
                    var reply = await showDialog(
                      context: context,
                      builder: (BLDR) {
                        return AlertDialog(
                          title: Text("Are you sure?"),
                          content: Text(
                            "This action will reduce the security level of the app considerably, as your username will be saved, and so will the password. We strongly advise you not to do this. If less privacy may be a security risk for you.\nNOTE: The app already tries to remember you. It does save your authentication token. The token expires every 24 hours, but if you open the app every 12 hours or so, it is not an issue.\n\n**NOTE: We may add a background service in the future to automatically refresh the token without user interaction.",
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context, true);
                              },
                              child: Text("Yes"),
                            ),
                          ],
                        );
                      },
                    );
                    bool A = false;

                    if (reply == null) {
                      A = false;
                    } else {
                      A = reply as bool;
                    }
                    ms.rememberMe = A;
                    setAppSettings();

                    setState(() {});
                  }
                },
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
            MemoryState ms = MemoryState();
            ms.authenticationToken = authReply.data.token!;
            if (ms.rememberMe) {
              ms.username = usernameController.text;
              ms.password = passwordController.text;
            }

            await setAuthToken(ms.authenticationToken);

            getAuthToken().then((S) async {
              if (S == "") {
                // Not logged in, do nothing, just let the user log in.
              } else {
                usernameController.text = "******";
                passwordController.text = "************";
                setState(() {});

                await getAppSettings();
                setState(() {});

                var userReply = await NetworkInterface.getUser("");
                MemoryState.A.currentUser = userReply.data!;

                // Use new token and move on to the next screen.
                Navigator.pushReplacementNamed(context, "/account");
              }
            });
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