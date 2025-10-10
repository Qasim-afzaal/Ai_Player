import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicxy/services/music_api_service.dart';
import 'package:musicxy/player/player_controller.dart';
import 'package:musicxy/home/home_controller.dart';

class MyMusicController extends GetxController {
  final RxList<String> musicFiles = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, String> fileSizeCache = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMusicFiles();
  }

  Future<void> loadMusicFiles() async {
    try {
      isLoading.value = true;
      fileSizeCache.clear(); // Clear cache to recalculate

      final files = await MusicApiService.getGeneratedMusicFiles();
      musicFiles.value = files;

      // Calculate file sizes for all files
      for (final filePath in files) {
        final size = _calculateFileSize(filePath);
        fileSizeCache[filePath] = size;
        print('🎵 Loaded file: ${filePath.split('/').last} - Size: $size');
      }
    } catch (e) {
      print('Error loading music files: $e');
      Get.snackbar(
        'Error',
        'Failed to load music files',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void playMusic(String filePath) async {
    try {
      final player = Get.find<PlayerController>();
      final displayName = MusicApiService.getDisplayName(filePath);

      // Start playing the song first
      await player.playLocalFile(filePath, title: displayName);

      // Then switch to player tab after a small delay to ensure song is loaded
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          final homeController = Get.find<HomeController>();
          homeController.switchTab(2); // Switch to player tab (index 2)
        } catch (e) {
          print('Could not switch to player tab: $e');
        }
      });

      Get.snackbar(
        'Now Playing 🎵',
        displayName,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play music',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void deleteMusic(String filePath) {
    try {
      MusicApiService.deleteGeneratedMusic(filePath);
      musicFiles.remove(filePath);
      Get.snackbar(
        'Deleted',
        'Music file deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete music file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearAllMusic() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Clear All Music',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete all generated music files?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <Widget>[
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                for (final filePath in musicFiles) {
                  await MusicApiService.deleteGeneratedMusic(filePath);
                }
                musicFiles.clear();
                Get.back();
                Get.snackbar(
                  'Success',
                  'All music files deleted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Error',
                  'Failed to delete some files',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(String filePath) {
    final displayName = MusicApiService.getDisplayName(filePath);
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Music',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$displayName"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: <Widget>[
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              deleteMusic(filePath);
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  String getDisplayName(String filePath) {
    return MusicApiService.getDisplayName(filePath);
  }

  String getFileSize(String filePath) {
    // Return cached size if available
    if (fileSizeCache.containsKey(filePath)) {
      return fileSizeCache[filePath]!;
    }

    // Calculate and cache if not available
    final size = _calculateFileSize(filePath);
    fileSizeCache[filePath] = size;
    return size;
  }

  String _calculateFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File does not exist: $filePath');
        return 'Not found';
      }

      final bytes = file.lengthSync();
      final fileName = file.path.split('/').last;

      // More detailed logging
      print('� Checking file: $fileName');
      print('📂 Full path: $filePath');
      print('📊 Raw bytes: $bytes');

      if (bytes == 0) {
        print('⚠️ File is empty!');
        return '0B';
      }

      // More precise calculation with better rounding
      if (bytes < 1024) {
        print('💾 Size category: Bytes');
        return '${bytes}B';
      } else if (bytes < 1024 * 1024) {
        final kb = bytes / 1024;
        print('💾 Size category: Kilobytes ($kb KB)');
        return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)}KB';
      } else {
        final mb = bytes / (1024 * 1024);
        print('💾 Size category: Megabytes ($mb MB)');
        // Show more precision for smaller MB values
        if (mb < 10) {
          return '${mb.toStringAsFixed(2)}MB';
        } else {
          return '${mb.toStringAsFixed(1)}MB';
        }
      }
    } catch (e) {
      print('💥 Error calculating size for $filePath: $e');
      print('💥 Error type: ${e.runtimeType}');
      return 'Error';
    }
  }

  String getCreationDate(String filePath) {
    try {
      final file = File(filePath);
      final date = file.lastModifiedSync();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
