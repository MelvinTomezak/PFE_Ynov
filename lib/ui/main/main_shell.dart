import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../common/neon_nav_bar.dart';
import '../admin/view/admin_screen.dart';
import '../events/view/events_screen.dart';
import '../home/view/home_screen.dart';
import '../linktree/view/linktree_screen.dart';
import '../music/view/music_screen.dart';
import '../profile/view/profile_screen.dart';
import '../shop/view/shop_screen.dart';
import '../vote/view/vote_screen.dart';

/// Coquille principale : barre supérieure (logo + profil) et navbar néon.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _isAdmin = false;
  int _contentRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final isAdmin = await AuthRepository().isAdmin();
      if (mounted) setState(() => _isAdmin = isAdmin);
    } catch (_) {
      // Une absence de table/migration conserve l'expérience utilisateur.
    }
  }

  void _selectTab(int i) => setState(() => _index = i);

  void _goHome() => setState(() => _index = 0);

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  static const _userNavItems = [
    NeonNavItem(
        icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Accueil'),
    NeonNavItem(
        icon: Icons.headphones_outlined,
        selectedIcon: Icons.headphones,
        label: 'Musique'),
    NeonNavItem(
        icon: Icons.how_to_vote_outlined,
        selectedIcon: Icons.how_to_vote,
        label: 'Vote'),
    NeonNavItem(
        icon: Icons.local_activity_outlined,
        selectedIcon: Icons.local_activity,
        label: 'Événement'),
    NeonNavItem(
        icon: Icons.share_outlined,
        selectedIcon: Icons.share,
        label: 'Réseaux'),
    NeonNavItem(
        icon: Icons.storefront_outlined,
        selectedIcon: Icons.storefront,
        label: 'Boutique'),
  ];

  static const _adminItem = NeonNavItem(
    icon: Icons.admin_panel_settings_outlined,
    selectedIcon: Icons.admin_panel_settings,
    label: 'Admin',
  );

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: ValueKey('home-$_contentRevision'),
        onSelectTab: _selectTab,
      ),
      MusicScreen(key: ValueKey('music-$_contentRevision')),
      const VoteScreen(),
      EventsScreen(key: ValueKey('events-$_contentRevision')),
      const LinktreeScreen(),
      ShopScreen(key: ValueKey('shop-$_contentRevision')),
      if (_isAdmin)
        AdminScreen(
          onContentChanged: () => setState(() => _contentRevision++),
        ),
    ];
    final navItems = [..._userNavItems, if (_isAdmin) _adminItem];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 20,
        title: Semantics(
          button: true,
          label: 'STYMA, retour à l\'accueil',
          child: GestureDetector(
            onTap: _goHome,
            child: Text('STYMA',
                style: Theme.of(context).appBarTheme.titleTextStyle),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ProfileAvatar(onTap: _openProfile),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NeonNavBar(
        currentIndex: _index,
        onTap: _selectTab,
        items: navItems,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = AuthRepository().username ?? '?';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Semantics(
      button: true,
      label: 'Profil et paramètres',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.neonGradient,
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: Text(initial,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
        ),
      ),
    );
  }
}
