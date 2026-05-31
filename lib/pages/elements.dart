import 'package:flutter/material.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/storage.dart';

class AlterWidget extends StatelessWidget {
  bool flush = false;
  bool roundedElement = true;
  bool squarePics = false;
  Color backgroundColor;
  Color textColor;
  UUID alterID;
  String alterName;

  AlterWidget({
    super.key,
    required this.alterID,
    required this.alterName,
    this.flush = true,
    this.roundedElement = true,
    this.squarePics = false,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: roundedElement ? null : BoxBorder.all(),
      margin: roundedElement ? null : EdgeInsetsGeometry.zero,
      color: backgroundColor,

      child: Row(
        children: [
          AlterImage(
            squarePics: squarePics,
            flush: flush,
            alterID: alterID,
            url: Alter.makeAvatarURL("null"),
          ),
          SizedBox(width: 8),
          Text(alterName, style: TextStyle(fontSize: 22, color: textColor)),
        ],
      ),
    );
  }
}

class AlterImage extends StatelessWidget {
  bool squarePics;
  bool flush;
  UUID alterID;
  double? width;
  double? height;
  String url;

  AlterImage({
    super.key,
    required this.squarePics,
    required this.flush,
    required this.alterID,
    required this.url,
    this.width = 75,
    this.height,
  });
  factory AlterImage.defaults({
    double? height,
    double? width,
    required Alter alter,
  }) {
    MemoryState ms = MemoryState();
    return AlterImage(
      squarePics: ms.squarePicture,
      flush: ms.flushPictures,
      alterID: alter.id,
      url: alter.getAvatarURL(),
      width: width ?? 75,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return flush
        ? Image.network(url, width: width, height: height)
        : Padding(
            padding: EdgeInsetsGeometry.all((squarePics && !flush) ? 8 : 2),
            child: Card(
              elevation: 8,
              shape: squarePics ? BoxBorder.all() : null,
              margin: squarePics ? EdgeInsets.zero : null,
              child: Image.network(url, width: width, height: height),
            ),
          );
  }
}

class FieldWidget extends StatelessWidget {
  bool roundedElement = true;
  Field field;
  Color backgroundColor;
  Color textColor;
  Function() onTap;
  bool enableReorder = false;

  FieldWidget({
    super.key,
    required this.field,
    required this.onTap,
    this.roundedElement = true,
    this.enableReorder = false,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: roundedElement ? null : BoxBorder.all(),
      margin: roundedElement ? null : EdgeInsetsGeometry.zero,
      color: backgroundColor,

      child: SizedBox(
        height: field.type.value() <= -1 ? 95 : 75,
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text(
            field.name,
            style: TextStyle(fontSize: 22, color: textColor),
          ),
          onTap: onTap,
          trailing: enableReorder ? Icon(Icons.menu) : null,
          subtitle: Text(
            "Order: ${field.order}${field.type.value() <= -1 ? "\n(REQUIRED FIELD)" : ""}",
          ),
        ),
      ),
    );
  }
}

Future<List<DropdownMenuEntry<FieldType>>> getFieldMenuEntries({
  bool includeSystem = false,
}) async {
  List<DropdownMenuEntry<FieldType>> entries = [];
  for (var val in FieldType.values) {
    if (val != FieldType.Unknown) {
      if (includeSystem || val.value() >= 0) {
        entries.add(DropdownMenuEntry(value: val, label: val.toString()));
      }
    }
  }

  return entries;
}
