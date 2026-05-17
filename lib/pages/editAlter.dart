import 'package:flutter/material.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/pages/elements.dart';

class EditAlterPage extends StatefulWidget {
  const EditAlterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _editAlter();
  }
}

class _editAlter extends State<EditAlterPage> {
  UUID alterId = UUID.ZERO;
  TextEditingController alterNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as EditAlterArguments;
    alterId = args.alterId;

    return Scaffold(
      appBar: AppBar(title: Text("Switchboard - Edit Alter")),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {},
        label: Text("Save"),
        icon: Icon(Icons.done_outline_rounded),
      ),
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
                alterNameController.text = alter.name;

                return Column(
                  children: [
                    Text(alter.name, style: TextStyle(fontSize: 22)),
                    Divider(),
                    Center(
                      child: InkWell(
                        child: AlterImage.defaults(
                          alter: alter,
                          width: 25,
                          height: 25,
                        ),
                        onTap: () {},
                      ),
                    ),
                    Text("ID: ${alter.id}"),
                    SizedBox(height: 25),
                    TextField(
                      controller: alterNameController,
                      decoration: InputDecoration(
                        hintText: "Alter Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 25),
                    Divider(),
                    FutureBuilder(
                      future: getFieldList(),
                      builder: (bldr, snapFields) {
                        if (!snapFields.hasData) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapFields.data == null) {
                            return SizedBox();
                          }
                          return snapFields.data!;
                        }
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Widget?> getFieldList() async {
    List<Widget> widgets = [];
    S2CFieldsResponse fields = await NetworkInterface.getDataFields();
    List<Field> fieldVals = fields.data;
    fieldVals.sort((F1, F2) {
      return F1.order.compareTo(F2.order);
    });
    S2CAlterResponse alterReply = await NetworkInterface.getAlterByID(alterId);
    Alter? alter = alterReply.data;
    if (alter == null) {
      return SizedBox(); // No alter, means no fields to populate.
    }

    for (var field in fieldVals) {
      widgets.add(Text(field.name, style: TextStyle(fontSize: 22)));

      widgets.add(Divider());
    }
    return Column(children: widgets);
  }
}

class AlterFieldData extends StatefulWidget {
  FieldData? data;
  FieldType type;

  AlterFieldData({super.key, required this.data, required this.type});

  @override
  State<StatefulWidget> createState() {
    return _alterFieldData(data: data, type: type);
  }
}

class _alterFieldData extends State<AlterFieldData> {
  FieldData? data;
  FieldType type;

  _alterFieldData({required this.data, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(); // Temporary return value
  }
}

class EditAlterArguments {
  UUID alterId;

  EditAlterArguments({required this.alterId});
}
