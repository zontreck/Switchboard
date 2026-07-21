import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:libac_dart/nbt/Stream.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/storage.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:text_scroll/text_scroll.dart';

class AlterWidget extends StatefulWidget {
  bool flush = false;
  bool roundedElement = true;
  bool squarePics = false;
  Color backgroundColor;
  Color textColor;
  String alterID;
  String alterName;
  String url;
  bool withFronterElement;
  bool get fronting => frontStartTime > 0 && frontEndTime == 0;
  String frontID;
  Alter? alter;
  bool showFrontingTime;
  int frontStartTime;
  int frontEndTime;
  bool longPressMenu = false;
  bool overflowDots = true;
  bool overflowAnim = false;
  void Function() onTap;
  List<CupertinoButton> longPressOptions = [];

  AlterWidget({
    super.key,
    required this.alterID,
    required this.alterName,
    required this.url,
    required this.withFronterElement,
    required this.frontID,
    required this.onTap,
    this.alter,
    this.flush = true,
    this.roundedElement = true,
    this.squarePics = false,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white70,
    this.showFrontingTime = false,
    this.frontStartTime = 0,
    this.frontEndTime = 0,
    this.longPressMenu = false,
    this.longPressOptions = const [],
    this.overflowDots = true,
    this.overflowAnim = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _widget();
  }
}

class _widget extends State<AlterWidget> {
  Widget getGlow(Widget child, List<Color> colors) {
    return GlowContainer(
      gradientColors: colors,
      glowRadius: 8,
      animations: MemoryState.A.disableGlowAnimations ? false : true,
      child: child,
    );
  }

  String calculateFrontingTime() {
    DateTime now = DateTime.now();
    if (!widget.fronting) now = TimeUtils.parseTimestamp(widget.frontEndTime);
    DateTime then = TimeUtils.parseTimestamp(widget.frontStartTime);
    Duration span = now.difference(then);

    int oneMinute = 60;
    int oneHour = oneMinute * 60;
    int oneDay = oneHour * 24;
    int oneWeek = oneDay * 7;

    int seconds = span.inSeconds;
    int weeks = (seconds / oneWeek).floor();
    seconds = seconds - (weeks * oneWeek);
    int days = (seconds / oneDay).floor();
    seconds = seconds - (days * oneDay);
    int hours = (seconds / oneHour).floor();
    seconds = seconds - (hours * oneHour);
    int minutes = (seconds / oneMinute).floor();
    seconds = seconds - (minutes * oneMinute);

    StringBuilder str = StringBuilder();
    if (weeks > 0) str.append("${weeks}w ");
    if (days > 0) str.append("${days}d ");
    if (hours > 0) str.append("${hours}h ");
    if (minutes > 0) str.append("${minutes}m ");
    if (seconds > 0) str.append("${seconds}s");

    return str.toString();
  }

  String getDateRange() {
    DateTime start = TimeUtils.parseTimestamp(widget.frontStartTime).toLocal();
    DateTime end = DateTime.now();

    if (widget.frontEndTime != 0) {
      end = TimeUtils.parseTimestamp(widget.frontEndTime).toLocal();
    }

    StringBuilder bldr = StringBuilder();
    bldr.append("${start.month}/${start.day}/${start.year} - ");
    if (widget.frontEndTime == 0) {
      bldr.append("Present");
    } else {
      bldr.append("${end.month}/${end.day}/${end.year}");
    }
    bldr.append(
      "\n${start.hour > 12 ? (start.hour - 12) : start.hour}:${start.minute.toString().padLeft(2, '0')}  ${start.hour >= 12 ? "PM" : "AM"}  - ",
    );

    if (widget.frontEndTime == 0) {
      bldr.append("Now");
    } else {
      bldr.append(
        "${end.hour > 12 ? (end.hour - 12) : end.hour}:${end.minute.toString().padLeft(2, '0')}  ${end.hour >= 12 ? "PM" : "AM"}",
      );
    }

    return bldr.toString();
  }

