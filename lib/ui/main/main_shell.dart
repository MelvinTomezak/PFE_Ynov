import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../common/neon_nav_bar.dart';
import '../events/view/events_screen.dart';
import '../home/view/home_screen.dart';
import '../linktree/view/linktree_screen.dart';
import '../music/view/music_screen.dart';
import '../profile/view/profile_screen.dart';
import '../vote/view/vote_screen.dart';

/// Coquille principale : barre supérieure (logo + profil) et navbar néon.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _selectTab(int i) => setState(() => _index = i);

  void _goHome() => setState(() => _index = 0);

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  static const _navItems = [
    NeonNavItem(
        icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Accueil'),
    NeonNavItem(
        icon: Icons.library_music_outlined,
        selectedIcon: Icons.library_music,
        label: 'Musique'),
    NeonNavItem(
        icon: Icons.how_to_vote_outlined,
        selectedIcon: Icons.how_to_vote,
        label: 'Vote'),
    NeonNavItem(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
        label: 'Agenda'),
    NeonNavItem(
        icon: Icons.link_outlined,
        selectedIcon: Icons.link,
        label: 'Linktree'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onSelectTab: _selectTab),
      const MusicScreen(),
      const VoteScreen(),
      const EventsScreen(),
      const LinktreeScreen(),
    ];

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
        items: _navItems,
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
