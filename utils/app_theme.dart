import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ===== PRIMARY COLOR SCHEME =====
  // Main: Red (Dominan - Merah)
  static const Color primaryRed = Color(0xFFD92F21);         // Dominan Red
  static const Color primaryRedDark = Color(0xFFB91C1C);     // Darker Red
  static const Color primaryRedLight = Color(0xFFEF5A48);    // Bright Red

  // Legacy Blue (untuk secondary accents)
  static const Color secondaryBlue = Color(0xFF3B82F6);      // Secondary Blue
  static const Color secondaryBlueDark = Color(0xFF1E40AF);  // Darker Blue

  // ===== STATUS COLORS (SEMANTIC) =====
  // Available: Green (indicates available/good)
  static const Color successGreen = Color(0xFF16A34A);       // Available - Green
  static const Color successGreenLight = Color(0xFFDCEDC5);  // Available Light BG
  static const Color successGreenDark = Color(0xFF15803D);   // Available Dark

  // Booked: Red variant (indicates unavailable/warning)
  static const Color errorRed = Color(0xFFDC2626);           // Error - Red
  static const Color errorRedLight = Color(0xFFFEE2E2);      // Error Light BG
  static const Color errorRedDark = Color(0xFFB91C1C);       // Error Dark

  // ===== NEUTRAL COLORS =====
  static const Color warningYellow = Color(0xFFF59E0B);      // Pending/Warning
  static const Color warningYellowLight = Color(0xFFFEF3C7); // Warning Light BG
  static const Color infoBlue = Color(0xFF0EA5E9);           // Info/Highlight

  // ===== BACKGROUND COLORS =====
  static const Color creamBackground = Color(0xFFF8FAFC);    // Light Gray-Blue
  static const Color lightCream = Color(0xFFFDF7F0);         // Very Light
  static const Color cardBackground = Color(0xFFFFFFFF);     // Pure White
  static const Color darkBackground = Color(0xFF0F172A);     // Dark (if needed)

  // ===== TEXT COLORS =====
  static const Color primaryText = Color(0xFF0F172A);        // Near Black
  static const Color secondaryText = Color(0xFF64748B);      // Gray
  static const Color lightText = Color(0xFFCBD5E1);          // Light Gray
  static const Color disabledText = Color(0xFFE2E8F0);       // Disabled Gray

  // ===== STRUCTURAL COLORS =====
  static const Color borderColor = Color(0xFFE2E8F0);        // Light Border
  static const Color borderColorDark = Color(0xFFCBD5E1);    // Dark Border
  static const Color shadowColor = Color(0xFF000000);        // For shadows

  // ===== ACCENT COLORS =====
  static const Color accentOrange = Color(0xFFF97316);       // Accent Orange
  static const Color accentPurple = Color(0xFFA855F7);       // Accent Purple

  // ===== GRADIENTS =====
  // Primary Gradient: RED theme (Dominan)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryRedLight],
  );

  // Available Status Gradient: Green
  static const LinearGradient availableGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
  );

  // Booked Status Gradient: Darker Red
  static const LinearGradient bookedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
  );

  // Card Gradient: Subtle white
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // Header Gradient: Premium Red
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryRedLight],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryRed,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        brightness: Brightness.light,
        background: AppColors.creamBackground,
        surface: AppColors.cardBackground,
      ),
      scaffoldBackgroundColor: AppColors.creamBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.primaryText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.secondaryText,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.lightText,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 14,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryRed,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

// Custom widget styles and decorations
class AppDecorations {
  static BoxDecoration gradientContainer = const BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration softShadowDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

// Padding and spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
