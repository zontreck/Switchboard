import 'dart:io';

import 'package:libac_dart/nbt/NbtIo.dart';
import 'package:libac_dart/nbt/impl/CompoundTag.dart';

class StorageProvider {
  StorageBackend backend = NullBackend();
}

enum DataTable { Users, FrontHistory }

abstract class StorageBackend {
  Future<void> write(DataTable source, String key, dynamic value);
  Future<dynamic> read(DataTable source, String key);
  Future<void> delete(DataTable source, String key);

  Future<void> initialize();
  String getProviderName();
  Future<bool> contains(DataTable source, String key);
  Future<void> flush();
  bool isDirty();
  void markDirty();
  void clearDirty();
}

class StorageNBT implements StorageBackend {
  bool _dirty = false;
  // Example in-memory structure: { source: { key: value } }
  final Map<DataTable, CompoundTag> _data = {};

  @override
  Future<bool> contains(DataTable source, String key) async {
    return _data[source]?.containsKey(key) ?? false;
  }

  @override
  Future<void> delete(DataTable source, String key) async {
    _data[source]?.remove(key);

    markDirty();
  }

  @override
  String getProviderName() {
    return "NBT";
  }

  @override
  Future<void> initialize() async {
    // Load NBT files into _data
    File users = File("data/${DataTable.Users.name}.nbt");
    if (users.existsSync()) {
      // Load into memory
      _data[DataTable.Users] = (await NbtIo.read(
        "data/${DataTable.Users.name}.nbt",
      )).asCompoundTag();

      _data[DataTable.FrontHistory] = (await NbtIo.read(
        "data/${DataTable.FrontHistory.name}.nbt",
      )).asCompoundTag();
    } else {
      // Create the file
      _data[DataTable.Users] = CompoundTag();
      _data[DataTable.FrontHistory] = CompoundTag();
    }

    markDirty();
  }

  @override
  Future<dynamic> read(DataTable source, String key) async {
    return _data[source]?[key];
  }

  @override
  Future<void> write(DataTable source, String key, dynamic value) async {
    _data.putIfAbsent(source, () => CompoundTag());
    _data[source]![key] = value;

    markDirty();
  }

  @override
  Future<void> flush() async {
    // Flush all files in memory to the disc.
    for (var table in _data.entries) {
      NbtIo.write("data/${table.key.name}.nbt", table.value);
    }

    clearDirty();
  }

  @override
  void clearDirty() {
    _dirty = false;
  }

  @override
  bool isDirty() {
    return _dirty;
  }

  @override
  void markDirty() {
    _dirty = true;
  }
}

class NullBackend implements StorageBackend {
  @override
  Future<void> delete(DataTable source, String key) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<dynamic> read(DataTable source, String key) async {
    return null;
  }

  @override
  Future<void> write(DataTable source, String key, dynamic value) async {}

  @override
  String getProviderName() {
    return "NULL";
  }

  @override
  Future<bool> contains(DataTable source, String key) async {
    return false;
  }

  @override
  void clearDirty() {}

  @override
  Future<void> flush() async {}

  @override
  bool isDirty() {
    return false;
  }

  @override
  void markDirty() {
    // TODO: implement markDirty
  }
}

class StorageSQL implements StorageBackend {
  @override
  Future<bool> contains(DataTable source, String key) {
    // SELECT EXISTS(SELECT 1 FROM source WHERE key = ?)
    throw UnimplementedError();
  }

  @override
  Future<void> delete(DataTable source, String key) {
    // DELETE FROM source WHERE key = ?
    throw UnimplementedError();
  }

  @override
  String getProviderName() {
    return "SQL";
  }

  @override
  Future<void> initialize() async {
    // Initialize DB connection
  }

  @override
  Future<dynamic> read(DataTable source, String key) {
    // SELECT value FROM source WHERE key = ?
    throw UnimplementedError();
  }

  @override
  Future<void> write(DataTable source, String key, dynamic value) {
    // INSERT OR UPDATE source (key, value)
    throw UnimplementedError();
  }

  @override
  void clearDirty() {
    // Not supported by this provider.
  }

  @override
  Future<void> flush() async {
    // Not supported in this provider
  }

  @override
  bool isDirty() {
    return false;
  }

  @override
  void markDirty() {}
}
