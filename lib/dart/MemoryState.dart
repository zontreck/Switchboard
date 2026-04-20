import 'dart:async';

import 'package:libac_dart/nbt/NbtUtils.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/nbt/impl/IntArrayTag.dart';

class MemoryState {
  static final MemoryState _state = MemoryState._init();

  factory MemoryState() {
    return _state;
  }

  static MemoryState get A => _state;

  MemoryState._init();

  bool useSQL = false;
  String mariaDBHost = "";
  String mariaDBUser = "";
  String mariaDBPass = "";
  String mariaDBName = "";
  String botToken = "";
  String authenticationToken = "";

  Timer? flushTimer;
  bool terminating = false;

  bool flushPictures = true;
  bool roundedBorder = true;
  bool squarePicture = false;

  int AlterBackgroundAlpha = 255;
  int AlterBackgroundRed = 90;
  int AlterBackgroundBlue = 90;
  int AlterBackgroundGreen = 90;

  int AlterTextAlpha = 179;
  int AlterTextRed = 255;
  int AlterTextGreen = 255;
  int AlterTextBlue = 255;

  int NavSelAlpha = 255;
  int NavSelRed = 0;
  int NavSelGreen = 183;
  int NavSelBlue = 255;

  int NavUnSelAlpha = 255;
  int NavUnSelRed = 105;
  int NavUnSelGreen = 105;
  int NavUnSelBlue = 105;

  void deserialize(CompoundTag ct) {
    if (ct.containsKey("flush_avatars"))
      flushPictures = true;
    else
      flushPictures = false;

    if (ct.containsKey("roundedborder"))
      roundedBorder = true;
    else
      roundedBorder = false;

    if (ct.containsKey("squarePicture"))
      squarePicture = true;
    else
      squarePicture = false;

    if (ct.containsKey("alterBackground")) {
      List<int> iat = ct.get("alterBackground")!.asIntArray();
      AlterBackgroundAlpha = iat[0];
      AlterBackgroundRed = iat[1];
      AlterBackgroundGreen = iat[2];
      AlterBackgroundBlue = iat[3];
    } else {
      AlterBackgroundAlpha = 255;
      AlterBackgroundBlue = 90;
      AlterBackgroundGreen = 90;
      AlterBackgroundRed = 90;
    }

    if (ct.containsKey("alterText")) {
      List<int> iat = ct.get("alterText")!.asIntArray();
      AlterTextAlpha = iat[0];
      AlterTextRed = iat[1];
      AlterTextGreen = iat[2];
      AlterTextBlue = iat[3];
    } else {
      AlterTextAlpha = 179;
      AlterTextRed = 255;
      AlterTextGreen = 255;
      AlterTextBlue = 255;
    }

    if (ct.containsKey("navSelColor")) {
      List<int> iat = ct.get("navSelColor")!.asIntArray();
      NavSelAlpha = iat[0];
      NavSelRed = iat[1];
      NavSelGreen = iat[2];
      NavSelBlue = iat[3];
    } else {
      NavSelAlpha = 255;
      NavSelRed = 0;
      NavSelGreen = 183;
      NavSelBlue = 255;
    }

    if (ct.containsKey("navUnSelColor")) {
      List<int> iat = ct.get("navUnSelColor")!.asIntArray();
      NavUnSelAlpha = iat[0];
      NavUnSelRed = iat[1];
      NavUnSelGreen = iat[2];
      NavUnSelBlue = iat[3];
    } else {
      NavUnSelAlpha = 255;
      NavUnSelRed = 105;
      NavUnSelGreen = 105;
      NavUnSelBlue = 105;
    }
  }

  CompoundTag serialize() {
    CompoundTag ct = CompoundTag();

    if (flushPictures) NbtUtils.writeBoolean(ct, "flush_avatars", true);
    if (roundedBorder) NbtUtils.writeBoolean(ct, "roundedborder", true);
    if (squarePicture) NbtUtils.writeBoolean(ct, "squarePicture", true);

    if (AlterBackgroundAlpha != 255 ||
        AlterBackgroundRed != 90 ||
        AlterBackgroundGreen != 90 ||
        AlterBackgroundBlue != 90) {
      IntArrayTag iat = IntArrayTag.valueOf([
        AlterBackgroundAlpha,
        AlterBackgroundRed,
        AlterBackgroundGreen,
        AlterBackgroundBlue,
      ]);

      ct.put("alterBackground", iat);
    }

    if (AlterTextAlpha != 179 ||
        AlterTextRed != 90 ||
        AlterTextGreen != 90 ||
        AlterTextBlue != 90) {
      IntArrayTag iat = IntArrayTag.valueOf([
        AlterTextAlpha,
        AlterTextRed,
        AlterTextGreen,
        AlterTextBlue,
      ]);

      ct.put("alterText", iat);
    }

    if (NavSelAlpha != 255 ||
        NavSelRed != 0 ||
        NavSelGreen != 183 ||
        NavSelBlue != 255) {
      IntArrayTag iat = IntArrayTag.valueOf([
        NavSelAlpha,
        NavSelRed,
        NavSelGreen,
        NavSelBlue,
      ]);

      ct.put("navSelColor", iat);
    }

    if (NavUnSelAlpha != 255 ||
        NavUnSelRed != 105 ||
        NavUnSelGreen != 105 ||
        NavUnSelBlue != 105) {
      IntArrayTag iat = IntArrayTag.valueOf([
        NavUnSelAlpha,
        NavUnSelRed,
        NavUnSelGreen,
        NavUnSelBlue,
      ]);

      ct.put("navUnSelColor", iat);
    }

    return ct;
  }

  void reset() {
    CompoundTag defaults = CompoundTag();

    NbtUtils.writeBoolean(defaults, "roundedborder", true);

    deserialize(defaults);
  }
}
