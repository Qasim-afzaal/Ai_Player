import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicxy/services/analytics_helper.dart';

class _BgImageLayout {
  final double left, top, width, height, radius, angle;
  final String image;
  final _MagicShape shape;
  _BgImageLayout({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.radius,
    required this.angle,
    required this.image,
    required this.shape,
  });
}

enum _MagicShape { roundedRect }

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;
  late Animation<double> _pulse;

  final List<String> _inspirationImages = [
    'assets/images/inspirations/Floating Garden Library.jpeg',
    'assets/images/inspirations/Horse on Beach.jpeg',
    'assets/images/inspirations/Ghibli Forest Path.jpeg',
    'assets/images/inspirations/3D Futuristic Train.jpeg',
    'assets/images/inspirations/Cyberpunk Neon Portrait.jpeg',
    'assets/images/inspirations/3D Steampunk Airship.jpeg',
    'assets/images/inspirations/Ghibli Autumn Bridge.jpeg',
    'assets/images/inspirations/Cyberpunk Street Food Stall.jpeg',
    'assets/images/inspirations/3D Ice Castle.jpeg',
    'assets/images/inspirations/3D Fantasy Armory.jpeg',
  ];
  int _bgIndex = 0;
  Timer? _bgTimer;
  List<_BgImageLayout> _bgLayout = [];

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('PaywallScreen');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _pulse = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _generateRandomBgLayout();
    _bgTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _bgIndex = (_bgIndex + 1) % _inspirationImages.length;
        _generateRandomBgLayout();
      });
    });
  }

  void _generateRandomBgLayout() {
    final rand = Random();
    final size =
        WidgetsBinding.instance.window.physicalSize /
        WidgetsBinding.instance.window.devicePixelRatio;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final int cols = 3;
    final int rows = 4;
    final double cellW = screenWidth / cols;
    final double cellH = screenHeight / rows;
    List<String> shuffled = List.from(_inspirationImages)..shuffle(rand);
    _bgLayout = [];
    int imgIdx = 0;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        double left = col * cellW;
        double top = row * cellH;
        double width = cellW;
        double height = cellH;
        double radius = 24;
        double angle = 0;
        String image = shuffled[imgIdx % shuffled.length];
        imgIdx++;
        _bgLayout.add(
          _BgImageLayout(
            left: left,
            top: top,
            width: width,
            height: height,
            radius: radius,
            angle: angle,
            image: image,
            shape: _MagicShape.roundedRect,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 420;
    return Scaffold(
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: _MagicalInspirationBackground(
                key: ValueKey(_bgIndex),
                imagePath: _inspirationImages[_bgIndex],
                allImages: _inspirationImages,
                layout: _bgLayout,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xCC181824),
                    Color(0xCC23243A),
                    Color(0xCC0F051D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulse.value,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFB16CEA,
                                            ).withOpacity(0.55),
                                            blurRadius: 36,
                                            spreadRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 44,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: const Color(0xFFFF5E69),
                                          size: 52,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Go Premium',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5E69),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Premium',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unlock unlimited AI music generations, all styles, and more. No ads, no watermarks.',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _perkCard(
                                    icon: Icons.all_inclusive,
                                    color: Color(0xFFB16CEA),
                                    title: 'Unlimited Generations',
                                    subtitle:
                                        'Create as many music as you want, anytime.',
                                  ),
                                  _perkCard(
                                    icon: Icons.style,
                                    color: Color(0xFFFF5E69),
                                    title: 'All Styles & Inspirations',
                                    subtitle:
                                        'Access every style and inspiration available.',
                                  ),
                                  _perkCard(
                                    icon: Icons.support_agent,
                                    color: Color(0xFF7F53AC),
                                    title: 'Priority Support',
                                    subtitle:
                                        'Get help fast from our premium team.',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Column(
                                children: [
                                  Text(
                                    '9.99/month',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFF5E69),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Monthly Plan',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFB16CEA),
                                        Color(0xFFFF5E69),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(24),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFB16CEA),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      AnalyticsHelper.logButtonTap(
                                        'pro_button',
                                        screenName: 'PaywallScreen',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Upgrade tapped!'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      textStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Upgrade for \$9.99/month'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    AnalyticsHelper.logButtonTap(
                                      'pro_button',
                                      screenName: 'PaywallScreen',
                                    );
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/home');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    backgroundColor: Colors.white.withOpacity(
                                      0.08,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    textStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  child: const Text('Continue with Free'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Secure payment • Cancel anytime',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _perkCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicalInspirationBackground extends StatelessWidget {
  final String imagePath;
  final List<String> allImages;
  final List<_BgImageLayout> layout;
  const _MagicalInspirationBackground({
    Key? key,
    required this.imagePath,
    required this.allImages,
    required this.layout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          for (final l in layout)
            Positioned(
              left: l.left,
              top: l.top,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(l.radius),
                child: Container(
                  width: l.width,
                  height: l.height,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    l.image,
                    fit: BoxFit.contain,
                    width: l.width,
                    height: l.height,
                    color: Colors.white.withOpacity(0.9),
                    colorBlendMode: BlendMode.modulate,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: l.width,
                      height: l.height,
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white38,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
