import 'dart:ui';
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

/// Barre de navigation flottante : cadre transparent à contour bleu néon.
/// L'onglet actif s'illumine (icône + label + halo).
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  return _NeonNavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
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
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: color,
                size: 24,
                shadows: selected
                    ? [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
