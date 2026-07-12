import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/globalHelpers.dart';

class AdSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _adsetting();
  }
}

class _adsetting extends State<AdSettings> {
  TextEditingController navCountController = TextEditingController();

  void updateAdCount() {
    if (navCountController.text.isEmpty) {
      navCountController.text = "0";
    }

    int sanitized = int.parse(navCountController.text);
    navCountController.text = "$sanitized";

    MemoryState.A.adSettings.navCount = sanitized;

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    navCountController.text = "${MemoryState.A.adSettings.navCount}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("ADS", style: TextStyle(fontSize: 20)),
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
              Text(
                "NOTE: Ads cannot be played more frequently than 10 times every 2 minutes. This is intentional, so that the app itself does not become so unpleasant to use, despite the optional nature of these settings.",
                style: TextStyle(fontSize: 16),
              ),
              Divider(),
              SizedBox(height: 25),
              Text("Navigation", style: TextStyle(fontSize: 18)),
              Divider(),
              Card(
                elevation: 16,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text("Ads on Navigation"),
                        subtitle: Text(
                          "Turning this on will display an ad after [X] number of page navigations. This frequency can be customized.",
                        ),
                        value: MemoryState.A.adSettings.onNavigate,
                        onChanged: (V) {
                          MemoryState.A.adSettings.onNavigate = V ?? false;

                          setState(() {});
                        },
                      ),
                      SizedBox(height: 25),
                      TextField(
                        controller: navCountController,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();

                          updateAdCount();
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          hintText: "Page Nav count before an ad plays",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          updateAdCount();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text("Stats", style: TextStyle(fontSize: 20)),
              Divider(),
              Card(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Text(
                        "Pages Navigated: ${MemoryState.A.adSettings.getPageViews()}",
                        style: TextStyle(fontSize: 18),
                      ),
                      ListTile(
                        title: Text("Reset Page Navigation Count"),
                        subtitle: Text(
                          "Tap here to reset the page navigation counter",
                        ),
                        onTap: () async {
                          MemoryState.A.adSettings.resetPageCounter();
                          setState(() {});
                        },
                        leading: Icon(Icons.clear),
                      ),

                      Divider(),

                      ListTile(
                        title: Text("Play an Ad"),
                        subtitle: Text(
                          "Immediately request to play a full screen ad.\nYou can use this if you do not want automatic ads, but still want to support the app.",
                        ),
                        leading: Icon(Icons.movie),
                        onTap: () async {
                          await requestAd(
                            (ad) {
                              ad.show();
                            },
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to load ad")),
                              );
                            },
                          );
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
