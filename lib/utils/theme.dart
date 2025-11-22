import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.authorPrimary,
    scaffoldBackgroundColor: AppColors.background,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.authorPrimary,
      primary: AppColors.authorPrimary,
      secondary: AppColors.warning,
      tertiary: AppColors.reviewerPrimary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.authorPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.mediumRadius,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.authorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppStyles.mediumRadius,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.authorPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.authorPrimary,
        side: const BorderSide(color: AppColors.authorPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppStyles.mediumRadius,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(AppSizes.paddingM),
      border: OutlineInputBorder(
        borderRadius: AppStyles.mediumRadius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppStyles.mediumRadius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppStyles.mediumRadius,
        borderSide: const BorderSide(
          color: AppColors.authorPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppStyles.mediumRadius,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: AppStyles.body2,
      hintStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.authorPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.authorPrimary,
      unselectedItemColor: AppColors.textMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppStyles.heading1,
      displayMedium: AppStyles.heading2,
      displaySmall: AppStyles.heading3,
      titleLarge: AppStyles.subtitle1,
      titleMedium: AppStyles.subtitle2,
      bodyLarge: AppStyles.body1,
      bodyMedium: AppStyles.body2,
      bodySmall: AppStyles.caption,
    ),
  );
  
  // Author Theme (Xanh lá)
  static ThemeData get authorTheme => lightTheme.copyWith(
    primaryColor: AppColors.authorPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.authorPrimary,
      foregroundColor: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );
  
  // Reviewer Theme (Xanh dương)
  static ThemeData reviewerTheme = lightTheme.copyWith(
    primaryColor: AppColors.reviewerPrimary,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.reviewerPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.reviewerPrimary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.reviewerPrimary,
    ),
  );
  
  // Admin Theme (Cam vàng)
  static ThemeData adminTheme = lightTheme.copyWith(
    textTheme: GoogleFonts.interTextTheme(),
    primaryColor: AppColors.adminPrimary,
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.adminPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.adminPrimary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.adminPrimary,
    ),
  );
  
  // Dark Theme (optional - currently same as light)
  static ThemeData darkTheme = lightTheme.copyWith(
    textTheme: GoogleFonts.interTextTheme(),
  );
}