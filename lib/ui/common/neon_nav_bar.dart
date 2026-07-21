import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Élément de la barre de navigation néon.
class NeonNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const NeonNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Barre de navigation sur fond noir : chaque bouton est délimité par un
/// contour néon bleu clair. L'onglet actif s'illumine (contour + halo).
class NeonNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NeonNavItem> items;

  const NeonNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NeonNavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NeonNavButton extends StatelessWidget {
  final NeonNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NeonNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primary
        : AppColors.primaryLight.withValues(alpha: 0.35);
    final contentColor = selected ? AppColors.primary : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.6 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: contentColor,
                size: 22,
                shadows: selected
                    ? [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  height: 1,
                  color: contentColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
