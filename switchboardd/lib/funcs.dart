import 'dart:convert';
import 'dart:math';

import 'package:libac_dart/utils/Hashing.dart';
import 'package:libac_dart/utils/TimeUtils.dart';

class ServerSecurityHelpers {
  static String makePasswordSalt() {
    int timestamp = TimeUtils.getUnixTimestamp();
    Random rnd = Random.secure();
    int val = rnd.nextInt(255);
    return Hashing.md5Hash("$timestamp:${Hashing.md5Hash("$val")}");
  }

  static String makePasswordHash(String passwordHash, String passwordSalt) {
    return Hashing.md5Hash("$passwordHash:$passwordSalt");
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

  // Handle lists
  if (value is List) {
    List<dynamic> corrected = value.map(typeCorrect).toList();
    if (corrected.isEmpty) {
      // Type is unknowable.
      return corrected;
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
