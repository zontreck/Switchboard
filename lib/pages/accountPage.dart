import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountPage();
  }
}

class _AccountPage extends State<AccountPage> {
  int _index = 0;
  MemoryState ms = MemoryState();

  Widget getPageForIndex() {
    switch (_index) {
      case 0:
        {
          return AltersPage();
        }
      case 1:
        {
          return FrontingPage();
        }
      case 2:
        {
          return FrontHistoryPage();
        }
    }

    return AltersPage();
  }

  Widget? getActionButton() {
    if (_index == 0) {
      return ElevatedButton.icon(
        onPressed: () async {
          // Add new alter!
        },
        label: Text("Alter"),
        icon: Icon(Icons.add),
      );
    }

    return null;
  }

  @override
  void initState() {
    getAppSettings();

    super.initState();
  }

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
              onTap: () async {
                await Navigator.pushNamed(context, "/account/settings");
                setState(() {});
              },
            ),
          ],
        ),
      ),
      floatingActionButton: getActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Alters",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2),
            label: "Fronting",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
        onTap: (value) async {
          _index = value;
          setState(() {});
        },
        selectedItemColor: getNavSelColor(),
        unselectedItemColor: getNavUnselColor(),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(children: [Divider(), getPageForIndex()]),
        ),
      ),
    );
  }
}

class AltersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _alters();
  }
}

class _alters extends State<AltersPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
        
      ],
    );
  }
}

class FrontingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _fronting();
  }
}

class _fronting extends State<FrontingPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FrontHistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _history();
  }
}

class _history extends State<FrontHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
