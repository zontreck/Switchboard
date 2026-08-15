/// This class describes the serialization format of all Switchboard Data
///
/// NOTE: This format is subject to change as this is OUR project format. We'll do our best to maintain backward compatibility.
class SwitchboardFormat {
  SwitchboardFormat() {}

  Map<String, dynamic> toJson() {
    return {};
  }

  factory SwitchboardFormat.fromJson(Map<String, dynamic> js) {
    return SwitchboardFormat();
  }
}
