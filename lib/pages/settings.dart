import 'package:flutter/material.dart';
import 'package:switchboard/globalHelpers.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _settings();
  }
}

class _settings extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("SETTINGS", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Text("Ads", style: TextStyle(fontSize: 20)),
                    Divider(),
                  ],
                ),
              ),
              Card(
                elevation: 16,
                child: Column(
                  children: [
                    FutureBuilder(
                      future: getAdsOptIn(),
                      builder: (bldr, snap) {
                        if (!snap.hasData) {
                          return CircularProgressIndicator();
                        } else {
                          return CheckboxListTile(
                            value: snap.data ?? false,
                            onChanged: (B) {
                              setAdsSupport(B ?? false);
                              setState(() {});
                            },
                            title: Text("Enable Ads"),
                            subtitle: Text(
                              "Any ads are still controlled by the Ad settings menu below. You have full control.",
                            ),
                          );
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Ad Settings"),
                      leading: Icon(Icons.ad_units),
                      trailing: Icon(Icons.forward),
                      subtitle: Text("Configure settings related to ads"),
                      onTap: () async {
                        pageChanged();
                        await Navigator.pushNamed(context, "/settings/ads");
                        pageChanged();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Center(child: Text("Account", style: TextStyle(fontSize: 20))),
              Divider(),
              Card(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Account Settings"),
                        subtitle: Text(
                          "View and manage all account related settings",
                        ),
                        trailing: Icon(Icons.forward),
                        leading: Icon(Icons.settings),
                        onTap: () async {
                          pageChanged();
                          await Navigator.pushNamed(
                            context,
                            "/settings/account",
                          );
                          pageChanged();

                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
