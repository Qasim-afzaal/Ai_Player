import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicxy/player/player_controller.dart';
import 'package:musicxy/services/music_api_service.dart';

class PlayerScreen extends GetView<PlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF181824),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // App header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Now Playing",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Album Art - takes proportional height
            Container(
              height: size.height * 0.35,
              width: size.height * 0.35,
              decoration: BoxDecoration(
                color: const Color(0xFF252537),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 20),

            // Song Title
            Obx(
              () => Text(
                controller.currentTitle.value.isEmpty
                    ? 'No track selected'
                    : controller.currentTitle.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress bar
            Obx(() {
              final pos = controller.position.value;
              final dur = controller.duration.value;
              final max = dur.inMilliseconds > 0
                  ? dur.inMilliseconds.toDouble()
                  : 1.0;
              final val = pos.inMilliseconds.clamp(0, max).toDouble();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Slider(
                      value: val,
                      min: 0,
                      max: max,
                      activeColor: const Color(0xFFB16CEA),
                      onChanged: (v) =>
                          controller.seek(Duration(milliseconds: v.round())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(pos),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _fmt(dur),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // Playback controls row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ✅ Loop button
                  Obx(
                    () => IconButton(
                      onPressed: controller.toggleLoop,
                      icon: Icon(
                        controller.isLooping.value
                            ? Icons
                                  .repeat_one // loop active
                            : Icons.repeat, // loop off
                        color: controller.isLooping.value
                            ? const Color(0xFFB16CEA) // highlighted when active
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => controller.seek(
                      controller.position.value - const Duration(seconds: 10),
                    ),
                    icon: const Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Play / Pause
                  Obx(
                    () => CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFB16CEA),
                      child: IconButton(
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: controller.togglePlayPause,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => controller.seek(
                      controller.position.value + const Duration(seconds: 10),
                    ),
                    icon: const Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Playlist button
                  IconButton(
                    onPressed: () => _showPlaylist(context),
                    icon: const Icon(
                      Icons.queue_music,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Playlist Bottom Sheet
  void _showPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252537),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.5; // half screen

        return SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "My Songs",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable song list
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: MusicApiService.getGeneratedMusicFiles(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFB16CEA),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading songs',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      final musicFiles = snapshot.data ?? [];

                      if (musicFiles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.music_off,
                                color: Colors.white38,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No songs generated yet',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Go to Create tab to generate music',
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: musicFiles.length,
                        itemBuilder: (context, index) {
                          final filePath = musicFiles[index];
                          final displayName = MusicApiService.getDisplayName(
                            filePath,
                          );
                          final isCurrentSong =
                              controller.currentTitle.value == displayName;

                          return _MusicTrackTile(
                            title: displayName,
                            filePath: filePath,
                            isCurrentSong: isCurrentSong,
                            onTap: (title, path) {
                              controller.playLocalFile(path, title: title);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
}

class _MusicTrackTile extends StatelessWidget {
  final String title;
  final String filePath;
  final bool isCurrentSong;
  final void Function(String title, String filePath) onTap;

  const _MusicTrackTile({
    required this.title,
    required this.filePath,
    required this.isCurrentSong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentSong
            ? const Color(0xFFB16CEA).withOpacity(0.2)
            : Colors.transparent,
        border: isCurrentSong
            ? Border.all(color: const Color(0xFFB16CEA), width: 1)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isCurrentSong
                  ? [const Color(0xFFB16CEA), const Color(0xFFFF5E69)]
                  : [Colors.white24, Colors.white12],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            isCurrentSong ? Icons.music_note : Icons.play_arrow,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isCurrentSong ? const Color(0xFFB16CEA) : Colors.white,
            fontSize: 14,
            fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isCurrentSong ? 'Now Playing' : 'Tap to play',
          style: GoogleFonts.poppins(
            color: isCurrentSong
                ? const Color(0xFFB16CEA).withOpacity(0.7)
                : Colors.white54,
            fontSize: 12,
          ),
        ),
        trailing: isCurrentSong
            ? const Icon(Icons.equalizer, color: Color(0xFFB16CEA), size: 20)
            : null,
        onTap: () => onTap(title, filePath),
      ),
    );
  }
}
