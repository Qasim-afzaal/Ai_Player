import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:musicxy/api/api.dart';

class MusicApiService {
  /// Generate music based on mood and style using the API service
  static Future<String> generateMusic({
    required String mood,
    required String style,
  }) async {
    try {
      print('🎵 [MusicAPI] Generating music...');
      print('🎵 [MusicAPI] Mood: $mood');
      print('🎵 [MusicAPI] Style: $style');

      // Use the ApiService for the request
      final response = await ApiService.post(
        '/generate-music',
        body: {'mood': mood, 'style': style},
      );

      print('📊 [MusicAPI] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // The response body contains the binary music file
        final audioBytes = response.bodyBytes;
        print('💾 [MusicAPI] Received ${audioBytes.length} bytes');

        // Check if we actually received a music file (not JSON error)
        if (audioBytes.length < 100) {
          // Probably an error message, not a music file
          final errorText = String.fromCharCodes(audioBytes);
          print('❌ [MusicAPI] Received error instead of music: $errorText');
          throw Exception('Music generation failed: $errorText');
        }

        // Save the audio file to local storage
        final filePath = await _saveAudioFile(audioBytes, mood, style);
        print('✅ [MusicAPI] Music saved to: $filePath');

        return filePath;
      } else {
        print('❌ [MusicAPI] Error: ${response.statusCode}');
        print('❌ [MusicAPI] Response: ${response.body}');

        // Try to parse error message from response
        String errorMessage = 'Unknown error occurred';
        try {
          if (response.body.isNotEmpty) {
            // If response contains JSON error, extract it
            if (response.body.contains('detail')) {
              errorMessage = response.body;
            } else {
              errorMessage = response.body;
            }
          }
        } catch (e) {
          // If parsing fails, use raw response
          errorMessage = response.body;
        }

        throw Exception(
          'Failed to generate music (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      print('💥 [MusicAPI] Exception: $e');

      // If API fails, show a meaningful error to user
      if (e.toString().contains('500') ||
          e.toString().contains('Music generation failed')) {
        throw Exception(
          '🎵 The music server is currently experiencing issues. Please try again in a few moments, or try a different style.',
        );
      }

      rethrow;
    }
  }

  /// Generate demo music for testing (when API is down)
  static Future<String> generateDemoMusic({
    required String mood,
    required String style,
  }) async {
    try {
      print('🎵 [MusicAPI] Generating DEMO music...');

      // For demo, create a reference to an online demo track
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/generated_music');

      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'demo_${mood}_${style}_$timestamp.txt';
      final file = File('${musicDir.path}/$filename');

      // Create a placeholder file with demo URL
      const demoUrl =
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      await file.writeAsString(demoUrl);

      return file.path;
    } catch (e) {
      print('💥 [MusicAPI] Demo generation failed: $e');
      rethrow;
    }
  }

  /// Save audio bytes to a local file
  static Future<String> _saveAudioFile(
    Uint8List audioBytes,
    String mood,
    String style,
  ) async {
    try {
      // Get the app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/generated_music');

      // Create directory if it doesn't exist
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedMood = mood
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final sanitizedStyle = style
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final filename =
          'music_${sanitizedMood}_${sanitizedStyle}_$timestamp.wav';
      final file = File('${musicDir.path}/$filename');

      // Write the audio data
      await file.writeAsBytes(audioBytes);

      return file.path;
    } catch (e) {
      print('💥 [MusicAPI] Error saving file: $e');
      throw Exception('Failed to save music file: $e');
    }
  }

  /// Get list of generated music files
  static Future<List<String>> getGeneratedMusicFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/generated_music');

      if (!await musicDir.exists()) {
        return [];
      }

      final files = await musicDir.list().toList();
      final musicFiles = files
          .where((file) => file is File && file.path.endsWith('.wav'))
          .map((file) => file.path)
          .toList();

      // Sort by creation time (newest first)
      musicFiles.sort(
        (a, b) =>
            File(b).lastModifiedSync().compareTo(File(a).lastModifiedSync()),
      );

      return musicFiles;
    } catch (e) {
      print('💥 [MusicAPI] Error getting music files: $e');
      return [];
    }
  }

  /// Delete a generated music file
  static Future<bool> deleteGeneratedMusic(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('💥 [MusicAPI] Error deleting file: $e');
      return false;
    }
  }

  /// Get file name from path for display
  static String getDisplayName(String filePath) {
    final fileName = filePath.split('/').last;
    // Remove file extension and timestamp, format for display
    return fileName
        .replaceAll('.wav', '')
        .replaceAll('music_', '')
        .replaceAll(RegExp(r'_\d+$'), '') // Remove timestamp
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}
