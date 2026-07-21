import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Titre en néon : police Unbounded avec un halo lumineux (glow).
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final double glow;

  const NeonText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.color = AppColors.primary,
    this.glow = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.unbounded(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 1,
        shadows: [
          Shadow(color: color.withValues(alpha: 0.8), blurRadius: glow),
          Shadow(color: color.withValues(alpha: 0.5), blurRadius: glow * 2),
        ],
      ),
    );
  }
}
