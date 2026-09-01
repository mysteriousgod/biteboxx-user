import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

enum ActiveTheme {
  classic(1, 'Classic'),
  modern(2, 'Modern'),
  neumorphic(3, 'Neumorphism'),
  glassmorphic(4, 'Glassmorphism'),
  brutalist(5, 'Neo-Brutalism'),
  cyberpunk(6, 'Cyberpunk'),
  minimalist(7, 'Minimalist 2.0'),
  darkFuturistic(8, 'Dark Futuristic'),
  vaporwave(9, 'Retro Vaporwave'),
  skeuomorphic(10, 'Skeuomorphism');

  final int id;
  final String label;
  const ActiveTheme(this.id, this.label);

  static ActiveTheme fromId(int? id) {
    return ActiveTheme.values.firstWhere(
      (theme) => theme.id == id,
      orElse: () => ActiveTheme.classic,
    );
  }
}

class ThemeTokens {
  // Neumorphism Colors & Shadows
  static const Color neuBaseColor = Color(0xFFE0E5EC);
  static const Color neuDarkShadow = Color(0xFFA3B1C6);
  static const Color neuLightShadow = Color(0xFFFFFFFF);

  static BoxDecoration neuBox({double radius = 16, bool isPressed = false}) {
    return BoxDecoration(
      color: neuBaseColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isPressed
          ? [
              const BoxShadow(color: neuDarkShadow, offset: Offset(2, 2), blurRadius: 4),
              const BoxShadow(color: neuLightShadow, offset: Offset(-2, -2), blurRadius: 4),
            ]
          : [
              const BoxShadow(color: neuDarkShadow, offset: Offset(6, 6), blurRadius: 12),
              const BoxShadow(color: neuLightShadow, offset: Offset(-6, -6), blurRadius: 12),
            ],
    );
  }

  // Glassmorphism
  static BoxDecoration glassBox({
    double radius = 16,
    Color? tintColor,
    Color? borderColor,
    double borderWidth = 1.2,
    bool isDark = false,
    List<BoxShadow>? customShadow,
  }) {
    final Color base = tintColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                base.withValues(alpha: 0.22),
                base.withValues(alpha: 0.08),
              ]
            : [
                base.withValues(alpha: 0.35),
                base.withValues(alpha: 0.12),
              ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (borderColor ?? (isDark ? const Color(0xFF94A3B8) : Colors.white)).withValues(alpha: isDark ? 0.22 : 0.45),
        width: borderWidth,
      ),
      boxShadow: customShadow ??
          [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF64748B).withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
    );
  }

  // Neo-Brutalism
  static const Color brutalistYellow = Color(0xFFFFDE59);
  static const Color brutalistMint = Color(0xFF54E38E);
  static const Color brutalistCoral = Color(0xFFFF7A59);
  static const Color brutalistLavender = Color(0xFFC4B5FD);

  static BoxDecoration brutalistBox({
    Color background = Colors.white,
    double radius = 8,
    Color shadowColor = Colors.black,
    double shadowOffset = 4,
    double borderWidth = 2.5,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.black, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: Offset(shadowOffset, shadowOffset),
          blurRadius: 0,
        ),
      ],
    );
  }

  // Cyberpunk
  static const Color cyberDark = Color(0xFF0A0E17);
  static const Color cyberCardBg = Color(0xFF131A29);
  static const Color cyberCyan = Color(0xFF00F0FF);
  static const Color cyberPink = Color(0xFFFF007F);
  static const Color cyberYellow = Color(0xFFFFE600);

  static BoxDecoration cyberBox({
    Color accent = cyberCyan,
    double radius = 8,
    bool glow = true,
  }) {
    return BoxDecoration(
      color: cyberCardBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent, width: 1.5),
      boxShadow: glow
          ? [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  // Minimalist 2.0
  static BoxDecoration minimalistBox({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

/// Glassmorphic frosted container with backdrop blur
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final Color? borderColor;
  final double borderWidth;
  final double blur;
  final VoidCallback? onTap;
  final List<BoxShadow>? customShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding,
    this.margin,
    this.tintColor,
    this.borderColor,
    this.borderWidth = 1.2,
    this.blur = 14,
    this.onTap,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    Widget content = Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: ThemeTokens.glassBox(
              radius: radius,
              tintColor: tintColor,
              borderColor: borderColor,
              borderWidth: borderWidth,
              isDark: isDark,
              customShadow: customShadow,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }
    return content;
  }
}

/// Frosted Glass Pill for ratings, badges, tags, and small chips
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color? tintColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double radius;

  const GlassPill({
    super.key,
    required this.child,
    this.tintColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.blur = 10,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (tintColor ?? (isDark ? Colors.black : Colors.white)).withValues(alpha: isDark ? 0.35 : 0.40),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: (borderColor ?? Colors.white).withValues(alpha: isDark ? 0.25 : 0.50),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Frosted circular glass icon button
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.size = 38,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.45),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.60),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}

/// Section title widget adapted for theme styling
class ThemedSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final Color? titleColor;
  final TextStyle? customStyle;
  final bool isBrutalist;

  const ThemedSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.titleColor,
    this.customStyle,
    this.isBrutalist = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: customStyle ??
                      (isBrutalist
                          ? robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              letterSpacing: 0.5,
                              color: titleColor ?? Colors.black,
                            )
                          : robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: titleColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                            )),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              child: Text(
                'view_all'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
