import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.charcoal,
      scaffoldBackgroundColor: AppColors.white,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.charcoal,
        secondary: AppColors.camel,
        surface: AppColors.offWhite,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.charcoal,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.charcoal,
          fontSize: 18,
          fontWeight: .w700,
          letterSpacing: 0.5,
        ),
      ),

      // TabBar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.charcoal,
        unselectedLabelColor: AppColors.grey,
        indicatorSize: .label,
        labelStyle: GoogleFonts.outfit(fontWeight: .w700, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontWeight: .w500,
          fontSize: 13,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: .w800,
          color: AppColors.charcoal,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 30,
          fontWeight: .w800,
          color: AppColors.charcoal,
          letterSpacing: -0.3,
          height: 1.1,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: .w700,
          color: AppColors.charcoal,
          letterSpacing: -0.2,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: .w600,
          color: AppColors.charcoal,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: .w700,
          color: AppColors.charcoal,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: .w600,
          color: AppColors.charcoal,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          color: AppColors.charcoal,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: AppColors.charcoal,
          height: 1.3,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          color: AppColors.grey,
          height: 1.2,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: .w800,
          color: AppColors.charcoal,
          letterSpacing: 1.0,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greySubtle,
        side: .none,
        shape: RoundedRectangleBorder(borderRadius: .circular(20)),
        padding: const .symmetric(horizontal: 12, vertical: 6),
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.ink),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        border: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: .none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: BorderSide(color: AppColors.greyLight, width: 1),
        ),
        contentPadding: .symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
