import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tous les styles de texte de l'application.
abstract class AppTextStyles {

  // ── Montants & chiffres ────────────────────────────────────────

  static TextStyle montantPrincipal(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary(isDark),
    letterSpacing: -0.5,
  );

  static TextStyle montantMoyen(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary(isDark),
    letterSpacing: -0.3,
  );

  static TextStyle montantPetit({
    required bool isDark,
    required bool isEntree,
  }) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: isEntree ? AppColors.entree : AppColors.sortie,
    letterSpacing: -0.2,
  );

  // ── Titres ─────────────────────────────────────────────────────

  static TextStyle h1(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary(isDark),
    letterSpacing: -0.5,
  );

  static TextStyle h2(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(isDark),
    letterSpacing: -0.3,
  );

  static TextStyle h3(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary(isDark),
    letterSpacing: 0,
  );

  // ── Corps de texte ─────────────────────────────────────────────

  static TextStyle bodyLarge(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary(isDark),
    height: 1.5,
  );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary(isDark),
    height: 1.4,
  );

  static TextStyle bodySmall(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary(isDark),
    height: 1.3,
  );

  // ── Labels & boutons ───────────────────────────────────────────

  static TextStyle boutonPrimaire() => const TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.1,
  );

  static TextStyle boutonSecondaire(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary(isDark),
    letterSpacing: 0.1,
  );

  static TextStyle label(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary(isDark),
    letterSpacing: 0.2,
  );

  static TextStyle hint(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHintLight,
  );

  // ── Navigation ─────────────────────────────────────────────────

  static TextStyle navActif() => const TextStyle(
    fontFamily: 'Outfit',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle navInactif(bool isDark) => TextStyle(
    fontFamily: 'Outfit',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary(isDark),
  );
}