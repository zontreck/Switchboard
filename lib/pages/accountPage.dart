import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:switchboard/globalHelpers.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountPage();
  }
}

class _AccountPage extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Switchboard")),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Text("Switchboard"),
                  FutureBuilder(
                    future: SwitchboardConsts.getPackageVersion(),
                    builder: (BTX, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text("Version v${snapshot.data}");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("S E T T I N G S"),
              subtitle: Text("Manage app settings"),
              leading: Icon(Icons.settings),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          // Add new alter!
        },
        label: Text("Alter"),
        icon: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Alters",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Front History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Account",
          ),
        ],
        onTap: (value) async {},
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(child: Column(children: [Divider()])),
      ),
    );
  }
}
