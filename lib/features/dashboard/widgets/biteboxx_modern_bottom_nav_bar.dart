import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BiteboxxModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BiteboxxModernBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Map screen indices: 0: Home, 1: Favorites, 3: Reorder, 4: Profile
    final List<_NavItemData> navItems = [
      _NavItemData(
        pageIndex: 0,
        label: 'Home',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      _NavItemData(
        pageIndex: 1,
        label: 'Favorites',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_border_rounded,
      ),
      _NavItemData(
        pageIndex: 3,
        label: 'Reorder',
        activeIcon: Icons.receipt_long_rounded,
        inactiveIcon: Icons.receipt_long_outlined,
      ),
      _NavItemData(
        pageIndex: 4,
        label: 'Profile',
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline_rounded,
      ),
    ];

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final bool isSelected = selectedIndex == item.pageIndex;

          return Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap(item.pageIndex);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: 68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      // Active: Vibrant Orange Circle Badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF6000),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6000).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            item.activeIcon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: robotoMedium.copyWith(
                          fontSize: 11,
                          color: const Color(0xFFFF6000),
                          height: 1.0,
                        ),
                      ),
                    ] else ...[
                      // Inactive: Subtle outline icon and grey label
                      const SizedBox(height: 4),
                      Icon(
                        item.inactiveIcon,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        size: 24,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label,
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItemData {
  final int pageIndex;
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  _NavItemData({
    required this.pageIndex,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

