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
