import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:switchboard/globalHelpers.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard - Privacy Policy"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              Text("PRIVACY POLICY", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            SizedBox(height: 25),
            FutureBuilder(
              future: Policies.privacyPolicy(),
              builder: (BCTX, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Expanded(child: MarkdownWidget(data: snapshot.data!));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
