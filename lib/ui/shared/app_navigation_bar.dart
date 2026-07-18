import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 8.0),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(context, 1, Icons.map_outlined, Icons.map, 'Tour'),
            _buildNavItem(context, 2, Icons.local_offer_outlined, Icons.local_offer, 'Khuyến mãi'),
            _buildNavItem(context, 3, Icons.confirmation_number_outlined, Icons.confirmation_number, 'Booking'),
            _buildNavItem(context, 4, Icons.person_outline, Icons.person, 'Hồ sơ'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    final primaryColor = Theme.of(context).primaryColor;
    final color = isSelected ? primaryColor : Colors.grey;

    return GestureDetector(
      onTap: () {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Canh giữa theo chiều dọc
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
