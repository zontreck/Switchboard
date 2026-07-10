import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:switchboard/dart/MemoryState.dart';
import 'package:switchboard/dart/globalHelpers.dart';
import 'package:switchboard/dart/privacyPolicy.dart';
import 'package:switchboard/globalHelpers.dart';
import 'package:switchboard/pages/elements.dart';

class GlowPresets extends StatefulWidget {
  const GlowPresets({super.key});

  @override
  State<StatefulWidget> createState() {
    return _presets();
  }
}

class _presets extends State<GlowPresets> {
  List<_Preset> presets = [
    _Preset(
      assetName: "pride_flag",
      label: "Pride Flag",
      callback: () {
        MemoryState.A.prideGlow = true;
      },
      deselect: () {
        MemoryState.A.prideGlow = false;
      },
    ),
    _Preset(
      assetName: "gilbert_baker_pride_flag",
      label: "Gilbert Baker Pride Flag",
      callback: () {
        MemoryState.A.gilberBakerGlow = true;
      },
      deselect: () {
        MemoryState.A.gilberBakerGlow = false;
      },
    ),
    _Preset(
      assetName: "trans_flag",
      label: "Transgender",
      callback: () {
        MemoryState.A.transGlow = true;
      },
      deselect: () {
        MemoryState.A.transGlow = false;
      },
    ),
    _Preset(
      assetName: "intersex_flag",
      label: "Intersex",
      callback: () {
        MemoryState.A.intersexGlow = true;
      },
      deselect: () {
        MemoryState.A.intersexGlow = false;
      },
    ),
    _Preset(
      assetName: "nonbinary_flag",
      label: "Non-Binary",
      callback: () {
        MemoryState.A.nonBinaryGlow = true;
      },
      deselect: () {
        MemoryState.A.nonBinaryGlow = false;
      },
    ),
    _Preset(
      assetName: "xenogender_flag",
      label: "Xenogender",
      callback: () {
        MemoryState.A.xenogenderGlow = true;
      },
      deselect: () {
        MemoryState.A.xenogenderGlow = false;
      },
    ),
    _Preset(
      assetName: "genderfluid_flag",
      label: "Genderfluid",
      callback: () {
        MemoryState.A.genderfluidGlow = true;
      },
      deselect: () {
        MemoryState.A.genderfluidGlow = false;
      },
    ),
    _Preset(
      assetName: "systemfluid_flag",
      label: "Systemfluid",
      callback: () {
        MemoryState.A.systemfluidGlow = true;
      },
      deselect: () {
        MemoryState.A.systemfluidGlow = false;
      },
    ),
    _Preset(
      assetName: "genderqueer_flag",
      label: "Genderqueer",
      callback: () {
        MemoryState.A.genderqueerGlow = true;
      },
      deselect: () {
        MemoryState.A.genderqueerGlow = false;
      },
    ),
    _Preset(
      assetName: "queer_flag",
      label: "Queer",
      callback: () {
        MemoryState.A.queerGlow = true;
      },
      deselect: () {
        MemoryState.A.queerGlow = false;
      },
    ),
    _Preset(
      assetName: "abro_flag",
      label: "Abro",
      callback: () {
        MemoryState.A.abroGlow = true;
      },
      deselect: () {
        MemoryState.A.abroGlow = false;
      },
    ),
    _Preset(
      assetName: "aroace_flag",
      label: "Aroace",
      callback: () {
        MemoryState.A.aroAceGlow = true;
      },
      deselect: () {
        MemoryState.A.aroAceGlow = false;
      },
    ),
    _Preset(
      assetName: "asexual_flag",
      label: "Asexual",
      callback: () {
        MemoryState.A.aceGlow = true;
      },
      deselect: () {
        MemoryState.A.aceGlow = false;
      },
    ),
    _Preset(
      assetName: "aromantic_flag",
      label: "Aromantic",
      callback: () {
        MemoryState.A.aroGlow = true;
      },
      deselect: () {
        MemoryState.A.aroGlow = false;
      },
    ),
    _Preset(
      assetName: "lesbian_flag",
      label: "Lesbian",
      callback: () {
        MemoryState.A.lesbianGlow = true;
      },
      deselect: () {
        MemoryState.A.lesbianGlow = false;
      },
    ),
    _Preset(
      assetName: "mlm_flag",
      label: "Men Loving Men",
      callback: () {
        MemoryState.A.gayGlow = true;
      },
      deselect: () {
        MemoryState.A.gayGlow = false;
      },
    ),
    _Preset(
      assetName: "bi_flag",
      label: "Bisexual",
      callback: () {
        MemoryState.A.biGlow = true;
      },
      deselect: () {
        MemoryState.A.biGlow = false;
      },
    ),
    _Preset(
      assetName: "pan_flag",
      label: "Pansexual",
      callback: () {
        MemoryState.A.panGlow = true;
      },
      deselect: () {
        MemoryState.A.panGlow = false;
      },
    ),
    _Preset(
      assetName: "omni_flag",
      label: "Omni",
      callback: () {
        MemoryState.A.omniGlow = true;
      },
      deselect: () {
        MemoryState.A.omniGlow = false;
      },
    ),
    _Preset(
      assetName: "polysexual_flag",
      label: "Polysexual",
      callback: () {
        MemoryState.A.polysexualGlow = true;
      },
      deselect: () {
        MemoryState.A.polysexualGlow = false;
      },
    ),
    _Preset(
      assetName: "polyam_flag_1",
      label: "Polyamorous",
      callback: () {
        MemoryState.A.polyamAGlow = true;
      },
      deselect: () {
        MemoryState.A.polyamAGlow = false;
      },
    ),
    _Preset(
      assetName: "polyam_flag_2",
      label: "Polyamorous",
      callback: () {
        MemoryState.A.polyamBGlow = true;
      },
      deselect: () {
        MemoryState.A.polyamBGlow = false;
      },
    ),
    _Preset(
      assetName: "neurogender_flag_1",
      label: "Neurogender",
      callback: () {
        MemoryState.A.neurogenderAGlow = true;
      },
      deselect: () {
        MemoryState.A.neurogenderAGlow = false;
      },
    ),
    _Preset(
      assetName: "neurogender_flag_2",
      label: "Neurogender",
      callback: () {
        MemoryState.A.neurogenderBGlow = true;
      },
      deselect: () {
        MemoryState.A.neurogenderBGlow = false;
      },
    ),
    _Preset(
      assetName: "autigender_flag_1",
      label: "Autigender",
      callback: () {
        MemoryState.A.autigenderAGlow = true;
      },
      deselect: () {
        MemoryState.A.autigenderAGlow = false;
      },
    ),
    _Preset(
      assetName: "autigender_flag_2",
      label: "Autigender",
      callback: () {
        MemoryState.A.autigenderBGlow = true;
      },
      deselect: () {
        MemoryState.A.autigenderBGlow = false;
      },
    ),
  ];
  int _selectedPreset = -1;

