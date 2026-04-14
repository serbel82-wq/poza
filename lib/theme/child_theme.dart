import 'package:flutter/material.dart';

class ChildTheme {
  // Яркая, но не утомляющая палитра
  static const Color primaryColor = Color(0xFF6C63FF); // Насыщенный фиолетовый
  static const Color secondaryColor = Color(0xFFFF6584); // Коралловый розовый
  static const Color accentColor = Color(0xFFFFD166); // Теплый желтый (звезды)
  static const Color successColor = Color(0xFF06D6A0); // Изумрудный (победа)
  static const Color skyColor = Color(0xFF118AB2); // Небесно-голубой
  
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat', // Если шрифта нет, Flutter использует дефолтный
          fontWeight: FontWeight.w900,
          fontSize: 28,
          color: Color(0xFF073B4C),
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Color(0xFF073B4C),
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: const Color(0xFF0D1B2A),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
