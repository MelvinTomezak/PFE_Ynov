import 'package:flutter/material.dart';

/// Palette STYMA — direction « Néon » bleu sur fond noir.
///
/// Fond noir pur, cadres quasi transparents à contour bleu néon.
/// Accessibilité (RGAA/WCAG) : néons réservés aux accents et titres,
/// texte courant en blanc cassé pour garantir les contrastes.
class AppColors {
  const AppColors._();

  // Fonds
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0x0AFFFFFF); // blanc ~4 % (cadre transparent)
  static const Color surfaceAlt = Color(0x14FFFFFF); // blanc ~8 %

  // Néons
  static const Color primary = Color(0xFF38BDF8); // bleu ciel électrique
  static const Color primaryLight = Color(0xFF7DD3FC);
  static const Color secondary = Color(0xFF6D5CFF); // indigo (dégradés)
  static const Color danger = Color(0xFFFF6B6B);

  // Texte
  static const Color textPrimary = Color(0xFFEDEFF5);
  static const Color textSecondary = Color(0xFF9CA3B4);
  // Contraste verifie sur fond noir : 5,8:1 (WCAG AA, seuil 4,5:1).
  // Valeur precedente #636B7E : 3,9:1, non conforme.
  static const Color textMuted = Color(0xFF7D8798);

  // Bordure néon (bleu à ~30 % d'opacité)
  static const Color border = Color(0x4D38BDF8);

  /// Dégradé signature bleu → indigo.
  static const LinearGradient neonGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
