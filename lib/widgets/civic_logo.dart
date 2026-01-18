import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CivicLogo extends StatelessWidget {
  final double size;
  final String title;      // ✅ Now customizable
  final String tagline;    // ✅ Now customizable

  const CivicLogo({
    super.key,
    this.size = 150,
    this.title = "CIVICSOLVER",      // Default name
    this.tagline = "STRONGER TOGETHER", // Default tagline
  });

  @override
  Widget build(BuildContext context) {
    final primaryTeal = const Color(0xFF4FD1C5);
    final darkTeal = const Color(0xFF2D8A8C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. THE SYMBOL (Keep the image for the icon part only)
        // Make sure you cropped just the circle part to 'assets/images/logo_icon.png'
        Image.asset(
          'assets/images/logo_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 16),

        // 2. APP NAME (Rendered in Code)
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.michroma(
            fontSize: size * 0.22,
            fontWeight: FontWeight.w500,
            color: primaryTeal,
            letterSpacing: 3.5,
          ),
        ),

        const SizedBox(height: 6),

        // 3. TAGLINE
        Text(
          tagline.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: size * 0.09,
            fontWeight: FontWeight.w600,
            color: darkTeal,
            letterSpacing: 4.0,
          ),
        ),
      ],
    );
  }
}