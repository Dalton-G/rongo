import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
# README
1. These just placeholders for quicker implementation in the future
2. Still pending Figma design for overall theme
3. This is just a basic theme for now
*/

class AppTheme {
  AppTheme._();

  // Colors 颜色
  // static const mercuryWhite = Color(0xFFF4F5F8);
  // static const nordicGrey = Color(0xFF222326);
  // static const boldRed = Color(0xFFCC0000);
  //
  //
  // // Text Styles 文本样式
  // static const TextStyle appBarTextStyle = TextStyle(
  //   fontSize: 20.0,
  //   color: mercuryWhite,
  //   fontWeight: FontWeight.bold,
  // );
  //
  // static const TextStyle titleLarge = TextStyle(
  //   fontSize: 24.0,
  //   color: mercuryWhite,
  //   fontWeight: FontWeight.bold,
  // );
  //
  // static const TextStyle bodyLarge = TextStyle(
  //   fontSize: 16.0,
  //   color: nordicGrey,
  //   fontWeight: FontWeight.bold,
  // );
  //
  // // AppBar
  // static const AppBarTheme _lightAppBarTheme = AppBarTheme(
  //   backgroundColor: nordicGrey,
  //   foregroundColor: mercuryWhite,
  //   titleTextStyle: appBarTextStyle,
  //   elevation: 0,
  //   iconTheme: IconThemeData(color: mercuryWhite),
  // );
  //
  // // Color Scheme
  // static const ColorScheme _lightColorScheme = ColorScheme.light(
  //   primary: nordicGrey,
  //   secondary: nordicGrey,
  //   error: boldRed,
  // );
  //
  // // Icon Theme
  // static const IconThemeData _lightIconTheme = IconThemeData(
  //   color: nordicGrey,
  // );
  //
  // // Text Theme
  // static const TextTheme _lightTextTheme = TextTheme(
  //   titleLarge: titleLarge,
  //   bodyLarge: bodyLarge,
  //
  //   // titleMedium, titleSmall, bodyMedium, bodySmall, etc
  // );

  // Themes 主题
  // static final ThemeData lightTheme = ThemeData(
  //   scaffoldBackgroundColor: mercuryWhite,
  //   appBarTheme: _lightAppBarTheme,
  //   colorScheme: _lightColorScheme,
  //   iconTheme: _lightIconTheme,
  //   textTheme: _lightTextTheme,
  // );

  // JL
  static const mainGreen = Color(0xff25995C);
  static const backgroundWhite = Color(0xffFAFAFA);

  static BoxDecoration widgetDeco({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.withOpacity(0.30)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 3,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    );
  }

//suzanne

  static TextStyle blackBodyText = GoogleFonts.nunito(
    textStyle: TextStyle(
      fontSize: 16,
      color: Colors.grey[900],
    ),
  );

  static TextStyle blackAppBarText = GoogleFonts.nunito(
    textStyle: TextStyle(
      fontSize: 18,
      color: Colors.grey[900],
    ),
  );

  static TextStyle greenAppBarText = GoogleFonts.nunito(
    textStyle: TextStyle(
      fontSize: 18,
      color: mainGreen,
    ),
  );

  static TextStyle whiteButtonText = GoogleFonts.nunito(
    textStyle: TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextStyle buttonText() {
    return TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600);
  }

  static AppBarTheme _lightAppBarTheme = AppBarTheme(
    centerTitle: true,
    backgroundColor: backgroundWhite,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.nunito(
        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
    elevation: 0,
    iconTheme: IconThemeData(color: mainGreen),
  );

  static const IconThemeData _lightIconTheme = IconThemeData(
    color: mainGreen,
  );

  static final ThemeData lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: mainGreen),
      primarySwatch: generateMaterialColor(mainGreen),
      scaffoldBackgroundColor: backgroundWhite,
      appBarTheme: _lightAppBarTheme,
      iconTheme: _lightIconTheme,
      textTheme: GoogleFonts.nunitoTextTheme()
      //     .copyWith(
      //   displayLarge: TextStyle(fontWeight: FontWeight.w500),
      //   displayMedium: TextStyle(fontWeight: FontWeight.w500),
      //   displaySmall: TextStyle(fontWeight: FontWeight.w500),
      //   headlineMedium: TextStyle(fontWeight: FontWeight.w500),
      //   headlineSmall: TextStyle(fontWeight: FontWeight.w500),
      //   titleLarge: TextStyle(fontWeight: FontWeight.w500),
      //   titleMedium: TextStyle(fontWeight: FontWeight.w500),
      //   titleSmall: TextStyle(fontWeight: FontWeight.w500),
      //   bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      //   bodyMedium: TextStyle(fontWeight: FontWeight.w500),
      //   bodySmall: TextStyle(fontWeight: FontWeight.w500),
      //   labelLarge: TextStyle(fontWeight: FontWeight.w500),
      //   labelSmall: TextStyle(fontWeight: FontWeight.w500),
      // ),
      );
}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);
