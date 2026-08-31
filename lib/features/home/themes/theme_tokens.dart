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
  static BoxDecoration glassBox({double radius = 16, Color? tintColor}) {
    return BoxDecoration(
      color: (tintColor ?? Colors.white).withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.35),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          spreadRadius: 1,
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
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding,
    this.margin,
    this.tintColor,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: ThemeTokens.glassBox(radius: radius, tintColor: tintColor),
            child: child,
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
