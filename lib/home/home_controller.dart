import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicxy/services/music_api_service.dart';
import 'package:musicxy/widget/inspiration_grid.dart';
import 'package:musicxy/player/player_controller.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  String? errorMessage;
  int selectedTab = 0; // 0: Create, 1: My Songs, 2: Player
  String selectedCategory = '';
  String generatedText = '';
  var selectedMood = 'Happy'.obs;

  void setMood(String mood) {
    selectedMood.value = mood;
    update();
  }

  final List<InspirationItem> inspirationItems = [
    InspirationItem(
      title: "Chill Vibes",
      imageUrl: "assets/images/inspirations/Horse on Beach.jpeg",
      prompt:
          "Relaxing chill beats with smooth melodies and calming atmosphere",
    ),
    InspirationItem(
      title: "Lo-Fi Study",
      imageUrl: "assets/images/inspirations/Cyberpunk Alley Cat.jpeg",
      prompt: "Lo-fi hip hop beats to relax and study, mellow background vibes",
    ),
    InspirationItem(
      title: "Epic Soundtrack",
      imageUrl: "assets/images/inspirations/Floating House in Sky.jpeg",
      prompt: "Cinematic orchestral soundtrack with epic strings and drums",
    ),
    InspirationItem(
      title: "Pop Hits",
      imageUrl: "assets/images/inspirations/Robot in Flower Field.jpeg",
      prompt: "Catchy modern pop melodies with upbeat vocals and hooks",
    ),
    InspirationItem(
      title: "Acoustic Sunset",
      imageUrl: "assets/images/inspirations/Girl & Red Balloon.jpeg",
      prompt: "Warm acoustic guitar and soft vocals, perfect for sunset vibes",
    ),
    InspirationItem(
      title: "Synthwave Drive",
      imageUrl: "assets/images/inspirations/Neon Samurai in Rain.jpeg",
      prompt: "Retro synthwave with neon vibes, 80s-inspired driving music",
    ),
    InspirationItem(
      title: "Ocean Chillout",
      imageUrl: "assets/images/inspirations/Underwater Mermaid City.jpeg",
      prompt: "Ambient chillout sounds with waves, soft pads, and ocean vibe",
    ),
    InspirationItem(
      title: "Indie Dreams",
      imageUrl: "assets/images/inspirations/Tiny House on Waterfall Cliff.jpeg",
      prompt: "Dreamy indie rock with guitars, reverb, and emotional vocals",
    ),
    InspirationItem(
      title: "Space Ambient",
      imageUrl: "assets/images/inspirations/Astronaut with Balloons.jpeg",
      prompt: "Ethereal space ambient with synth pads and cosmic textures",
    ),
    InspirationItem(
      title: "Late Night Jazz",
      imageUrl: "assets/images/inspirations/Cyberpunk Cafe at Night.jpeg",
      prompt: "Smooth jazz with saxophone, piano, and late-night lounge mood",
    ),
    InspirationItem(
      title: "Wild Nature",
      imageUrl: "assets/images/inspirations/Wolf Howling on Cliff.jpeg",
      prompt:
          "Tribal drums and nature-inspired instruments with cinematic tone",
    ),
    InspirationItem(
      title: "Fantasy Adventure",
      imageUrl: "assets/images/inspirations/Floating Islands and Crystals.jpeg",
      prompt:
          "Magical fantasy soundtrack with orchestral and epic storytelling",
    ),
    InspirationItem(
      title: "Mystic Forest",
      imageUrl: "assets/images/inspirations/Girl & Giant Fox Spirit.jpeg",
      prompt: "Enchanted forest sounds, ethereal vocals, and atmospheric tones",
    ),
    InspirationItem(
      title: "Electronic Groove",
      imageUrl: "assets/images/inspirations/Robot City Market.jpeg",
      prompt: "Energetic EDM beats with synths and danceable grooves",
    ),
    InspirationItem(
      title: "Dragon Energy",
      imageUrl: "assets/images/inspirations/Dragon Over Ocean Cliff.jpeg",
      prompt: "Epic hybrid orchestral with powerful drums and soaring themes",
    ),
    InspirationItem(
      title: "Zen Garden",
      imageUrl: "assets/images/inspirations/Moonlit Temple Garden.jpeg",
      prompt: "Meditative zen sounds with soft flutes, water, and calm energy",
    ),
    InspirationItem(
      title: "Neon Beats",
      imageUrl: "assets/images/inspirations/Cyber Skater Girl.jpeg",
      prompt: "Futuristic beats with neon vibes, trap/electro fusion",
    ),
    InspirationItem(
      title: "Cute Pop",
      imageUrl: "assets/images/inspirations/Cute Fox in a Teacup.jpeg",
      prompt: "Fun and bubbly J-pop/K-pop inspired upbeat tracks",
    ),
    InspirationItem(
      title: "Cosmic Journey",
      imageUrl: "assets/images/inspirations/Space Whale in Galaxy.jpeg",
      prompt: "Space-inspired ambient music with expansive synth textures",
    ),
    InspirationItem(
      title: "Library Lo-Fi",
      imageUrl: "assets/images/inspirations/Floating Garden Library.jpeg",
      prompt: "Lo-fi piano and beats, cozy background music for reading",
    ),
    InspirationItem(
      title: "Desert Beats",
      imageUrl: "assets/images/inspirations/Desert Caravan at Dusk.jpeg",
      prompt: "Middle-eastern inspired beats with desert atmosphere",
    ),
    InspirationItem(
      title: "Night Drive",
      imageUrl: "assets/images/inspirations/Cyberpunk Street Racer.jpeg",
      prompt: "Moody synthwave and chill electronic for night driving",
    ),
    InspirationItem(
      title: "Forest Calm",
      imageUrl: "assets/images/inspirations/Ghibli Forest Path.jpeg",
      prompt: "Relaxing ambient sounds with birds, streams, and soft pads",
    ),
    InspirationItem(
      title: "Mecha Beats",
      imageUrl: "assets/images/inspirations/3D Mecha Robot.jpeg",
      prompt: "Industrial electronic beats with heavy synth and robotic vibe",
    ),
    InspirationItem(
      title: "Rainy Mood",
      imageUrl: "assets/images/inspirations/Anime Girl in Rain.jpeg",
      prompt: "Emotional piano and soft beats with rain ambiance",
    ),
    InspirationItem(
      title: "Peaceful Lake",
      imageUrl: "assets/images/inspirations/Ghibli Tranquil Lake.jpeg",
      prompt: "Calm nature-inspired instrumental with water and soft strings",
    ),
    InspirationItem(
      title: "Future Metro",
      imageUrl: "assets/images/inspirations/3D Futuristic Train.jpeg",
      prompt: "Fast-paced futuristic techno beats with metro vibe",
    ),
    InspirationItem(
      title: "Hacker Beats",
      imageUrl: "assets/images/inspirations/Cyberpunk Hacker Den.jpeg",
      prompt: "Dark cyberpunk beats with glitchy electronic textures",
    ),
    InspirationItem(
      title: "Tea House Jazz",
      imageUrl: "assets/images/inspirations/Ghibli Tea House.jpeg",
      prompt: "Soft traditional instruments with relaxing jazz elements",
    ),
    InspirationItem(
      title: "Epic Armory",
      imageUrl: "assets/images/inspirations/3D Fantasy Armory.jpeg",
      prompt: "Heroic battle soundtrack with drums, brass, and choir",
    ),
    InspirationItem(
      title: "Drone Chase",
      imageUrl: "assets/images/inspirations/Cyberpunk Drone Chase.jpeg",
      prompt: "Fast electronic beats with futuristic chase sequence vibe",
    ),
    InspirationItem(
      title: "Mountain Folk",
      imageUrl: "assets/images/inspirations/Ghibli Mountain Village.jpeg",
      prompt: "Acoustic folk instruments with mountain village feel",
    ),
    InspirationItem(
      title: "Ice Kingdom",
      imageUrl: "assets/images/inspirations/3D Ice Castle.jpeg",
      prompt: "Chilly orchestral sounds with icy, majestic atmosphere",
    ),
    InspirationItem(
      title: "Street Food Beats",
      imageUrl: "assets/images/inspirations/Cyberpunk Street Food Stall.jpeg",
      prompt: "Urban world music inspired by bustling food streets",
    ),
    InspirationItem(
      title: "Autumn Calm",
      imageUrl: "assets/images/inspirations/Ghibli Autumn Bridge.jpeg",
      prompt: "Warm acoustic tones with autumn leaves and cozy mood",
    ),
    InspirationItem(
      title: "Sky Airship",
      imageUrl: "assets/images/inspirations/3D Steampunk Airship.jpeg",
      prompt: "Adventure orchestral with steampunk-inspired brass",
    ),
    InspirationItem(
      title: "Neon Portrait",
      imageUrl: "assets/images/inspirations/Cyberpunk Neon Portrait.jpeg",
      prompt: "Moody synthwave portrait music with deep neon bass",
    ),
  ];

  @override
  void onInit() {
    super.onInit();
  }

  void switchTab(int index) {
    if(index != 2){    selectedTab = index;
}
    isLoading = false; // Hide loader when switching tabs
    // Auto-load the requested track when opening Player tab (only if no song is currently loaded)
    if (index == 2) {
      Get.toNamed('/player');
      try {
        final player = Get.find<PlayerController>();
        // Only play default song if no song is currently loaded/playing
        if (player.currentTitle.value.isEmpty ||
            player.currentTitle.value == '') {
          player.playUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            title: 'SoundHelix Song 1',
          );
        }
      } catch (_) {}
    }
    update();
  }

  void setPrompt(String value) {
    prompt = value;
    update();
  }

  String prompt = '';

  Future<void> generateMusic({String? category, String? style}) async {
    print('🚀 [HomeController] Starting music generation...');
    print('📝 [HomeController] Prompt: "$prompt"');
    print('🎵 [HomeController] Selected Mood: ${selectedMood.value}');
    print('🎨 [HomeController] Style: $style');

    if (prompt.trim().isEmpty) {
      print('❌ [HomeController] Prompt is empty, showing error');
      errorMessage = 'Please describe what kind of music you want.';
      update();
      Future.delayed(const Duration(seconds: 2), clearError);
      return;
    }

    print('⏳ [HomeController] Setting loading state...');
    isLoading = true;
    errorMessage = null;
    update();

    try {
      print('🌐 [HomeController] Calling MusicApiService.generateMusic...');

      // Combine prompt and mood for style
      String musicStyle = prompt;
      if (style != null && style.isNotEmpty) {
        musicStyle = '$prompt in $style style';
      }

      print("music style is : {$musicStyle}");

      final musicFilePath = await MusicApiService.generateMusic(
        mood: selectedMood.value,
        style: musicStyle,
      );

      print('✅ [HomeController] Successfully generated music: $musicFilePath');

      // Navigate to player screen and auto-play the generated music
      print('🔄 [HomeController] Switching to player tab...');
      switchTab(2); // Switch to player tab

      // Load the generated music in the player
      try {
        final player = Get.find<PlayerController>();
        final displayName = MusicApiService.getDisplayName(musicFilePath);
        await player.playLocalFile(musicFilePath, title: displayName);
        print('🎵 [HomeController] Started playing generated music');
      } catch (e) {
        print('⚠️ [HomeController] Error loading player: $e');
      }

      Get.snackbar(
        'Success! 🎵',
        'Your music is ready and playing!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('💥 [HomeController] Error during music generation: $e');
      print('💥 [HomeController] Error type: ${e.runtimeType}');
      errorMessage = 'Failed to generate music: ${e.toString()}';
      update();
      Get.snackbar(
        'Error',
        'Failed to generate music. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      print('🏁 [HomeController] Finishing music generation process');
      isLoading = false;
      update();
    }
  }

  void clearError() {
    errorMessage = null;
    update();
  }
}
