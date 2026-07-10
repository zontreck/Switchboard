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

  String serverBotPSK = "";
  String botToken = "";
  String authenticationToken = "";
  String lastErrorRay = "";

  Timer? flushTimer;
  bool terminating = false;

  bool flushPictures = false;
  bool roundedBorder = true;
  bool squarePicture = false;
  bool rememberMe = false;
  bool disableGlowAnimations = false;
  String username = "";
  String password = "";
  String applicationVersion = "";
  bool useCustomFont = false;
  String customFontFamily = "";
  AdSettings adSettings = AdSettings(onNavigate: false);

  bool prideGlow = false;
  bool transGlow = false;
  bool lesbianGlow = false;
  bool intersexGlow = false;
  bool nonBinaryGlow = false;
  bool panGlow = false;
  bool omniGlow = false;
  bool biGlow = false;
  bool aceGlow = false;
  bool aroGlow = false;
  bool aroAceGlow = false;
  bool gayGlow = false;
  bool abroGlow = false;
  bool genderfluidGlow = false;
  bool systemfluidGlow = false;
  bool gilberBakerGlow = false;
  bool queerGlow = false;
  bool polysexualGlow = false;
  bool polyamAGlow = false;
  bool polyamBGlow = false;
  bool xenogenderGlow = false;
  bool genderqueerGlow = false;
  bool neurogenderAGlow = false;
  bool neurogenderBGlow = false;
  bool autigenderAGlow = false;
  bool autigenderBGlow = false;

  int glowPresetID = -1;

  static const GLOW_PRIDE = 1;
  static const GLOW_TRANS = 2;
  static const GLOW_LESBIAN = 4;
  static const GLOW_INTERSEX = 8;
  static const GLOW_NONBINARY = 16;
  static const GLOW_PAN = 32;
  static const GLOW_OMNI = 64;
  static const GLOW_BI = 128;
  static const GLOW_ACE = 256;
  static const GLOW_ARO = 512;
  static const GLOW_AROACE = 1024;
  static const GLOW_GAY = 2048;
  static const GLOW_ABRO = 4096;
  static const GLOW_GENDERFLUID = 8192;
  static const GLOW_SYSTEMFLUID = 16384;
  static const GLOW_GILBERT_BAKER = 32768;
  static const GLOW_QUEER = 65536;
  static const GLOW_POLYSEXUAL = 131072;
  static const GLOW_POLYAM_A = 262144;
  static const GLOW_POLYAM_B = 524288;
  static const GLOW_XENOGENDER = 1048576;
  static const GLOW_GENDERQUEER = 2097152;
  static const GLOW_NEUROGENDER_A = 4194304;
  static const GLOW_NEUROGENDER_B = 8388608;
  static const GLOW_AUTIGENDER_A = 16777216;
  static const GLOW_AUTIGENDER_B = 33554432;

  List<List<int>> glowColors = [];

  List<int> AlterBackgroundColor = [255, 90, 90, 90];
  List<int> AlterTextColor = [179, 255, 255, 255];
  List<int> NavSelColor = [255, 0, 183, 255];
  List<int> NavUnSelColor = [255, 105, 105, 205];

  void fromJson(Map<String, dynamic> js, {bool theme = false}) {
    js = typeCorrectJson(js); // Fix the types real fast.

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

    if (js.containsKey("prideGlow")) {
      int mask = 0;
      try {
        mask = js['prideGlow'];
      } catch (E) {}
      if ((mask & GLOW_PRIDE) == GLOW_PRIDE) {
        prideGlow = true;
      } else {
        prideGlow = false;
      }
      if ((mask & GLOW_TRANS) == GLOW_TRANS) {
        transGlow = true;
      } else {
        transGlow = false;
      }
      if ((mask & GLOW_LESBIAN) == GLOW_LESBIAN) {
        lesbianGlow = true;
      } else {
        lesbianGlow = false;
      }
      if ((mask & GLOW_INTERSEX) == GLOW_INTERSEX) {
        intersexGlow = true;
      } else {
        intersexGlow = false;
      }
      if ((mask & GLOW_NONBINARY) == GLOW_NONBINARY) {
        nonBinaryGlow = true;
      } else {
        nonBinaryGlow = false;
      }
      if ((mask & GLOW_PAN) == GLOW_PAN) {
        panGlow = true;
      } else {
        panGlow = false;
      }
      if ((mask & GLOW_OMNI) == GLOW_OMNI) {
        omniGlow = true;
      } else {
        omniGlow = false;
      }
      if ((mask & GLOW_BI) == GLOW_BI) {
        biGlow = true;
      } else {
        biGlow = false;
      }
      if ((mask & GLOW_ACE) == GLOW_ACE) {
        aceGlow = true;
      } else {
        aceGlow = false;
      }
      if ((mask & GLOW_ARO) == GLOW_ARO) {
        aroGlow = true;
      } else {
        aroGlow = false;
      }
      if ((mask & GLOW_AROACE) == GLOW_AROACE) {
        aroAceGlow = true;
      } else {
        aroAceGlow = false;
      }
      if ((mask & GLOW_GAY) == GLOW_GAY) {
        gayGlow = true;
      } else {
        gayGlow = false;
      }
      if ((mask & GLOW_ABRO) == GLOW_ABRO) {
        abroGlow = true;
      } else {
        abroGlow = false;
      }
      if ((mask & GLOW_GENDERFLUID) == GLOW_GENDERFLUID) {
        genderfluidGlow = true;
      } else {
        genderfluidGlow = false;
      }
      if ((mask & GLOW_SYSTEMFLUID) == GLOW_SYSTEMFLUID) {
        systemfluidGlow = true;
      } else {
        systemfluidGlow = false;
      }
      if ((mask & GLOW_GILBERT_BAKER) == GLOW_GILBERT_BAKER) {
        gilberBakerGlow = true;
      } else {
        gilberBakerGlow = false;
      }
      if ((mask & GLOW_QUEER) == GLOW_QUEER) {
        queerGlow = true;
      } else {
        queerGlow = false;
      }
      if ((mask & GLOW_POLYSEXUAL) == GLOW_POLYSEXUAL) {
        polysexualGlow = true;
      } else {
        polysexualGlow = false;
      }
      if ((mask & GLOW_POLYAM_A) == GLOW_POLYAM_A) {
        polyamAGlow = true;
      } else {
        polyamAGlow = false;
      }
      if ((mask & GLOW_POLYAM_B) == GLOW_POLYAM_B) {
        polyamBGlow = true;
      } else {
        polyamBGlow = false;
      }
      if ((mask & GLOW_XENOGENDER) == GLOW_XENOGENDER) {
        xenogenderGlow = true;
      } else {
        xenogenderGlow = false;
      }
      if ((mask & GLOW_GENDERQUEER) == GLOW_GENDERQUEER) {
        genderqueerGlow = true;
      } else {
        genderqueerGlow = false;
      }
      if ((mask & GLOW_NEUROGENDER_A) == GLOW_NEUROGENDER_A) {
        neurogenderAGlow = true;
      } else {
        neurogenderAGlow = false;
      }
      if ((mask & GLOW_NEUROGENDER_B) == GLOW_NEUROGENDER_B) {
        neurogenderBGlow = true;
      } else {
        neurogenderBGlow = false;
      }
      if ((mask & GLOW_AUTIGENDER_A) == GLOW_AUTIGENDER_A) {
        autigenderAGlow = true;
      } else {
        autigenderAGlow = false;
      }
      if ((mask & GLOW_AUTIGENDER_B) == GLOW_AUTIGENDER_B) {
        autigenderBGlow = true;
      } else {
        autigenderBGlow = false;
      }
    }

    if (js.containsKey("glowPreset")) {
      glowPresetID = js['glowPreset'];
    }

    if (js.containsKey("glow")) {
      var g = js['glow'];
      glowColors = [];
      for (var entry in g) {
        glowColors.add(entry as List<int>);
      }
    } else {
      glowColors = [];
    }

    if (js.containsKey("glow_anims")) {
      disableGlowAnimations = true;
    } else {
      disableGlowAnimations = false;
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

    int prideGlows = 0;

    if (prideGlow) {
      prideGlows |= GLOW_PRIDE;
    }
    if (transGlow) {
      prideGlows |= GLOW_TRANS;
    }
    if (lesbianGlow) {
      prideGlows |= GLOW_LESBIAN;
    }
    if (intersexGlow) {
      prideGlows |= GLOW_INTERSEX;
    }
    if (nonBinaryGlow) {
      prideGlows |= GLOW_NONBINARY;
    }
    if (panGlow) {
      prideGlows |= GLOW_PAN;
    }
    if (omniGlow) {
      prideGlows |= GLOW_OMNI;
    }
    if (biGlow) {
      prideGlows |= GLOW_BI;
    }
    if (aceGlow) {
      prideGlows |= GLOW_ACE;
    }
    if (aroGlow) {
      prideGlows |= GLOW_ARO;
    }
    if (aroAceGlow) {
      prideGlows |= GLOW_AROACE;
    }
    if (gayGlow) {
      prideGlows |= GLOW_GAY;
    }
    if (abroGlow) {
      prideGlows |= GLOW_ABRO;
    }
    if (genderfluidGlow) {
      prideGlows |= GLOW_GENDERFLUID;
    }
    if (systemfluidGlow) {
      prideGlows |= GLOW_SYSTEMFLUID;
    }
    if (gilberBakerGlow) {
      prideGlows |= GLOW_GILBERT_BAKER;
    }
    if (queerGlow) {
      prideGlows |= GLOW_QUEER;
    }
    if (polysexualGlow) {
      prideGlows |= GLOW_POLYSEXUAL;
    }
    if (polyamAGlow) {
      prideGlows |= GLOW_POLYAM_A;
    }
    if (polyamBGlow) {
      prideGlows |= GLOW_POLYAM_B;
    }
    if (xenogenderGlow) {
      prideGlows |= GLOW_XENOGENDER;
    }
    if (genderqueerGlow) {
      prideGlows |= GLOW_GENDERQUEER;
    }
    if (neurogenderAGlow) {
      prideGlows |= GLOW_NEUROGENDER_A;
    }
    if (neurogenderBGlow) {
      prideGlows |= GLOW_NEUROGENDER_B;
    }
    if (autigenderAGlow) {
      prideGlows |= GLOW_AUTIGENDER_A;
    }
    if (autigenderBGlow) {
      prideGlows |= GLOW_AUTIGENDER_B;
    }

    js['prideGlow'] = prideGlows;
    js['glowPreset'] = glowPresetID;

    if (glowColors.isNotEmpty) {
      js['glow'] = glowColors;
    }

    if (disableGlowAnimations) {
      js['glow_anims'] = disableGlowAnimations;
    }

    return js;
  }

  Future<void> reset() async {
    fromJson(_defaults.toJson());
    await clearApplicationFont();
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
  }

  void navigated() {
    if (!onNavigate) {
      _pageViews = 0;
      return;
    }
    _pageViews++;
  }
}
