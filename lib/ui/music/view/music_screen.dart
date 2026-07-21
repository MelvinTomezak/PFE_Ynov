import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../../data/models/track.dart';
import '../../common/error_state.dart';
import '../viewmodel/music_viewmodel.dart';

/// Écran « Musique » : liste des morceaux de STYMA.
class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicViewModel()..load(),
      child: const _MusicView(),
    );
  }
}

class _MusicView extends StatelessWidget {
  const _MusicView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MusicViewModel>();

    switch (vm.status) {
      case LoadStatus.loading:
      case LoadStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return ErrorState(
          message: vm.errorMessage!,
          onRetry: () => context.read<MusicViewModel>().load(),
        );
      case LoadStatus.success:
        if (vm.tracks.isEmpty) {
          return const Center(child: Text('Aucun morceau pour le moment.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: vm.tracks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _TrackRow(track: vm.tracks[index]),
        );
    }
  }
}

class _TrackRow extends StatelessWidget {
  final Track track;
  const _TrackRow({required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Pochette avec halo bleu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child:
                const Icon(Icons.music_note, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (track.album != null)
                  Text(
                    track.album!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            track.formattedDuration,
            style: const TextStyle(color: AppColors.primaryLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
