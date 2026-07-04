import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:switchboard/globalHelpers.dart';

class FileLoader {
  /// Opens the appropriate file browser, then returns the contents of a selected file, or null if the user cancelled selection.
  static Future<Uint8List?> getFile({
    BuildContext? context,
    required List<String> allowedExtensions,
  }) async {
    bool perm = await checkStoragePermissions();
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

    // Get the platform
    if (kIsWeb) {
      // All other platforms get ignored by this special handler.
    }
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
      type: FileType.custom,
      withData: true,
    );

    if (result == null) return null;

    return result.files.first.bytes;
  }
}
