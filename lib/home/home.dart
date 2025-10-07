import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicxy/home/home_controller.dart';
import 'package:musicxy/my_music/my_music_screen.dart';
import 'package:musicxy/paywall_screen.dart';
import 'package:musicxy/player/player_screen.dart';
import 'package:musicxy/services/analytics_helper.dart';
import 'package:musicxy/widget/bottom_nav_bar.dart';
import 'package:musicxy/widget/inspiration_grid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('HomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (HomeController controller) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFF181824),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Music Mood Mix',
                            style: GoogleFonts.poppins(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              AnalyticsHelper.logButtonTap(
                                'pro_button',
                                screenName: 'HomeScreen',
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PaywallScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Pro',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
              body: controller.selectedTab == 0
                  ? _buildMusicGenerationTab(context, controller)
                  : MyMusicScreen(),

              bottomNavigationBar: controller.selectedTab == 2
                  ? null
                  : BottomNavBar(
                      currentIndex: controller.selectedTab,
                      onTap: controller.switchTab,
                      items: const [
                        BottomNavigationBarItem(
                          icon: ImageIcon(
                            AssetImage('assets/images/creat_image.png'),
                            size: 28,
                          ),
                          label: 'Create',
                        ),
                        BottomNavigationBarItem(
                          icon: ImageIcon(
                            AssetImage('assets/images/my_image.png'),
                            size: 28,
                          ),
                          label: 'My Songs',
                        ),
                   
                      ],
                    ),
            ),
            _LoadingOverlay(
              isLoading: controller.isLoading,
              messages: const [
                "Almost there...",
                "Composing your track...",
                "AI is mixing the beats...",
                "Generating your melody...",
                "Just a moment...",
                "Dreaming up your music...",
                "Tuning the vibes...",
                "Bringing your sound to life...",
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMusicGenerationTab(
    BuildContext context,
    HomeController controller,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Create stunning Music According to Mood with AI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Turn words into works of Music — generate \nprofessional tracks in seconds using AI.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            _LightGlassyPromptCard(controller: controller),

            const SizedBox(height: 18),
            InspirationGrid(
              items: controller.inspirationItems,
              onPromptSelected: (prompt) {
                final item = controller.inspirationItems.firstWhereOrNull(
                  (i) => i.prompt == prompt,
                );
                AnalyticsHelper.logCustomEvent(
                  'inspiration_selected',
                  parameters: {
                    'type': 'inspiration',
                    'title': item?.title ?? '',
                    'prompt': prompt,
                  },
                );
                controller.setPrompt(prompt);
                controller.generateMusic();
              },
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final List<String> messages;
  const _LoadingOverlay({required this.isLoading, required this.messages});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<String> _messages;
  late final Duration _interval;
  late final AnimationController _spinController;
  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
    _interval = const Duration(milliseconds: 1500);
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    if (widget.isLoading) _startCycling();
  }

  @override
  void didUpdateWidget(covariant _LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _startCycling();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _stopCycling();
    }
  }

  Timer? _timer;
  void _startCycling() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _messages.length;
      });
    });
  }

  void _stopCycling() {
    _timer?.cancel();
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spinController,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.85),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _messages[_currentIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LightGlassyPromptCard extends StatefulWidget {
  final HomeController controller;
  const _LightGlassyPromptCard({required this.controller});

  @override
  State<_LightGlassyPromptCard> createState() => _LightGlassyPromptCardState();
}

class _LightGlassyPromptCardState extends State<_LightGlassyPromptCard> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> loadingMessages = [
    "Composing your track...",
    "AI is mixing the beats...",
    "Generating your melody...",
    "Just a moment...",
    "Dreaming up your music...",
    "Tuning the vibes...",
    "Bringing your sound to life...",
  ];
  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'What do you want to listen to?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.13),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _promptController,
                focusNode: _focusNode,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: const Color(0xFFB16CEA),
                decoration: InputDecoration(
                  hintText:
                      'Describe your mood, let our AI create music for you...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                  suffixIcon: _promptController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                _promptController.clear();
                                widget.controller.setPrompt('');
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                onChanged: (v) {
                  widget.controller.setPrompt(v);
                  AnalyticsHelper.logCustomEvent(
                    'prompt_added',
                    parameters: {'prompt': v},
                  );
                  setState(() {});
                },
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onTap: () => setState(() {}),
                onEditingComplete: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'Pick a Mood',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _MoodPill(controller: controller, mood: "Happy"),
                  const SizedBox(width: 8),
                  _MoodPill(controller: controller, mood: "Sad"),
                  const SizedBox(width: 8),
                  _MoodPill(controller: controller, mood: "Chill"),
                  const SizedBox(width: 8),
                  _MoodPill(controller: controller, mood: "Energetic"),
                  const SizedBox(width: 8),
                  _MoodPill(controller: controller, mood: "Romantic"),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          AnalyticsHelper.logButtonTap(
                            'generate_button',
                            screenName: 'HomeScreen',
                          );
                          controller.generateMusic();
                        },
                  child: controller.isLoading
                      ? const Text('Generate')
                      : const Text('Generate'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  final HomeController controller;
  final String mood;
  const _MoodPill({required this.controller, required this.mood});

  @override
  Widget build(BuildContext context) {
    final bool selected = controller.selectedMood == mood;
    return GestureDetector(
      onTap: () {
        AnalyticsHelper.logButtonTap(
          'mood_pill_$mood',
          screenName: 'HomeScreen',
        );
        controller.setMood(mood);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: const Color(0xFFB16CEA), width: 1.5)
              : null,
        ),
        child: Text(
          mood,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
