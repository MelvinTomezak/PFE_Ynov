import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../common/neon_text.dart';
import '../../common/section_label.dart';

/// Écran « Vote » — placeholder en attendant l'implémentation complète
/// (vote pour le prochain morceau + bracelet simulé) prévue en Partie B.
class VoteScreen extends StatelessWidget {
  const VoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.neonGradient,
              ),
              child: const Icon(Icons.how_to_vote, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const NeonText('Vote', fontSize: 30),
            const SizedBox(height: 16),
            const SectionLabel('Bientôt en concert'),
            const SizedBox(height: 12),
            Text(
              'Pendant les lives de STYMA, votez ici pour le prochain morceau. '
              'Votre bracelet connecté déclenchera le vote en temps réel.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
