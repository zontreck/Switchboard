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
