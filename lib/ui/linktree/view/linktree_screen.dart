import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../../data/models/social_link.dart';
import '../../common/error_state.dart';
import '../../common/neon_text.dart';
import '../../common/section_label.dart';
import '../viewmodel/linktree_viewmodel.dart';

/// Écran « Linktree » : photo de STYMA + réseaux (chargés depuis la base).
class LinktreeScreen extends StatelessWidget {
  const LinktreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LinktreeViewModel()..load(),
      child: const _LinktreeView(),
    );
  }
}

class _LinktreeView extends StatelessWidget {
  const _LinktreeView();

  /// Associe une clé d'icône (stockée en base) à une icône FontAwesome.
  static FaIconData _iconFor(String key) {
    switch (key) {
      case 'spotify':
        return FontAwesomeIcons.spotify;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'soundcloud':
        return FontAwesomeIcons.soundcloud;
      case 'deezer':
        return FontAwesomeIcons.deezer;
      case 'twitter':
      case 'x':
        return FontAwesomeIcons.xTwitter;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      default:
        return FontAwesomeIcons.link;
    }
  }

  Future<void> _open(BuildContext context, String url) async {
    final ok =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LinktreeViewModel>();

    switch (vm.status) {
      case LoadStatus.loading:
      case LoadStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return ErrorState(
          message: vm.errorMessage!,
          onRetry: () => context.read<LinktreeViewModel>().load(),
        );
      case LoadStatus.success:
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            _Header(photoUrl: vm.photoUrl),
            const SizedBox(height: 32),
            ...vm.links.map(
              (link) => _LinkButton(
                link: link,
                icon: _iconFor(link.iconKey),
                onTap: () => _open(context, link.url),
              ),
            ),
          ],
        );
    }
  }
}

/// En-tête : photo (ou repli dégradé) + nom + sous-titre.
class _Header extends StatelessWidget {
  final String? photoUrl;
  const _Header({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.neonGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
              ),
            ],
          ),
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _FallbackAvatar(),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const _FallbackAvatar(loading: true),
                  )
                : const _FallbackAvatar(),
          ),
        ),
        const SizedBox(height: 16),
        const NeonText('STYMA', fontSize: 30),
        const SizedBox(height: 6),
        const SectionLabel('Tous mes réseaux'),
      ],
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  final bool loading;
  const _FallbackAvatar({this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.graphic_eq, size: 40, color: Colors.white),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final SocialLink link;
  final FaIconData icon;
  final VoidCallback onTap;

  const _LinkButton({
    required this.link,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              FaIcon(icon, color: link.color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(link.label,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    if (link.handle != null && link.handle!.isNotEmpty)
                      Text(link.handle!,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new,
                  color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
