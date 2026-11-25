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
