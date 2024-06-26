import 'package:flutter/material.dart';

/*
# README
1. These just placeholders for quicker implementation in the future
2. Still pending Figma design for overall theme
3. This is just a basic theme for now
*/

class AppTheme {
  AppTheme._();

  // Colors 颜色
  static const mercuryWhite = Color(0xFFF4F5F8);
  static const nordicGrey = Color(0xFF222326);
  static const boldRed = Color(0xFFCC0000);

  // Text Styles 文本样式
  static const TextStyle appBarTextStyle = TextStyle(
    fontSize: 20.0,
    color: mercuryWhite,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 24.0,
    color: mercuryWhite,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    color: nordicGrey,
    fontWeight: FontWeight.bold,
  );

  // AppBar
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: nordicGrey,
    foregroundColor: mercuryWhite,
    titleTextStyle: appBarTextStyle,
    elevation: 0,
    iconTheme: IconThemeData(color: mercuryWhite),
  );

  // Color Scheme
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: nordicGrey,
    secondary: nordicGrey,
    error: boldRed,
  );

  // Icon Theme
  static const IconThemeData _lightIconTheme = IconThemeData(
    color: nordicGrey,
  );

  // Text Theme
  static const TextTheme _lightTextTheme = TextTheme(
    titleLarge: titleLarge,
    bodyLarge: bodyLarge,
    // titleMedium, titleSmall, bodyMedium, bodySmall, etc
  );

  // Themes 主题
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: mercuryWhite,
    appBarTheme: _lightAppBarTheme,
    colorScheme: _lightColorScheme,
    iconTheme: _lightIconTheme,
    textTheme: _lightTextTheme,
  );
}
