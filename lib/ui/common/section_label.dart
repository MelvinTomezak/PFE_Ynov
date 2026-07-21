import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Petit label « techno » en capitales espacées (police Chakra Petch).
class SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const SectionLabel(this.text, {super.key, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.chakraPetch(
        fontSize: 11,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