  void sanityCheck() {
    int indx = 0;
    for (var preset in presets) {
      if (_selectedPreset == indx) {
        // okay
        continue;
      } else {
        preset.deselect();
      }
      indx++;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedPreset = MemoryState.A.glowPresetID;
    sanityCheck();
  }

  Widget getCard(int index) {
    return Card(
      elevation: 8,
      child: Column(
        children: [
          presets[index].getImage(),
          Text(presets[index].label, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switchboard"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(125),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  "Glow Presets - ${presets.length} total",
                  style: TextStyle(fontSize: 22),
                ),
                AlterWidget(
                  alterID: UUID_ZERO,
                  onTap: () {},
                  alterName: "Sample Alter",
                  url: "${getAPIServerURL()}/avatar/null",
                  withFronterElement: false,
                  frontID: UUID_ZERO,
                  frontStartTime: TimeUtils.getUnixTimestamp(),
                  frontEndTime: 0,
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (bldr, index) {
            return InkWell(
              onTap: () {
                if (_selectedPreset == index) {
                  _selectedPreset = -1;
                  presets[index].deselect();
                } else {
                  _selectedPreset = index;
                  presets[index].callback();
                }

                sanityCheck();
                setState(() {
                  MemoryState.A.glowPresetID = _selectedPreset;
                });
              },
              child: _selectedPreset == index
                  ? GlowContainer(
                      gradientColors: [getNavSelColor()],
                      animations: MemoryState.A.disableGlowAnimations
                          ? false
                          : true,
                      child: getCard(index),
                    )
                  : getCard(index),
            );
          },
          itemCount: presets.length,
        ),
      ),
    );
  }
}

class _Preset {
  String assetName;
  String label;
  void Function() callback;
  void Function() deselect;

  Widget getImage() {
    return Image.asset("assets/$assetName.png", width: 175, height: 110);
  }

  _Preset({
    required this.assetName,
    required this.label,
    required this.callback,
    required this.deselect,
  });
}
