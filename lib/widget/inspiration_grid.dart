import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:musicxy/services/analytics_helper.dart';

class InspirationItem {
  final String title;
  final String imageUrl;
  final String prompt;

  InspirationItem({
    required this.title,
    required this.imageUrl,
    required this.prompt,
  });
}

class InspirationGrid extends StatelessWidget {
  final List<InspirationItem> items;
  final void Function(String prompt) onPromptSelected;

  const InspirationGrid({
    super.key,
    required this.items,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get Inspired",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Curated moods & ideas for your next hit 🎶",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),

        CarouselSlider.builder(
          itemCount: items.length,
          itemBuilder: (context, index, realIndex) {
            return _InspirationCard(
              item: items[index],
              onPromptSelected: onPromptSelected,
              width: screenWidth * 0.75,
            );
          },
          options: CarouselOptions(
            height: 240,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            viewportFraction: 0.75,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final InspirationItem item;
  final void Function(String prompt) onPromptSelected;
  final double width;

  const _InspirationCard({
    required this.item,
    required this.onPromptSelected,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 240;

    return GestureDetector(
      onTap: () {
        AnalyticsHelper.logCustomEvent(
          'inspiration_card_tap',
          parameters: {'title': item.title, 'prompt': item.prompt},
        );
        onPromptSelected(item.prompt);
      },
      child: Container(
        width: width,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
                width: width,
                height: cardHeight,
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
