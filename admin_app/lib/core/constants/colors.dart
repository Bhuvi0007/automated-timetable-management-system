import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color warmOffWhite = Color.fromARGB(255, 249, 250, 251);
  static const Color trustworthyNavy = Color(0xFF2E5A88);
  static const Color mutedSage = Color(0xFF6B8F71);
  static const Color softTeal = Color(0xFF4DB6AC);
  static const Color terracotta = Color(0xFFCC7357);

  // Gradients
  static const LinearGradient oddSemesterGradient = LinearGradient(
    colors: [Color(0xFFF0F4F8), Color(0xFFE3EBF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient evenSemesterGradient = LinearGradient(
    colors: [Color(0xFFF2F7ED), Color(0xFFE6EFE0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic Colors
  static const Color primary = trustworthyNavy;
  static const Color secondary = softTeal;
  static const Color success = mutedSage;
  static const Color warning = terracotta;
  static const Color surface = warmOffWhite;
}
