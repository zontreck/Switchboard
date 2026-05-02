import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:switchboard/globalHelpers.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Switchboard - Privacy Policy")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            Container(
              alignment: AlignmentGeometry.center,
              child: Text("PRIVACY POLICY", style: TextStyle(fontSize: 22)),
            ),
            Divider(),
            SizedBox(height: 25),
            FutureBuilder(
              future: Policies.privacyPolicy(),
              builder: (BCTX, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Expanded(child: Markdown(data: snapshot.data!));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
