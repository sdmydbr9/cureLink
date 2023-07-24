import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData defaultTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: CupertinoColors.systemGrey,
    ),
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.black,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.black.withAlpha(50),
      focusColor: Colors.black,
      hoverColor: Colors.black,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 44, 42, 42),
      ),
      hintStyle: const TextStyle(
        color: Color.fromARGB(255, 29, 28, 28),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
  );

  static final ThemeData lightTheme = defaultTheme;

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white.withAlpha(50),
      focusColor: Colors.white,
      hoverColor: Colors.white,
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
      hintStyle: const TextStyle(
        color: Colors.white,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: Colors.white,
    ),
  );
}
