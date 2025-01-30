import 'package:flutter/material.dart';

class AppColors {
  static Color primary = const Color(0xFF6fa4dd);
  static Color secondary = const Color(0xFF03DAC5);
  static Color background = const Color(0xFFF5F5F5);
  static Color surface = Colors.white;
  static Color error = const Color(0xFFB00020);
  static Color warning = const Color(0xFFFFA726);
  static Color text = const Color(0xFF1D1D1D);
  static Color textLight = const Color(0xFF6E6E6E);
  static Color textDark = const Color(0xFF212121);
  
  static LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primary.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color success = Colors.green;
}

