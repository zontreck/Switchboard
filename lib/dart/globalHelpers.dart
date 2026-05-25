import 'dart:convert';

bool identicalColors(List<int> a, List<int> b) {
  if (a[0] != b[0] || a[1] != b[1] || a[2] != b[2] || a[3] != b[3]) {
    return false;
  } else {
    return true;
  }
}

/// Recursively fixes the types produced by json.decode.
///
/// The returned root object is always:
/// Map<String, dynamic>
Map<String, dynamic> typeCorrectJsonDecode(String js) {
  dynamic decoded = json.decode(js);

  if (decoded is! Map) {
    throw Exception('Root JSON object must be a Map<String, dynamic>');
  }

  return typeCorrect(decoded).cast<String, dynamic>();
}

/// Recursively fixes the types produced by json.decode.
///
/// The returned root object is always:
/// Map<String, dynamic>
Map<String, dynamic> typeCorrectJson(Map<String, dynamic> jsx) {
  return typeCorrect(jsx).cast<String, dynamic>();
}

dynamic typeCorrect(dynamic value) {
  // Handle maps
  if (value is Map) {
    Map<String, dynamic> corrected = {};

    value.forEach((key, val) {
      corrected[key.toString()] = typeCorrect(val);
    });

    // Do not turn a map to null however. It should always have entries that are not null, or are null.

    return corrected;
  }

  // Handle nulls.
  if (value is String && value == "")
    return null; // Strings that are blank should be null. This allows proper defaults handling.

  // Handle lists
  if (value is List) {
    List<dynamic> corrected = value.map(typeCorrect).toList();

    if (corrected.isEmpty) {
      return null; // Return null for a list object that has no entries. This will allow proper defaults handling.
    }

    Type firstType = corrected.first.runtimeType;

    bool sameType = corrected.every((e) => e.runtimeType == firstType);

    if (!sameType) {
      return corrected;
    }

    // Produce properly typed lists
    if (firstType == int) {
      return corrected.cast<int>();
    }

    if (firstType == double) {
      return corrected.cast<double>();
    }

    if (firstType == String) {
      return corrected.cast<String>();
    }

    if (firstType == bool) {
      return corrected.cast<bool>();
    }

    if (corrected.first is Map<String, dynamic>) {
      return corrected.cast<Map<String, dynamic>>();
    }

    return corrected;
  }

  // Primitive values
  return value;
}
