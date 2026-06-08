import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract class AppTheme {

  static ThemeData themeLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.entree,
        surface: AppColors.cardLight,
        error: AppColors.alerte,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // ── Police Outfit locale ───────────────────────────────
      fontFamily: 'Outfit',

      // ── AppBar ─────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimaryLight,
        ),
      ),

      // ── Cartes ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
      ),

      // ── Inputs ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputLight,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),

      // ── Boutons ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppSpacing.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusButton,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Dividers ────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 0,
      ),

      // ── Bottom sheet ─────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusCard),
            topRight: Radius.circular(AppSpacing.radiusCard),
          ),
        ),
        elevation: 0,
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),

      // ── Snack bar ─────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSpacing.radiusSmall),
          ),
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData themeDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.entree,
        surface: AppColors.cardDark,
        error: AppColors.alerte,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // ── Police Outfit locale ───────────────────────────────
      fontFamily: 'Outfit',

      // ── AppBar ─────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimaryDark,
        ),
      ),

      // ── Cartes ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
      ),

      // ── Inputs ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputDark,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),

      // ── Boutons ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppSpacing.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusButton,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Dividers ────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 0,
      ),

      // ── Bottom sheet ─────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusCard),
            topRight: Radius.circular(AppSpacing.radiusCard),
          ),
        ),
        elevation: 0,
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),

      // ── Snack bar ─────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSpacing.radiusSmall),
          ),
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}