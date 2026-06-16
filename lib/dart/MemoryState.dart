import 'dart:async';

import 'package:switchboard/dart/globalHelpers.dart';
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

  bool flushPictures = false;
  bool roundedBorder = true;
  bool squarePicture = false;
  bool rememberMe = false;
  String username = "";
  String password = "";
  String applicationVersion = "";
  bool useCustomFont = false;
  String customFontFamily = "";
  AdSettings adSettings = AdSettings(onNavigate: false);

  List<int> AlterBackgroundColor = [255, 90, 90, 90];
  List<int> AlterTextColor = [179, 255, 255, 255];
  List<int> NavSelColor = [255, 0, 183, 255];
  List<int> NavUnSelColor = [255, 105, 105, 205];

  void fromJson(Map<String, dynamic> js, {bool theme = false}) {
    if (js.containsKey("flushPictures")) {
      flushPictures = true;
    } else {
      flushPictures = _defaults.flushPictures;
    }

    if (js.containsKey("rounded")) {
      roundedBorder = false;
    } else {
      roundedBorder = _defaults.roundedBorder;
    }

    if (js.containsKey("squarePics")) {
      squarePicture = true;
    } else {
      squarePicture = _defaults.squarePicture;
    }

    if (js.containsKey("ads")) {
      adSettings = AdSettings.decode(js['ads']);
    } else {
      adSettings = AdSettings(onNavigate: false);
    }

    if (js.containsKey("alterBackground")) {
      AlterBackgroundColor = js['alterBackground'];
    } else {
      AlterBackgroundColor = _defaults.AlterBackgroundColor;
    }

    if (js.containsKey("alterText")) {
      AlterTextColor = js['alterText'];
    } else {
      AlterTextColor = _defaults.AlterTextColor;
    }

    if (js.containsKey("navSelColor")) {
      NavSelColor = js['navSelColor'];
    } else {
      NavSelColor = _defaults.NavSelColor;
    }

    if (js.containsKey("navUnSelColor")) {
      NavUnSelColor = js['navUnSelColor'];
    } else {
      NavUnSelColor = _defaults.NavUnSelColor;
    }

    if (!theme && js.containsKey("rememberMe")) {
      rememberMe = js['rememberMe'];
      if (rememberMe) {
        username = js['username'];
        password = js['password'];
      }
    } else {
      if (!js.containsKey("rememberMe")) {
        username = "";
        password = "";
        rememberMe = false;
      }
    }
  }

  Map<String, dynamic> toJson({bool theme = true}) {
    Map<String, dynamic> js = {};

    if (flushPictures != _defaults.flushPictures) {
      js['flushPictures'] = true;
    }

    if (roundedBorder != _defaults.roundedBorder) {
      js['rounded'] = true;
    }

    if (squarePicture != _defaults.squarePicture) {
      js['squarePics'] = true;
    }

    if (!identicalColors(
      AlterBackgroundColor,
      _defaults.AlterBackgroundColor,
    )) {
      js['alterBackground'] = AlterBackgroundColor;
    }

    if (!identicalColors(AlterTextColor, _defaults.AlterTextColor)) {
      js['alterText'] = AlterTextColor;
    }

    if (!identicalColors(NavSelColor, _defaults.NavSelColor)) {
      js['navSelColor'] = NavSelColor;
    }

    if (!identicalColors(NavUnSelColor, _defaults.NavUnSelColor)) {
      js['navUnSelColor'] = NavUnSelColor;
    }

    if (rememberMe && !theme) {
      js['rememberMe'] = true;
      js['username'] = username;
      js['password'] = password;
    }

    js['ads'] = adSettings.toJson();

    return js;
  }

  void reset() {
    fromJson(_defaults.toJson());
  }
}

class AdSettings {
  bool onNavigate = false;
  int navCount = 4;
  int _pageViews = 0;

  Map<String, dynamic> toJson() {
    return {"nav": onNavigate, "navCount": navCount, "view": _pageViews};
  }

  factory AdSettings.decode(Map<String, dynamic> js) {
    return AdSettings(
      onNavigate: js['nav'],
      navCount: js['navCount'],
      pageViews: js['view'],
    );
  }

  AdSettings({required this.onNavigate, this.navCount = 4, int pageViews = 0})
    : _pageViews = pageViews;

  bool shouldShowAd() {
    if (!onNavigate) {
      _pageViews = 0;
      return false;
    }

    if (_pageViews >= navCount) {
      return true;
    }

    return false;
  }

  bool willShowAd() {
    if (!onNavigate) {
      _pageViews = 0;
      setAppSettings();
      return false;
    }

    if (_pageViews + 1 >= navCount) {
      return true;
    }

    return false;
  }

  int getPageViews() {
    return _pageViews;
  }

  void resetPageCounter() {
    _pageViews = 0;
    setAppSettings();
  }

  void navigated() {
    if (!onNavigate) {
      _pageViews = 0;
      return;
    }
    _pageViews++;
    setAppSettings();
  }
}
