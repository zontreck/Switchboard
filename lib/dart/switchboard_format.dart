import 'package:libac_dart/nbt/NbtUtils.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';
import 'package:libac_dart/nbt/impl/StringTag.dart';
import 'package:libac_dart/utils/uuid/NbtUUID.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';

class SwitchboardUser {
  UUID userID = UUID.ZERO;
  String? description = "";
  String? avatarURL = "";

  Map<String, dynamic> toJson() {
    return {
      "id": userID.toString(),
      "description": description,
      "avatar_url": avatarURL,
    };
  }

  CompoundTag toNBT() {
    CompoundTag ct = CompoundTag();
    NbtUtils.writeUUID(ct, "id", NbtUUID.fromUUID(userID));
    ct.put("description", StringTag.valueOf(description ?? ""));
    ct.put("avatar", StringTag.valueOf(avatarURL ?? ""));

    return ct;
  }
}