  Widget getCard() {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.longPressMenu
          ? () async {
              await showDialog(
                context: context,
                builder: (bldr) {
                  return CupertinoAlertDialog(
                    title: Text(
                      widget.alterName,
                      style: TextStyle(fontSize: 22),
                    ),
                    actions: widget.longPressOptions,
                  );
                },
              );
            }
          : null,
      child: Card(
        elevation: 8,
        shape: widget.roundedElement ? null : BoxBorder.all(),
        margin: widget.roundedElement ? null : EdgeInsetsGeometry.zero,
        color: widget.backgroundColor,
        clipBehavior: Clip.hardEdge,

        child: Row(
          children: [
            AlterImage(
              squarePics: widget.squarePics,
              flush: widget.flush,
              alterID: widget.alterID,
              url: Alter.makeAvatarURL(widget.url),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.overflowAnim)
                    TextScroll(
                      widget.alterName,
                      style: TextStyle(fontSize: 22, color: widget.textColor),
                      mode: TextScrollMode.endless,
                      fadedBorder: true,
                      fadedBorderWidth: 0.02,
                      pauseBetween: Duration(seconds: 5),
                      velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                    ),
                  if (!widget.overflowAnim)
                    Text(
                      widget.alterName,
                      maxLines: 1,
                      style: TextStyle(fontSize: 22, color: widget.textColor),
                      overflow: widget.overflowDots
                          ? TextOverflow.ellipsis
                          : null,
                    ),
                  FutureBuilder(
                    future: widget.alter?.getPronouns(),
                    builder: (probldr, prosnap) {
                      if (!prosnap.hasData) {
                        if (!prosnap.hasError) {
                          return SizedBox();
                        }
                        return CircularProgressIndicator();
                      } else {
                        String txt = "";
                        if (prosnap.data == "") {
                          return SizedBox();
                        } else {
                          txt = "(${prosnap.data})";
                        }

                        if (widget.overflowAnim) {
                          return TextScroll(
                            txt,
                            style: TextStyle(
                              fontSize: 22,
                              color: widget.textColor,
                            ),
                            mode: TextScrollMode.endless,
                            fadedBorder: true,
                            fadedBorderWidth: 0.02,
                            pauseBetween: Duration(seconds: 5),
                            velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                          );
                        }
                        return Text(
                          txt,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 22,
                            color: widget.textColor,
                          ),
                          overflow: widget.overflowDots
                              ? TextOverflow.ellipsis
                              : null,
                        );
                      }
                    },
                  ),
                  if (widget.showFrontingTime && widget.fronting)
                    Text(
                      "Fronting for: \n${calculateFrontingTime()}",
                      style: TextStyle(fontSize: 20, color: widget.textColor),
                    ),
                  if (!widget.fronting && widget.showFrontingTime)
                    Text(
                      "${calculateFrontingTime()}\n${getDateRange()}",
                      style: TextStyle(color: widget.textColor, fontSize: 18),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.withFronterElement) {
      return Dismissible(
        key: UniqueKey(),
        background: Card(
          elevation: 1,
          shape: widget.roundedElement ? null : BoxBorder.all(),
          margin: widget.roundedElement ? null : EdgeInsetsGeometry.zero,
          color: Colors.blueGrey,
          child: ListTile(
            leading: widget.fronting ? Icon(Icons.download) : null,
            trailing: widget.fronting ? null : Icon(Icons.upload),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Left to right: Remove from front
            if (widget.fronting) {
              var rep = await NetworkInterface.unfrontFronter(widget.alterID);
              widget.frontEndTime = TimeUtils.getUnixTimestamp();
              widget.frontID = UUID_ZERO;

              if (!rep.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "FATAL: Fronter could not be removed [${rep.reason}]\nRequest ID: ${rep.id.toString()}",
                    ),
                  ),
                );
              }
            }
          } else if (direction == DismissDirection.endToStart) {
            // Right to left: Set front
            if (!widget.fronting) {
              var rep = await NetworkInterface.setFronting(widget.alterID);

              widget.frontEndTime = 0;
              widget.frontStartTime = TimeUtils.getUnixTimestamp();

              if (!rep.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "FATAL: Fronter could not be set [${rep.reason}]\nRequest ID: ${rep.id.toString()}",
                    ),
                  ),
                );
              }
            }
          } else {
            // Invalid direction. Cancel the action
          }

          return false;
        },
        child: widget.fronting
            ? getGlow(
                getCard(),
                getCustomGlow(alterPreferedColor: widget.backgroundColor),
              )
            : getCard(),
      );
    } else {
      if (widget.fronting) {
        return getGlow(
          getCard(),
          getCustomGlow(alterPreferedColor: widget.backgroundColor),
        );
      } else {
        return getCard();
      }
    }
  }
}

class AlterImage extends StatelessWidget {
  bool squarePics;
  bool flush;
  String alterID;
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
