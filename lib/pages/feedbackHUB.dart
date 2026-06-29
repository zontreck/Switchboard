import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown_block.dart';

class FeedbackHUB extends StatefulWidget {
  const FeedbackHUB({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              MarkdownBlock(
                data:
                    "# Feedback\n\nHello! We're still in the process of building this section of the app. If it is not available, that means we needed to prioritize other functionality to quickly get the app launched in time for users to migrate to our platform. This area of the app will be operational very soon!",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
