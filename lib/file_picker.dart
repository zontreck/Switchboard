import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:switchboard/globalHelpers.dart';

class FileLoader {
  /// Opens the appropriate file browser, then returns the contents of a selected file, or null if the user cancelled selection.
  static Future<Uint8List?> getFile({
    BuildContext? context,
    required List<String> allowedExtensions,
    required bool photos,
    required bool camera,
  }) async {
    bool perm = await checkStoragePermissions(camera: camera, photos: photos);
    if (!perm) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Storage permissions are denied currently. Please grant them before you can proceed.",
            ),
          ),
        );
      }
      return null;
    }

    FileType selType = FileType.custom;
    List<String>? exts = allowedExtensions;
    if (Capabilities.requiresMedia) {
      if (photos || camera) {
        selType = FileType.image;
        exts = null;
      }
    }

    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      allowedExtensions: exts,
      type: selType,
      withData: true,
    );

    if (result == null) return null;

    return result.files.first.bytes;
  }
}
