import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:switchboard/dart/storage.dart';

class EditAlterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _editAlter();
  }
}

class _editAlter extends State<EditAlterPage> {
  UUID alterId = UUID.ZERO;

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as EditAlterArguments;
    alterId = args.alterId;

    return Scaffold(
      appBar: AppBar(title: Text("Switchboard - Edit Alter")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: NetworkInterface.getAlterByID(alterId),
            builder: (bldr, AsyncSnapshot<S2CAlterResponse> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                Alter alter = snapshot.data!.data!;

                String avatarUrl = alter.avatarUrl.startsWith("http")
                    ? alter.avatarUrl
                    : "${getAPIServerURL()}/avatar/${alter.id.toString()}";

                return Column(
                  children: [
                    Text(alter.name, style: TextStyle(fontSize: 22)),
                    Divider(),
                    Center(child: Image.network(avatarUrl, scale: 20)),
                  ],
                );

                setState(() {});
              }
            },
          ),
        ),
      ),
    );
  }
}

class EditAlterArguments {
  UUID alterId;

  EditAlterArguments({required this.alterId});
}
