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
    );
  }

  @override
  Widget build(BuildContext context) {
    return flush
        ? Image.network(
            "https://api.systemswitchboard.com/avatar/${alterID.toString()}",
            width: width,
            height: height,
          )
        : Padding(
            padding: EdgeInsetsGeometry.all((squarePics && !flush) ? 8 : 2),
            child: Card(
              elevation: 8,
              shape: squarePics ? BoxBorder.all() : null,
              margin: squarePics ? EdgeInsets.zero : null,
              child: Image.network(
                "https://api.systemswitchboard.com/avatar/${alterID.toString()}",
                width: width,
                height: height,
              ),
            ),
          );
  }
}
