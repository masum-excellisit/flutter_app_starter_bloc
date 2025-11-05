import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';

class _BottomNavItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String path;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.path,
  });
}

const List<_BottomNavItem> _navItems = <_BottomNavItem>[
  _BottomNavItem(
    label: 'Posts',
    icon: Icons.article_outlined,
    selectedIcon: Icons.article,
    path: '/posts',
  ),
  _BottomNavItem(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    path: '/profile',
  ),
];

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  int _locationToIndex(String location) {
    final String path = Uri.tryParse(location)?.path ?? location;
    final int index = _navItems.indexWhere(
      (_BottomNavItem item) =>
          path == item.path || path.startsWith('${item.path}/'),
    );
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.enableBottomNavigation) {
      return const SizedBox.shrink();
    }

    final GoRouter router = GoRouter.of(context);
    final String location =
        router.routerDelegate.currentConfiguration.uri.toString();
    final int selectedIndex = _locationToIndex(location);

    return SafeArea(
      child: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: _navItems
            .map(
              (_BottomNavItem item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon),
                label: item.label,
              ),
            )
            .toList(),
        onDestinationSelected: (int index) {
          final _BottomNavItem destination = _navItems[index];
          final String targetPath = destination.path;
          final String currentPath = Uri.tryParse(location)?.path ?? location;
          if (currentPath == targetPath) {
            return;
          }
          router.go(targetPath);
        },
      ),
    );
  }
}
