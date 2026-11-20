import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Home, Groups, [+], Lectures, Profile — matches the Figma bottom navigation.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTab,
    required this.onAdd,
  });

  final int currentIndex; // 0 Home, 1 Groups, 2 Lectures, 3 Profile
  final ValueChanged<int> onTab;
  final VoidCallback onAdd;

  static const _items = [
    _NavItem('Home', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Groups', Icons.groups_outlined, Icons.groups_rounded),
    _NavItem('Lectures', Icons.play_arrow_outlined, Icons.play_arrow_rounded),
    _NavItem('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  Widget _tab(int branch) {
    final item = _items[branch];
    final selected = currentIndex == branch;
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => onTab(branch),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? item.activeIcon : item.icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w500, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        // Fixed height so the bar can never grow to fill the screen.
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _tab(0),
              _tab(1),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ),
              _tab(2),
              _tab(3),
            ],
          ),
        ),
      ),
    );
  }
}
