import 'package:flutter/material.dart';

class SBAboutPage extends StatelessWidget {
  const SBAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Switchboard - About")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              Text(
                "Switchboard is an accessibility app, designed to help accommodate those with DID/OSDD, plurality, or for roleplay needs.",
              ),
              Text("At present there is a single developer."),
            ],
          ),
        ),
      ),
    );
  }
}
