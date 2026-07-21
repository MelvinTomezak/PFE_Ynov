import 'package:flutter/material.dart';

/// Un lien social de STYMA, tel que stocké en base.
class SocialLink {
  final String label;
  final String? handle;
  final String url;
  final String iconKey;
  final Color color;

  const SocialLink({
    required this.label,
    required this.url,
    required this.iconKey,
    required this.color,
    this.handle,
  });

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      label: map['label'] as String,
      handle: map['handle'] as String?,
      url: map['url'] as String,
      iconKey: map['icon_key'] as String,
      color: _parseHexColor(map['color'] as String?),
    );
  }

  /// Convertit "#RRGGBB" en Color. Repli sur le bleu STYMA si invalide.
  static Color _parseHexColor(String? hex) {
    final cleaned = (hex ?? '').replaceAll('#', '').trim();
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null || cleaned.length != 6) return const Color(0xFF38BDF8);
    return Color(0xFF000000 | value);
  }
}
