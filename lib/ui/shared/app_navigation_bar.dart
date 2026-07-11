import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key});

  static const _routes = [
    '/home',
    '/tours',
    '/promotions',
    '/bookings',
    '/profile',
  ];

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _routes.indexWhere((route) => path.startsWith(route));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _selectedIndex(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) {
          return;
        }
        context.go(
          _routes[index],
          extra: {'fromTabIndex': currentIndex, 'toTabIndex': index},
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Tour',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_offer_outlined),
          selectedIcon: Icon(Icons.local_offer),
          label: 'Khuyến mãi',
        ),
        NavigationDestination(
          icon: Icon(Icons.confirmation_number_outlined),
          selectedIcon: Icon(Icons.confirmation_number),
          label: 'Booking',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}
