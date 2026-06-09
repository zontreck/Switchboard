import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:switchboard/globalHelpers.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
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

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _tosPage();
  }
}

class _tosPage extends State<TermsOfServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Column(
            children: [
              Text("TERMS OF SERVICE", style: TextStyle(fontSize: 22)),
              Divider(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: Policies.tos(),
              builder: (bldr, snap) {
                if (!snap.hasData) {
                  return CircularProgressIndicator();
                } else {
                  return Expanded(child: MarkdownWidget(data: snap.data!));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
