import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/core/global/globals.dart';

import '../../presentation/provider/favorites_provider.dart';
// For accessing directories like Downloads

class BackupService {
  BackupService();

  Future<void> createBackup() async {
    var provider = SMA.navigationKey.currentContext!.read<FavoritesProvider>();

    if (Platform.isAndroid && !await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    try {
      // Let the user pick the save location for the backup
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName:
            'favorites_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.db',
        type: FileType.any,
      );

      if (outputPath == null) {
        return; // Exit if the user cancels the file picker
      }

      // Check if the output path is valid
      final outputFile = File(outputPath);
      if (!await outputFile.parent.exists()) {
        // If the parent directory does not exist, create it
        await outputFile.parent.create(recursive: true);
      }

      String tempBackupPath =
          await provider.createBackup(); // Create the temporary backup file

      final tempFile = File(tempBackupPath);
      final dbBytes = await tempFile.readAsBytes();

      // Write the backup file to the chosen location
      await outputFile.writeAsBytes(dbBytes);

      // Optionally, delete the temporary backup file if needed
      await tempFile.delete();

      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Backup saved successfully to: $outputPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to create backup: $e')),
      );
    }
  }

  Future<void> restoreBackup() async {
    var provider = SMA.navigationKey.currentContext!.read<FavoritesProvider>();
    if (Platform.isAndroid && !await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return; // Return early if permission is denied
    }

    try {
      // Let the user pick the backup file from the Downloads folder
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.any,
        allowedExtensions: ['db'],
        initialDirectory: await _getDownloadsDirectory()
            .then((v) => v!.path), // Default to Downloads folder
      );

      if (result == null || result.files.isEmpty) {
        return; // Exit if no file is selected
      }

      String backupPath = result.files.single.path!;

      // Confirm the restore action with the user
      bool? confirm = await showDialog<bool>(
        context: SMA.navigationKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Restore Backup'),
          content: const Text(
              'Are you sure you want to restore from this backup? This will overwrite your current data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirm != true) return; // Exit if the user cancels the action

      // Read the selected backup file
      final backupFile = File(backupPath);
      final backupBytes = await backupFile.readAsBytes();

      // Write the backup file to a temporary directory
      final tempDir = Directory.systemTemp;
      final tempDbPath = '${tempDir.path}/temp_restore.db';
      final tempDbFile = File(tempDbPath);
      await tempDbFile.writeAsBytes(backupBytes);

      // Call the provider to restore the backup
      await provider.restoreBackup(tempDbPath);

      await tempDbFile.delete(); // Clean up the temporary restore file

      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to restore backup: $e')),
      );
    }
  }

  // Method to get the Downloads directory for Android
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      // For Android 10 and above, use the public Downloads directory
      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing Downloads directory: $e');
      }
    }
    return null; // Return null if Downloads directory cannot be accessed
  }
}
