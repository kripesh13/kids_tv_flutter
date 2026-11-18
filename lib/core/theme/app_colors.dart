import 'package:flutter/material.dart';

class AppColors {
  // Mobile / Playful Kids Palette
  static const Color primary = Color(0xFF6657E8);
  static const Color primaryLight = Color(0xFF8F82FF);
  static const Color primaryDark = Color(0xFF4838C2);

  static const Color secondary = Color(0xFFFFB84D);
  static const Color secondaryLight = Color(0xFFFFD580);
  static const Color secondaryDark = Color(0xFFE59820);

  static const Color accent = Color(0xFFFF6B81);
  static const Color accentLight = Color(0xFFFF9AA9);
  static const Color accentDark = Color(0xFFD63B53);

  static const Color background = Color(0xFFF7F8FF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardSecondary = Color(0xFFF0F2FD);

  static const Color text = Color(0xFF252344);
  static const Color textSecondary = Color(0xFF6D6A8D);
  static const Color textLight = Color(0xFF9E9DB5);

  static const Color success = Color(0xFF42C98A);
  static const Color warning = Color(0xFFFF9F43);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF54A0FF);
  static const Color cyan = Color(0xFF00D2D3);
  static const Color purple = Color(0xFF5F27CD);

  // Android TV Palette (Cinematic High-Contrast Dark Mode)
  static const Color tvPrimary = Color(0xFF6657E8);
  static const Color tvBackground = Color(0xFF0E101A);
  static const Color tvSurface = Color(0xFF161928);
  static const Color tvCard = Color(0xFF1F2338);
  static const Color tvCardHover = Color(0xFF2B314E);
  static const Color tvFocusBorder = Color(0xFFFFB84D);
  static const Color tvFocusGlow = Color(0x66FFB84D);
  static const Color tvText = Color(0xFFF5F6FA);
  static const Color tvTextSecondary = Color(0xFFA4B0BE);

  // Gradient helper for kids playful banners and chips
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6657E8), Color(0xFF8F82FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFFB84D), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B81), Color(0xFFFF4757)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [Color(0xFF6657E8), Color(0xFFFF6B81), Color(0xFFFFB84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000), Color(0xF5000000)],
    stops: [0.3, 0.7, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
