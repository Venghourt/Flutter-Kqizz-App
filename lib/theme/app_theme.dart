import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xFFf8f9ff),
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF2d3748)),
    ),
    cardColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Color(0xFF4a5568)),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2d3748),
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2d3748),
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Color(0xFF4a5568),
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Color(0xFF4a5568),
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Color(0xFF4a5568),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.blue,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF1E1E1E),
    dialogBackgroundColor: const Color(0xFF1E1E1E),
    iconTheme: const IconThemeData(color: Colors.grey),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    ),
  );

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF2d3748);
  }

  static Color getSubtextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey
        : const Color(0xFF4a5568);
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : const Color(0xFFf8f9ff);
  }

  static LinearGradient getBackgroundGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [
              Color(0xFF121212),
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFf8f9ff),
              Color(0xFFe8eaff),
              Color(0xFFf0f2ff),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }

  static BoxShadow getCardShadow(BuildContext context) {
    return BoxShadow(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    );
  }
}