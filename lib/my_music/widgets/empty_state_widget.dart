import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/my_image.png',
              width: 35,
              height: 35,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Songs in history yet.',
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate some Songs to see them here',
            style: GoogleFonts.poppins(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
