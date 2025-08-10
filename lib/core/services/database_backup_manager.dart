import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/database/local_database.dart';

class DatabaseBackupManager {
  static final DatabaseBackupManager _instance = DatabaseBackupManager._init();
  static DatabaseBackupManager get instance => _instance;

  DatabaseBackupManager._init();

  /// FIXED: Robust file selection with multiple fallback strategies
  Future<String?> _selectBackupFileRobust() async {
    try {
      // Strategy 1: Try with most common database extensions
      FilePickerResult? result = await _tryPickFilesWithExtensions(['db']);

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }

      // Strategy 2: Try with generic file types that usually work
      result = await _tryPickFilesWithExtensions(['sqlite']);

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }

      // Strategy 3: Use FileType.any and let user choose any file
      result = await _useAnyFileType();

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        // Validate the selected file is a valid backup
        if (await _isValidBackupFile(filePath)) {
          return filePath;
        } else {
          throw Exception('Selected file is not a valid backup database');
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('All file selection strategies failed: $e');
      }

      // Last resort: Show user a dialog with instructions
      return await _showManualSelectionInstructions();
    }
  }

  /// Try picking files with specific extensions
  Future<FilePickerResult?> _tryPickFilesWithExtensions(
      List<String> extensions) async {
    try {
      if (kDebugMode) {
        print('Trying file picker with extensions: $extensions');
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions, // Extensions without dots
        allowMultiple: false,
        dialogTitle: 'Select Backup File',
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to pick files with extensions $extensions: $e');
      }
      return null;
    }
  }

  /// Use FileType.any as fallback
  Future<FilePickerResult?> _useAnyFileType() async {
    try {
      if (kDebugMode) {
        print('Using FileType.any as fallback');
      }

      return await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: 'Select Any Backup File (We will validate it)',
      );
    } catch (e) {
      if (kDebugMode) {
        print('FileType.any also failed: $e');
      }
      return null;
    }
  }

  /// Show manual selection instructions
  Future<String?> _showManualSelectionInstructions() async {
    // This would show a dialog to user with instructions
    // For now, return null - you can implement UI dialog here
    if (kDebugMode) {
      print('File picker completely failed. Need manual file selection.');
    }
    return null;
  }

  /// Enhanced backup file validation
  Future<bool> _isValidBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      // Check if file has reasonable size (not empty, not too large)
      final stats = await file.stat();
      if (stats.size < 100) return false; // Too small to be a real database
      if (stats.size > 100 * 1024 * 1024)
        return false; // Larger than 100MB is suspicious

      // Try to open as SQLite database
      try {
        final db = await openDatabase(filePath, readOnly: true);

        // Check if it has required tables
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );

        final tableNames = tables.map((t) => t['name'] as String).toList();
        final hasRequiredTables = tableNames.contains('favorites');

        await db.close();

        if (kDebugMode) {
          print(
              'Database validation: hasRequiredTables=$hasRequiredTables, tables=$tableNames');
        }

        return hasRequiredTables;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to validate as SQLite database: $e');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in backup file validation: $e');
      }
      return false;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Create backup (this should work fine as it doesn't use file picker)
  Future<BackupResult> createEnhancedBackup({
    String? customName,
    BackupLocation location = BackupLocation.downloads,
    bool includeMetadata = true,
  }) async {
    try {
      final hasPermission = await _checkStoragePermissions();
      if (!hasPermission) {
        return BackupResult.error('Storage permission denied');
      }

      final timestamp = DateTime.now();
      final fileName = customName?.isNotEmpty == true
          ? '${customName}_${_formatTimestamp(timestamp)}.db'
          : 'favorites_backup_${_formatTimestamp(timestamp)}.db';

      final backupDir = await _getBackupDirectory(location);
      final backupPath = join(backupDir.path, fileName);

      final db = await LocalDatabase.instance.database;
      final dbFile = File(db.path);

      if (!await dbFile.exists()) {
        return BackupResult.error('Database file not found');
      }

      // Copy database file
      await dbFile.copy(backupPath);

      if (kDebugMode) {
        print('✅ Backup created successfully at: $backupPath');
      }

      // Create basic metadata
      final metadata = BackupMetadata(
        fileName: fileName,
        createdAt: timestamp,
        size: await File(backupPath).length(),
        itemCount: await LocalDatabase.instance.getTotalFavoritesCount(),
        version: '1.0',
        deviceInfo: {},
      );

      return BackupResult.success(backupPath, metadata);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Backup creation failed: $e');
      }
      return BackupResult.error('Failed to create backup: $e');
    }
  }

  // ... [Keep other helper methods the same] ...

  Future<bool> _checkStoragePermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<Directory> _getBackupDirectory(BackupLocation location) async {
    Directory baseDir;

    switch (location) {
      case BackupLocation.downloads:
        baseDir = await getDownloadsDirectory() ??
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        break;
      case BackupLocation.documents:
        baseDir = await getApplicationDocumentsDirectory();
        break;
      case BackupLocation.external:
        baseDir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        break;
    }

    final backupDir = Directory(join(baseDir.path, 'FavoritesBackups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  String _formatTimestamp(DateTime timestamp) {
    return timestamp
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '_')
        .substring(0, 19);
  }

  Future<RestoreResult> _performRestoreWithLogic(
      String backupPath, BackupMetadata? metadata) async {
    try {
      if (kDebugMode) {
        print('🔄 Starting database replacement...');
      }

      // Step 1: Close current database connection
      await LocalDatabase.instance.close();
      if (kDebugMode) {
        print('✅ Closed current database connection');
      }

      // Step 2: Get database paths
      final dbPath = await getDatabasesPath();
      final currentDbPath = join(dbPath, 'favorites.db');

      // Step 3: Create backup of current database before replacement
      final currentDb = File(currentDbPath);
      if (await currentDb.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupCurrentPath =
            '$currentDbPath.backup_before_restore_$timestamp';
        await currentDb.copy(backupCurrentPath);

        if (kDebugMode) {
          print('✅ Created backup of current database: $backupCurrentPath');
        }
      }

      // Step 4: Validate backup file exists and is readable
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file no longer exists: $backupPath');
      }

      // Step 5: Replace current database with backup
      if (await currentDb.exists()) {
        await currentDb.delete();
        if (kDebugMode) {
          print('🗑️ Deleted current database');
        }
      }

      await backupFile.copy(currentDbPath);
      if (kDebugMode) {
        print('📁 Copied backup to database location');
      }

      // Step 6: Verify the replacement was successful
      try {
        final testDb = await openDatabase(currentDbPath, readOnly: true);

        // Check if required tables exist
        final tables = await testDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );

        final tableNames = tables.map((t) => t['name'] as String).toList();
        final hasRequiredTables = tableNames.contains('favorites');

        await testDb.close();

        if (!hasRequiredTables) {
          throw Exception('Restored database is missing required tables');
        }

        if (kDebugMode) {
          print('✅ Database replacement verification successful');
        }
      } catch (e) {
        throw Exception('Database replacement verification failed: $e');
      }

      // Step 7: Reinitialize database connection
      await LocalDatabase.instance.database;
      if (kDebugMode) {
        print('🔌 Reinitialized database connection');
      }

      // Step 8: Get final count to confirm success
      final totalItems = await LocalDatabase.instance.getTotalFavoritesCount();

      if (kDebugMode) {
        print('🎉 Database replacement completed successfully!');
        print('📊 Total items in new database: $totalItems');
      }

      return RestoreResult.success(totalItems, metadata);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Database replacement failed: $e');
      }

      // Try to restore original database if replacement failed
      try {
        final dbPath = await getDatabasesPath();
        final currentDbPath = join(dbPath, 'favorites.db');

        // Find the most recent backup
        final dbDir = Directory(dirname(currentDbPath));
        final backupFiles = dbDir
            .listSync()
            .where(
                (file) => basename(file.path).contains('backup_before_restore'))
            .cast<File>()
            .toList();

        if (backupFiles.isNotEmpty) {
          backupFiles.sort(
              (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
          await backupFiles.first.copy(currentDbPath);
          await LocalDatabase.instance.database; // Reinitialize

          if (kDebugMode) {
            print('🔄 Restored original database after failed replacement');
          }
        }
      } catch (restoreError) {
        if (kDebugMode) {
          print('❌ Failed to restore original database: $restoreError');
        }
      }

      return RestoreResult.error('Database replacement failed: $e');
    }
  }

  Future<RestoreResult> restoreFromSelectedBackupWithLogic({
    BuildContext? context,
    bool showConfirmation = true,
  }) async {
    try {
      // Step 1: Let user select backup file
      final selectedFile = await _selectBackupFileRobust();
      if (selectedFile == null) {
        return RestoreResult.cancelled();
      }

      if (kDebugMode) {
        print('📁 Selected backup file: $selectedFile');
      }

      // Step 2: Validate backup file
      if (!await _isValidBackupFile(selectedFile)) {
        return RestoreResult.error(
            'The selected file is not a valid backup database.\n\n'
            'Please ensure you select a .db file that was created by this app.');
      }

      // Step 3: Show confirmation dialog if context provided
      if (context != null && showConfirmation) {
        final confirmed =
            await _showRestoreConfirmationDialog(context, selectedFile);
        if (!confirmed) {
          return RestoreResult.cancelled();
        }
      }

      // Step 4: Perform the actual database replacement
      final result = await _performRestoreWithLogic(selectedFile, null);

      // Step 5: Show success/failure feedback
      if (context != null) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ Database replaced successfully!\n${result.restoredItemCount} favorites restored.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '❌ Replacement failed: ${result.error}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Restore process failed: $e');
      }
      return RestoreResult.error('Restore process failed: ${e.toString()}');
    }
  }

  Future<bool> _showRestoreConfirmationDialog(
      BuildContext context, String backupPath) async {
    final file = File(backupPath);
    final stats = await file.stat();
    final currentItemCount =
        await LocalDatabase.instance.getTotalFavoritesCount();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.swap_horizontal_circle_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  const Text('Replace Database'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current vs New comparison
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.1),
                            Colors.orange.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.delete_forever,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Current Database ($currentItemCount items)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Icon(Icons.keyboard_double_arrow_down_rounded,
                              color: Colors.orange),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.restore_rounded,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Backup Database (${basename(backupPath)})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildInfoRow('File:', basename(backupPath)),
                    _buildInfoRow('Size:', _formatBytes(stats.size)),
                    _buildInfoRow('Modified:', _formatDate(stats.modified)),

                    const SizedBox(height: 16),

                    // Final warning
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_rounded,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your current database will be permanently replaced. This cannot be undone!',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context)
                        .pop(false); // Return false = cancelled
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, size: 16),
                      const SizedBox(width: 6),
                      const Text('Cancel'),
                    ],
                  ),
                ),

                // Replace Database Button - THIS IS THE MAIN LOGIC
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Strong haptic feedback for important action
                      HapticFeedback.heavyImpact();

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      // Close loading dialog and confirmation dialog
                      Navigator.of(context).pop(); // Close loading
                      Navigator.of(context)
                          .pop(true); // Return true = confirmed
                    } catch (e) {
                      // If there's an error, close loading and stay on dialog
                      Navigator.of(context).pop(); // Close loading

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz_rounded, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Replace Database',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

// Keep all your existing supporting classes...
enum BackupLocation { downloads, documents, external }

class BackupMetadata {
  final String fileName;
  final DateTime createdAt;
  final int size;
  final int itemCount;
  final Map<String, int>? itemCountsByType;
  final String version;
  final Map<String, dynamic> deviceInfo;

  BackupMetadata({
    required this.fileName,
    required this.createdAt,
    required this.size,
    required this.itemCount,
    this.itemCountsByType,
    required this.version,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'size': size,
        'itemCount': itemCount,
        'itemCountsByType': itemCountsByType,
        'version': version,
        'deviceInfo': deviceInfo,
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
        fileName: json['fileName'],
        createdAt: DateTime.parse(json['createdAt']),
        size: json['size'],
        itemCount: json['itemCount'],
        itemCountsByType: json['itemCountsByType']?.cast<String, int>(),
        version: json['version'],
        deviceInfo: json['deviceInfo'],
      );
}

class BackupResult {
  final bool isSuccess;
  final String? filePath;
  final BackupMetadata? metadata;
  final String? error;

  BackupResult.success(this.filePath, this.metadata)
      : isSuccess = true,
        error = null;

  BackupResult.error(this.error)
      : isSuccess = false,
        filePath = null,
        metadata = null;
}

class RestoreResult {
  final bool isSuccess;
  final bool isCancelled;
  final int? restoredItemCount;
  final BackupMetadata? metadata;
  final String? error;

  RestoreResult.success(this.restoredItemCount, this.metadata)
      : isSuccess = true,
        isCancelled = false,
        error = null;

  RestoreResult.error(this.error)
      : isSuccess = false,
        isCancelled = false,
        restoredItemCount = null,
        metadata = null;

  RestoreResult.cancelled()
      : isSuccess = false,
        isCancelled = true,
        restoredItemCount = null,
        metadata = null,
        error = null;
}
