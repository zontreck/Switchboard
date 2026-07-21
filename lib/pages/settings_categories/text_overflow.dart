import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';

class TextOverflowSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _txtover();
  }
}

class _txtover extends State<TextOverflowSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Text Overflow Settings", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Alter Widgets", style: TextStyle(fontSize: 20)),
              ),
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      AlterWidget(
                        alterID: UUID_ZERO,
                        alterName:
                            "This alter has a really, really, really, really long name!",
                        url: "https://api.systemswitchboard.com/avatar/null",
                        withFronterElement: false,
                        frontID: UUID_ZERO,
                        onTap: () {},
                        overflowDots: MemoryState.A.overflowDots,
                        overflowAnim: MemoryState.A.overflowAnimate,
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        value: MemoryState.A.overflowDots,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        title: Text(
                          "Replace the cut off text with three dots (...)",
                        ),
                        secondary: Icon(Icons.more),
                        onChanged: (B) async {
                          if ((B ?? false)) {
                            MemoryState.A.overflowAnimate = false;
                            MemoryState.A.overflowDots = true;
                          } else {
                            MemoryState.A.overflowDots = false;
                            MemoryState.A.overflowAnimate = true;
                          }

                          setAppSettings();

                          setState(() {});
                        },
                      ),
                      CheckboxListTile(
                        value: MemoryState.A.overflowAnimate,
                        onChanged: (B) async {
                          if ((B ?? false)) {
                            MemoryState.A.overflowAnimate = true;
                            MemoryState.A.overflowDots = false;
                          } else {
                            MemoryState.A.overflowDots = true;
                            MemoryState.A.overflowAnimate = false;
                          }

                          setAppSettings();

                          setState(() {});
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        title: Text("Side Scroll overflowing text"),
                        secondary: Icon(Icons.animation_sharp),
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
