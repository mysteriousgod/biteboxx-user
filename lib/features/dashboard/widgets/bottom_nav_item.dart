import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';

class SmoothBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isGlassmorphic;

  const SmoothBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.isGlassmorphic = false,
  });

  static const List<IconData> _navIcons = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.menu,
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;
    const double circleSize = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double itemWidth = totalWidth / _navIcons.length;
        final double bubbleLeft =
            (selectedIndex * itemWidth) + (itemWidth - circleSize) / 2;

        return SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Smooth Gliding Floating Bubble (Active Indicator) ─────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: bubbleLeft,
                bottom: 14,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Theme.of(context).colorScheme.surface
                        : Colors.white,
                    border: isDark
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          )
                        : (isGlassmorphic
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1,
                              )
                            : null),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.40 : 0.12),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        _navIcons[selectedIndex],
                        key: ValueKey<int>(selectedIndex),
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

              // ── 5 Tab Touch Targets & Inactive Icons ────────────────────────
              Row(
                children: List.generate(_navIcons.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(index);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Inactive icon fades out when this tab is selected
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              opacity: selectedIndex == index ? 0.0 : 1.0,
                              child: Icon(
                                _navIcons[index],
                                color: isDark
                                    ? Theme.of(context).disabledColor
                                    : Colors.grey.shade400,
                                size: 22,
                              ),
                            ),

                            // Cart Badge (at index 2)
                            if (index == 2)
                              GetBuilder<CartController>(
                                builder: (cartController) {
                                  final int count =
                                      cartController.cartList.length;
                                  if (count == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Positioned(
                                    right: itemWidth * 0.12,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor
                                                .withValues(alpha: 0.35),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        count.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final Function? onTap;
  final bool isSelected;
  final int? badge;

  const BottomNavItem({
    super.key,
    required this.iconData,
    this.onTap,
    this.isSelected = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap?.call(),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 0.0 : 1.0,
                child: Icon(
                  iconData,
                  color: isDark
                      ? Theme.of(context).disabledColor
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: 14,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Theme.of(context).colorScheme.surface
                          : Colors.white,
                      border: isDark
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.40 : 0.12),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              if (badge != null && badge! > 0)
                Positioned(
                  right: 6,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
