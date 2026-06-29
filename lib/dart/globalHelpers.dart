import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:switchboard/dart/MemoryState.dart';

/// Runs a get request against a URL, supplying the Switchboard authentication header. Returns the response as a stream of bytes, overriding any content type.
Future<Uint8List> loadBytes(String url) async {
  Dio dio = Dio();
  print("Sending http get call to $url");
  var reply = await dio.get(
    url,
    options: Options(
      headers: {
        "Cache-Control": "no-cache",
        "X-SB-Auth": MemoryState.A.authenticationToken,
      },
      responseType: ResponseType.bytes,
    ),
  );

  print("Response received.");
  return reply.data;
}

bool identicalColors(List<int> a, List<int> b) {
  if (a[0] != b[0] || a[1] != b[1] || a[2] != b[2] || a[3] != b[3]) {
    return false;
  } else {
    return true;
  }
}

const String UUID_ZERO = "00000000-0000-0000-0000-000000000000";

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
