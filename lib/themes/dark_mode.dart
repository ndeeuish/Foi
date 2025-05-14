import 'package:flutter/material.dart';

// ThemeData darkMode = ThemeData(
//   colorScheme:ColorScheme.dark(
//     surface: const Color.fromARGB(255, 20, 20, 20),
//     primary: const Color.fromARGB(255, 122, 122, 122),
//     secondary: const Color.fromARGB(255, 30, 30, 30),
//     tertiary: const Color.fromARGB(255, 47, 47, 47),
//     inversePrimary: Colors.grey.shade300,
//   )
// );

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 75, 89, 69), // Dark background
    primary: Color(
        0xFF7986CB), // Light blue for primary elements (titles, important text)
    secondary: Color(0xFF2C2C2C), // Dark gray for secondary elements
    tertiary:
        Color(0xFF3D3D3D), // Slightly lighter dark gray for tertiary elements
    inversePrimary: Color(0xFFF5F5F5), // Brighter text for dark mode
    onPrimary: Colors.white, // Text color on primary elements
    onSecondary: Color(0xFFF5F5F5), // Text color on secondary elements
    onTertiary: Color(0xFFF5F5F5), // Text color on tertiary elements
    onSurface: Color(0xFFF5F5F5), // Text color on surface
    onBackground: Color(0xFFF5F5F5), // Text color on background
    onError: Colors.white, // Text color on error elements
    error: Colors.red, // Error color
    background: const Color.fromARGB(255, 20, 20, 20), // Background color
  ),
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.5),
  ),
  appBarTheme: AppBarTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.5),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    elevation: 8,
  ),
);
