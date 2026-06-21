import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/storage.dart';

class AlterWidget extends StatelessWidget {
  bool flush = false;
  bool roundedElement = true;
  bool squarePics = false;
  Color backgroundColor;
  Color textColor;
  UUID alterID;
  String alterName;
  String url;
  bool withFronterElement;
  bool fronting;

  AlterWidget({
    super.key,
    required this.alterID,
    required this.alterName,
    required this.url,
    required this.withFronterElement,
    this.flush = true,
    this.roundedElement = true,
    this.squarePics = false,
    this.fronting = false,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white70,
  });

  Widget getGlow(Widget child, List<Color> colors) {
    return GlowContainer(gradientColors: colors, child: child, glowRadius: 8);
  }

  Widget getCard() {
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
            url: Alter.makeAvatarURL(url),
          ),
          SizedBox(width: 8),
          Text(alterName, style: TextStyle(fontSize: 22, color: textColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (withFronterElement) {
      return Dismissible(
        key: UniqueKey(),
        child: fronting
            ? getGlow(getCard(), [
                Color.fromARGB(255, 0, 192, 192),
                backgroundColor,
              ])
            : getCard(),
        background: Card(
          elevation: 1,
          shape: roundedElement ? null : BoxBorder.all(),
          margin: roundedElement ? null : EdgeInsetsGeometry.zero,
          color: Colors.blueGrey,
          child: ListTile(
            leading: Icon(Icons.download),
            trailing: Icon(Icons.upload),
          ),
        ),
      );
    } else {
      return getCard();
    }
  }
}

class AlterImage extends StatelessWidget {
  bool squarePics;
  bool flush;
  UUID alterID;
  double? width;
  double? height;
  String url;
  bool useCacheBusting = false;

  AlterImage({
    super.key,
    required this.squarePics,
    required this.flush,
    required this.alterID,
    required this.url,
    this.width = 75,
    this.height = 75,
    this.useCacheBusting = false,
  });
  factory AlterImage.defaults({
    double? height,
    double? width,
    bool useCacheBusting = false,
    required Alter alter,
  }) {
    MemoryState ms = MemoryState();
    return AlterImage(
      squarePics: ms.squarePicture,
      flush: ms.flushPictures,
      alterID: alter.id,
      url: alter.getAvatarURL(),
      width: width ?? 75,
      height: height ?? 75,
      useCacheBusting: useCacheBusting,
    );
  }

  @override
  Widget build(BuildContext context) {
    return flush
        ? Image.network(
            useCacheBusting ? "$url?ts=${TimeUtils.getUnixTimestamp()}" : url,
            width: width,
            height: height,
            fit: BoxFit.contain,
          )
        : Padding(
            padding: EdgeInsetsGeometry.all((squarePics && !flush) ? 8 : 2),
            child: Card(
              elevation: 8,
              clipBehavior: Clip.none,
              shape: squarePics ? BoxBorder.all() : null,
              margin: squarePics ? EdgeInsets.zero : null,
              child: Image.network(
                useCacheBusting
                    ? "$url?ts=${TimeUtils.getUnixTimestamp()}"
                    : url,
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
            ),
          );
  }
}

class NetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  Uint8List theData = Uint8List(0);
  NetImage({super.key, required this.url, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    return (theData.isEmpty)
        ? FutureBuilder(
            future: loadBytes(url),
            builder: (bldr, snap) {
              if (!snap.hasData) {
                return CircularProgressIndicator();
              } else {
                theData = snap.data!;
                return Image.memory(
                  theData,
                  fit: fit,
                  width: width,
                  height: height,
                );
              }
            },
          )
        : Image.memory(theData, fit: fit, width: width, height: height);
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
