import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../common/section_label.dart';

/// Écran « Profil & paramètres ».
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  bool _notificationsEnabled = true;
  late String _username;

  @override
  void initState() {
    super.initState();
    _username = _authRepo.username ?? 'Utilisateur';
  }

  Future<void> _editUsername() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UsernameEditorSheet(initialUsername: _username),
    );

    if (result != null && result.isNotEmpty && result != _username) {
      try {
        await _authRepo.updateUsername(result);
        if (!mounted) return;
        setState(() => _username = result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pseudonyme mis à jour.')),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de modifier le pseudonyme.'),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthViewModel>();
    final navigator = Navigator.of(context);
    await auth.signOut();
    navigator.popUntil((route) => route.isFirst);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est définitive. Toutes vos données seront supprimées. '
          'Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final auth = context.read<AuthViewModel>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await auth.deleteAccount();
    if (ok) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Échec de la suppression du compte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _authRepo.currentUser?.email ?? '';
    final initial = _username.isNotEmpty ? _username[0].toUpperCase() : '?';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Text('STYMA'),
          ),
          bottom: const TabBar(
            dividerColor: AppColors.border,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Profil'),
              Tab(text: 'Paramètres'),
              Tab(text: 'À propos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProfileTab(
              username: _username,
              email: email,
              initial: initial,
              onEditUsername: _editUsername,
            ),
            _SettingsTab(
              notificationsEnabled: _notificationsEnabled,
              onNotificationsChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              onSignOut: _signOut,
              onDeleteAccount: _confirmDelete,
            ),
            const _AboutTab(),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String username;
  final String email;
  final String initial;
  final VoidCallback onEditUsername;

  const _ProfileTab({
    required this.username,
    required this.email,
    required this.initial,
    required this.onEditUsername,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.neonGradient,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(username, style: Theme.of(context).textTheme.titleLarge),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const SectionLabel('Informations personnelles'),
        const SizedBox(height: 12),
        _SettingTile(
          icon: Icons.badge_outlined,
          label: 'Pseudonyme',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
          onTap: onEditUsername,
        ),
        const SizedBox(height: 10),
        _SettingTile(
          icon: Icons.mail_outline,
          label: 'Adresse e-mail',
          trailing: Flexible(
            child: Text(
              email,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  const _SettingsTab({
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionLabel('Préférences'),
        const SizedBox(height: 12),
        _SettingTile(
          icon: Icons.notifications_none,
          label: 'Notifications',
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
        ),
        const SizedBox(height: 32),
        const SectionLabel('Session'),
        const SizedBox(height: 12),
        _SettingTile(
          icon: Icons.logout,
          label: 'Se déconnecter',
          onTap: onSignOut,
        ),
        const SizedBox(height: 32),
        const SectionLabel('Zone sensible'),
        const SizedBox(height: 8),
        const Text(
          'La suppression du compte est définitive et efface les données associées.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        _SettingTile(
          icon: Icons.delete_forever,
          label: 'Supprimer mon compte',
          color: AppColors.danger,
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: Icon(Icons.graphic_eq, size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Center(
          child:
              Text('STYMA', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Version 0.1.0',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 28),
        const _AboutCard(
          icon: Icons.auto_awesome,
          title: 'L’expérience STYMA',
          description:
              'Une application conçue pour rapprocher STYMA de son public avant, pendant et après les concerts.',
        ),
        const SizedBox(height: 12),
        const _AboutCard(
          icon: Icons.headphones_outlined,
          title: 'Musique et communauté',
          description:
              'Découvre les morceaux, vote pendant les lives, aime tes titres préférés et échange avec la communauté.',
        ),
        const SizedBox(height: 12),
        const _AboutCard(
          icon: Icons.local_activity_outlined,
          title: 'Concerts et actualités',
          description:
              'Retrouve les prochains événements, les réseaux officiels et toute l’actualité de STYMA.',
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            '© 2026 STYMA — Tous droits réservés',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsernameEditorSheet extends StatefulWidget {
  final String initialUsername;

  const _UsernameEditorSheet({required this.initialUsername});

  @override
  State<_UsernameEditorSheet> createState() => _UsernameEditorSheetState();
}

class _UsernameEditorSheetState extends State<_UsernameEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ton pseudonyme',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fermer',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'C’est le nom visible sur ton profil et tes commentaires.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (_, value, __) {
                          final name = value.text.trim();
                          return Container(
                            width: 72,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.neonGradient,
                            ),
                            child: Text(
                              name.isEmpty ? '?' : name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _controller,
                      autofocus: true,
                      maxLength: 20,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.username],
                      onFieldSubmitted: (_) => _save(),
                      decoration: const InputDecoration(
                        labelText: 'Pseudonyme',
                        hintText: 'Comment doit-on t’appeler ?',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Enregistrer le pseudonyme'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color color;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: TextStyle(color: color, fontSize: 15))),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
