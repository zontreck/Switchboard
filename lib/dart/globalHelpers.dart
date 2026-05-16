import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

bool identicalColors(List<int> a, List<int> b) {
  if (a[0] != b[0] || a[1] != b[1] || a[2] != b[2] || a[3] != b[3]) {
    return false;
  } else {
    return true;
  }
}

// Define a reusable function
String generateRandomString(int length) {
  final random = Random();
  const availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  final randomString = List.generate(
    length,
    (index) => availableChars[random.nextInt(availableChars.length)],
  ).join();

  return randomString;
}

/// Encodes a UTF-8 string to base64
String base64Enc(String input) {
  final bytes = utf8.encode(input);
  return base64Encode(bytes);
}

/// Decodes a base64 string back to UTF-8 string
String base64Dec(String input) {
  final bytes = base64Decode(input);
  return utf8.decode(bytes);
}

/// Encodes a Uint8List to base64 string
String base64EncBytes(Uint8List input) {
  return base64Encode(input);
}

/// Decodes a base64 string to Uint8List
Uint8List base64DecBytes(String input) {
  return base64Decode(input);
}
