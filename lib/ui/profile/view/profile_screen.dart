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
    final controller = TextEditingController(text: _username);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        void save() {
          if (formKey.currentState!.validate()) {
            Navigator.pop(ctx, controller.text.trim());
          }
        }

        return AlertDialog(
          backgroundColor: AppColors.surfaceAlt,
          title: const Text('Modifier le pseudonyme'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.username],
              onFieldSubmitted: (_) => save(),
              decoration: const InputDecoration(
                labelText: 'Pseudonyme',
                hintText: 'Comment doit-on t’appeler ?',
                helperText: 'Entre 2 et 20 caractères',
                prefixIcon: Icon(Icons.alternate_email),
                counterText: '',
              ),
              validator: Validators.username,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            TextButton(onPressed: save, child: const Text('Enregistrer')),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null && result.isNotEmpty && result != _username) {
      await _authRepo.updateUsername(result);
      if (mounted) setState(() => _username = result);
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text('STYMA'),
        ),
      ),
      body: ListView(
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
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Text(_username, style: Theme.of(context).textTheme.titleLarge),
                if (email.isNotEmpty)
                  Text(email,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const SectionLabel('Compte'),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.badge_outlined,
            label: 'Pseudonyme',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_username,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 18),
              ],
            ),
            onTap: _editUsername,
          ),
          const SizedBox(height: 28),
          const SectionLabel('Préférences'),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.notifications_none,
            label: 'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: Icons.info_outline,
            label: 'À propos',
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'STYMA',
              applicationVersion: '0.1.0',
              applicationLegalese: '© 2026 STYMA',
            ),
          ),
          const SizedBox(height: 36),
          _SettingTile(
            icon: Icons.logout,
            label: 'Se déconnecter',
            color: AppColors.danger,
            onTap: _signOut,
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: Icons.delete_forever,
            label: 'Supprimer mon compte',
            color: AppColors.danger,
            onTap: _confirmDelete,
          ),
        ],
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
