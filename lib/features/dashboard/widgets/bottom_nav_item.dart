import 'package:flutter/material.dart';

class BottomNavItem extends StatefulWidget {
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
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Only lifts slightly — just enough to peek above the bar
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      widget.isSelected ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap?.call(),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 56,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // ── Icon (inactive state, fades out) ─────────────────────
                  if (!widget.isSelected)
                    Icon(
                      widget.iconData,
                      color: isDark
                          ? Theme.of(context).disabledColor
                          : Colors.grey.shade400,
                      size: 22,
                    ),

                  // ── Floating circle (active state) ─────────────────
                  if (widget.isSelected)
                    Positioned(
                      // Sits centred on the top edge of the bar — half in, half out
                      bottom: 7 + _floatAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 46,
                          height: 46,
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
                                color: Colors.black.withValues(
                                    alpha: (isDark ? 0.40 : 0.10) *
                                        _opacityAnimation.value),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.iconData,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                  // ── Badge ────────────────────────────────────────────────
                  if (widget.badge != null && widget.badge! > 0)
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
                          widget.badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
