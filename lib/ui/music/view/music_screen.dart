import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../../data/models/track.dart';
import '../../../data/models/track_comment.dart';
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
    final vm = context.read<MusicViewModel>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pochette avec halo bleu
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.music_note,
                    color: AppColors.primary, size: 20),
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
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Row(
            children: [
              _InteractionButton(
                icon: track.isLiked ? Icons.favorite : Icons.favorite_border,
                color: track.isLiked ? AppColors.danger : AppColors.textMuted,
                label: '${track.likeCount}',
                tooltip: track.isLiked ? 'Retirer le like' : 'Aimer ce morceau',
                semanticLabel: track.isLiked
                    ? "Retirer le like. ${track.likeCount} j'aime"
                    : "Aimer ce morceau. ${track.likeCount} j'aime",
                onTap: () async {
                  final ok = await vm.toggleLike(track);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Impossible de modifier le like.'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              _InteractionButton(
                icon: Icons.chat_bubble_outline,
                color: AppColors.primaryLight,
                label: '${track.commentCount}',
                tooltip: 'Voir les commentaires',
                semanticLabel:
                    "Voir les commentaires. ${track.commentCount} commentaires",
                onTap: () => _showComments(context, vm, track),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComments(
    BuildContext context,
    MusicViewModel viewModel,
    Track track,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => _CommentsSheet(viewModel: viewModel, track: track),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String tooltip;
  final String? semanticLabel;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // Le libellé annoncé inclut le compteur : l'icône seule ne suffit pas.
      label: semanticLabel ?? tooltip,
      excludeSemantics: true,
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final MusicViewModel viewModel;
  final Track track;

  const _CommentsSheet({required this.viewModel, required this.track});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  late Future<List<TrackComment>> _commentsFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.viewModel.fetchComments(widget.track.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    final comment = await widget.viewModel.addComment(widget.track, content);
    if (!mounted) return;

    if (comment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’envoyer le commentaire.')),
      );
      setState(() => _isSending = false);
      return;
    }

    _controller.clear();
    setState(() {
      _isSending = false;
      _commentsFuture = widget.viewModel.fetchComments(widget.track.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + keyboardHeight),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.track.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Commentaires',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TrackComment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Impossible de charger les commentaires.'),
                      );
                    }
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text('Sois le premier à commenter ce morceau.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) => _CommentTile(
                        comment: comments[index],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLength: 500,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire…',
                  counterText: '',
                  suffixIcon: IconButton(
                    tooltip: 'Envoyer',
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final TrackComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.surfaceAlt,
            child: Text(
              comment.username.isEmpty
                  ? '?'
                  : comment.username[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primaryLight),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(comment.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
