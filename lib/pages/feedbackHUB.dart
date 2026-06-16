import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeedbackHUB extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _feedback();
  }
}

class _feedback extends State<FeedbackHUB> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("FEEDBACK HUB", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
