import 'dart:async';

import 'package:libac_dart/nbt/NbtUtils.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/nbt/impl/IntArrayTag.dart';
import 'package:libac_dart/nbt/impl/StringTag.dart';
import 'package:switchboard/globalHelpers.dart';

class MemoryState {
  static final MemoryState _state = MemoryState._init();
  static final MemoryState _defaults = MemoryState._init();

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
  String lastErrorRay = "";

  Timer? flushTimer;
  bool terminating = false;

  bool flushPictures = true;
  bool roundedBorder = true;
  bool squarePicture = false;
  bool rememberMe = false;
  String username = "";
  String password = "";

  List<int> AlterBackgroundColor = [255, 90, 90, 90];
  List<int> AlterTextColor = [179, 255, 255, 255];
  List<int> NavSelColor = [255, 0, 183, 255];
  List<int> NavUnSelColor = [255, 105, 105, 205];

  void deserialize(CompoundTag ct) {
    if (ct.containsKey("flush_avatars")) {
      flushPictures = true;
    } else {
      flushPictures = _defaults.flushPictures;
    }

    if (ct.containsKey("roundedborder")) {
      roundedBorder = true;
    } else {
      roundedBorder = _defaults.roundedBorder;
    }

    if (ct.containsKey("squarePicture")) {
      squarePicture = true;
    } else {
      _defaults.squarePicture;
    }

    if (ct.containsKey("alterBackground")) {
      List<int> iat = ct.get("alterBackground")!.asIntArray();
      AlterBackgroundColor = iat;
    } else {
      AlterBackgroundColor = _defaults.AlterBackgroundColor;
    }

    if (ct.containsKey("alterText")) {
      List<int> iat = ct.get("alterText")!.asIntArray();
      AlterTextColor = iat;
    } else {
      AlterTextColor = _defaults.AlterTextColor;
    }

    if (ct.containsKey("navSelColor")) {
      List<int> iat = ct.get("navSelColor")!.asIntArray();
      NavSelColor = iat;
    } else {
      NavSelColor = _defaults.NavSelColor;
    }

    if (ct.containsKey("navUnSelColor")) {
      List<int> iat = ct.get("navUnSelColor")!.asIntArray();
      NavUnSelColor = iat;
    } else {
      NavUnSelColor = _defaults.NavUnSelColor;
    }

    if (ct.containsKey("rememberMe")) {
      rememberMe = NbtUtils.readBoolean(ct, "rememberMe");
      if (rememberMe) {
        username = ct.get("username")!.asString();
        password = ct.get("password")!.asString();
      }
    } else {
      username = "";
      password = "";
      rememberMe = false;
    }
  }

  CompoundTag serialize() {
    CompoundTag ct = CompoundTag();

    if (flushPictures) NbtUtils.writeBoolean(ct, "flush_avatars", true);
    if (roundedBorder) NbtUtils.writeBoolean(ct, "roundedborder", true);
    if (squarePicture) NbtUtils.writeBoolean(ct, "squarePicture", true);

    if (!identicalColors(
      AlterBackgroundColor,
      _defaults.AlterBackgroundColor,
    )) {
      IntArrayTag iat = IntArrayTag.valueOf(AlterBackgroundColor);
      ct.put("alterBackground", iat);
    }

    if (!identicalColors(AlterTextColor, _defaults.AlterTextColor)) {
      IntArrayTag iat = IntArrayTag.valueOf(AlterTextColor);

      ct.put("alterText", iat);
    }

    if (!identicalColors(NavSelColor, _defaults.NavSelColor)) {
      IntArrayTag iat = IntArrayTag.valueOf(NavSelColor);

      ct.put("navSelColor", iat);
    }

    if (!identicalColors(NavUnSelColor, _defaults.NavUnSelColor)) {
      IntArrayTag iat = IntArrayTag.valueOf(NavUnSelColor);

      ct.put("navUnSelColor", iat);
    }

    NbtUtils.writeBoolean(ct, "rememberMe", rememberMe);
    if (rememberMe) {
      ct.put("username", StringTag.valueOf(username));
      ct.put("password", StringTag.valueOf(password));
    }

    return ct;
  }

  void reset() {
    CompoundTag defaults = CompoundTag();

    NbtUtils.writeBoolean(defaults, "roundedborder", true);

    deserialize(defaults);
  }
}
