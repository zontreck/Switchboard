import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SBAboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("System Switchboard")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              Text(
                "System Switchboard is an accessibility app, designed to help accommodate role play needs, and for those who are plural, or have DID or OSDD.",
              ),
              Text("At present there is a single developer."),
            ],
          ),
        ),
      ),
    );
  }
}
