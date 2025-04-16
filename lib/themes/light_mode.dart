import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//   colorScheme:ColorScheme.light(
//     surface: Colors.grey.shade300,
//     primary: Colors.grey.shade500,
//     secondary: Colors.grey.shade100,
//     tertiary: Colors.white,
//     inversePrimary: Colors.grey.shade700,
//   )
// );

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white, // White background
    primary: Color(
        0xFF1A237E), // Deep blue for primary elements (titles, important text)
    secondary: Color(0xFFE0E0E0), // Light gray for secondary elements
    tertiary: Color(0xFFF5F5F5), // Light gray for tertiary elements
    inversePrimary: Color(0xFF1A1A1A), // Darker text for light mode
    onPrimary: Colors.white, // Text color on primary elements
    onSecondary: Color(0xFF1A1A1A), // Text color on secondary elements
    onTertiary: Color(0xFF1A1A1A), // Text color on tertiary elements
    onSurface: Color(0xFF1A1A1A), // Text color on surface
    onBackground: Color(0xFF1A1A1A), // Text color on background
    onError: Colors.white, // Text color on error elements
    error: Colors.red, // Error color
    background: Colors.white, // Background color
  ),
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
  ),
  appBarTheme: AppBarTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    elevation: 8,
  ),
);
