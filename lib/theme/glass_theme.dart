import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

ThemeData glassDarkTheme = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFFF7918), // BiteBoxx Signature Orange from logo
  secondaryHeaderColor: const Color(0xFFFFA000), // Warm Amber Glow
  disabledColor: const Color(0xFFA2A7AD),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF94A3B8),
  cardColor: const Color(0xFF1A1816).withValues(alpha: 0.68),
  scaffoldBackgroundColor: const Color(0xFF0D0E11),
  shadowColor: const Color(0xFFFF7918).withValues(alpha: 0.18),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7918)),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF7918),
    secondary: Color(0xFFFFA000),
    tertiary: Color(0xFFFF5722),
    tertiaryContainer: Color(0xFF3E1F08),
    surface: Color(0xFF141416),
    error: Color(0xFFEF4444),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF1A1816).withValues(alpha: 0.92),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1A1816).withValues(alpha: 0.90),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
    ),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: const Color(0xFF141416).withValues(alpha: 0.94),
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFFFF7918),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: BottomAppBarThemeData(
    color: const Color(0xFF141416).withValues(alpha: 0.78),
    surfaceTintColor: Colors.transparent,
    height: 60,
    padding: const EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.12),
    thickness: 0.5,
  ),
  tabBarTheme: const TabBarThemeData(
    dividerColor: Colors.transparent,
    indicatorColor: Color(0xFFFF7918),
  ),
);

ThemeData glassLightTheme = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFFF7918), // BiteBoxx Signature Orange from logo
  secondaryHeaderColor: const Color(0xFFFFA000), // Warm Amber Glow
  disabledColor: const Color(0xFF94A3B8),
  brightness: Brightness.light,
  hintColor: const Color(0xFF64748B),
  cardColor: Colors.white.withValues(alpha: 0.78),
  scaffoldBackgroundColor: const Color(0xFFFAF7F5),
  shadowColor: const Color(0xFFFF7918).withValues(alpha: 0.12),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7918)),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF7918),
    secondary: Color(0xFFFFA000),
    tertiary: Color(0xFFFF5722),
    tertiaryContainer: Color(0xFFFFF0E5),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFEF4444),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white.withValues(alpha: 0.94),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white.withValues(alpha: 0.94),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
    ),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.white.withValues(alpha: 0.96),
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFFFF7918),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: BottomAppBarThemeData(
    color: Colors.white.withValues(alpha: 0.82),
    surfaceTintColor: Colors.transparent,
    height: 60,
    padding: const EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.black.withValues(alpha: 0.08),
    thickness: 0.5,
  ),
  tabBarTheme: const TabBarThemeData(
    dividerColor: Colors.transparent,
    indicatorColor: Color(0xFFFF7918),
  ),
);
