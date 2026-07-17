import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  selectedIcon: HugeIcons
                      .strokeRoundedHome01, // Using stroke for both to ensure compatibility, relying on color for selection
                  unselectedIcon: HugeIcons.strokeRoundedHome01,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavBarItem(
                  selectedIcon: HugeIcons.strokeRoundedTask01,
                  unselectedIcon: HugeIcons.strokeRoundedTask01,
                  label: 'Tasks',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _NavBarItem(
                  selectedIcon: HugeIcons.strokeRoundedUser,
                  unselectedIcon: HugeIcons.strokeRoundedUser,
                  label: 'Account',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final dynamic selectedIcon;
  final dynamic unselectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.textTheme.bodyLarge?.color ?? Colors.black
        : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
              Colors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: isSelected ? selectedIcon : unselectedIcon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
