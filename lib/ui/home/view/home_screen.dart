import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../artist/view/artist_screen.dart';
import '../../common/error_state.dart';
import '../../common/neon_text.dart';
import '../../common/section_label.dart';
import '../viewmodel/home_viewmodel.dart';

/// Écran « Accueil » : dernières actualités de STYMA.
class HomeScreen extends StatelessWidget {
  /// Bascule vers un autre onglet (Musique = 1, Événement = 3, Réseaux = 4).
  final ValueChanged<int> onSelectTab;

  const HomeScreen({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..load(),
      child: _HomeView(onSelectTab: onSelectTab),
    );
  }
}

class _HomeView extends StatelessWidget {
  final ValueChanged<int> onSelectTab;
  const _HomeView({required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final username = AuthRepository().username ?? 'toi';

    switch (vm.status) {
      case LoadStatus.loading:
      case LoadStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return ErrorState(
          message: vm.errorMessage!,
          onRetry: () => context.read<HomeViewModel>().load(),
        );
      case LoadStatus.success:
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            const SectionLabel('Ravi de te revoir'),
            const SizedBox(height: 8),
            NeonText(username, fontSize: 34, glow: 18),
            const SizedBox(height: 28),

            if (vm.nextEvent != null) ...[
              const SectionLabel('Prochain concert'),
              const SizedBox(height: 10),
              _NewsCard(
                icon: Icons.local_activity,
                title: vm.nextEvent!.title,
                subtitle:
                    '${vm.nextEvent!.venue} — ${vm.nextEvent!.city}\n${vm.nextEvent!.formattedDate}',
                onTap: () => onSelectTab(3),
              ),
              const SizedBox(height: 24),
            ],

            const SectionLabel('Derniers sons'),
            const SizedBox(height: 10),
            ...vm.latestTracks.map(
              (t) => _NewsCard(
                icon: Icons.music_note,
                title: t.title,
                subtitle: t.album ?? '',
                trailing: t.formattedDuration,
                onTap: () => onSelectTab(1),
              ),
            ),
            const SizedBox(height: 24),

            const SectionLabel('Découvrir'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickLink(
                    icon: Icons.person,
                    label: 'Biographie',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ArtistScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickLink(
                    icon: Icons.share,
                    label: 'Réseaux',
                    onTap: () => onSelectTab(4),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _NewsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _NewsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                Text(trailing!,
                    style: const TextStyle(
                        color: AppColors.primaryLight, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
