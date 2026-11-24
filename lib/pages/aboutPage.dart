import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/all.dart';

class SBAboutPage extends StatelessWidget {
  const SBAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("About", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: MarkdownWidget(
          data:
              "# The App\n\nSwitchboard is a app designed for those with DID/OSDD, plurality, and for roleplay purposes. The app lets you log alters, log who is fronting, and in the case of roleplay, lets you switch out the profile for the proxy bot to automatically rename you in chats.\n\n# zontreck\n\nAt present, the solo-developer of the app.\n\n# The Asterism Theatre\n\nOur artist, and zontreck's partner.",
        ),
      ),
    );
  }
}
