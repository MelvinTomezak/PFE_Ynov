import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../common/error_state.dart';
import '../../common/neon_text.dart';
import '../../common/section_label.dart';
import '../viewmodel/artist_viewmodel.dart';

/// Écran « Biographie » : présentation détaillée de STYMA.
class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArtistViewModel()..load(),
      child: const _ArtistView(),
    );
  }
}

class _ArtistView extends StatelessWidget {
  const _ArtistView();

  static const _tags = ['Trap', 'Électronique', 'Live interactif'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ArtistViewModel>();
    final showAppBar = Navigator.of(context).canPop();

    Widget body;
    switch (vm.status) {
      case LoadStatus.loading:
      case LoadStatus.idle:
        body = const Center(child: CircularProgressIndicator());
        break;
      case LoadStatus.error:
        body = ErrorState(
          message: vm.errorMessage!,
          onRetry: () => context.read<ArtistViewModel>().load(),
        );
        break;
      case LoadStatus.success:
        final artist = vm.artist!;
        body = ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
          children: [
            // Bandeau dégradé
            Container(
              height: 150,
              decoration: const BoxDecoration(gradient: AppColors.neonGradient),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.graphic_eq, size: 56, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Artiste'),
                  const SizedBox(height: 10),
                  Semantics(
                    header: true,
                    child: NeonText(artist.name, fontSize: 36),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((t) => _Tag(label: t)).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    artist.bio,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
    }

    // Depuis l'accueil, l'écran est empilé (avec AppBar retour).
    // En onglet direct, pas d'AppBar (le logo STYMA reste en haut).
    if (showAppBar) {
      return Scaffold(appBar: AppBar(title: const Text('Biographie')), body: body);
    }
    return body;
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primaryLight, fontSize: 12),
      ),
    );
  }
}
