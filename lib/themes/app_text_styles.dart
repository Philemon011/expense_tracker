import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tous les styles de texte de l'application.
///
/// Hiérarchie :
///   displayLarge  → Montants principaux (solde total)
///   headlineLarge → Titres d'écran (H1)
///   headlineMedium→ Titres de section (H2)
///   titleLarge    → Titres de carte
///   bodyLarge     → Texte principal
///   bodyMedium    → Texte secondaire
///   labelLarge    → Labels, badges, boutons
///   labelSmall    → Hints, placeholders
abstract class AppTextStyles {

  // ── Montants & chiffres ────────────────────────────────────────

  /// Montant principal — solde total du dashboard
  /// Exemple : "2 450,00 €"
  static TextStyle montantPrincipal(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.5,
      );

  /// Montant moyen — cartes entrées/sorties
  /// Exemple : "+ 1 200,00 €"
  static TextStyle montantMoyen(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.3,
      );

  /// Montant petit — dans les listes d'opérations
  /// Exemple : "- 45,00 €"
  static TextStyle montantPetit({
    required bool isDark,
    required bool isEntree,
  }) =>
      GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        // Vert si entrée, orange si sortie
        color: isEntree ? AppColors.entree : AppColors.sortie,
        letterSpacing: -0.2,
      );

  // ── Titres ─────────────────────────────────────────────────────

  /// Titre d'écran principal — H1
  /// Exemple : "Bonjour, David 👋"
  static TextStyle h1(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.5,
      );

  /// Titre de section — H2
  /// Exemple : "Opérations récentes"
  static TextStyle h2(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.3,
      );

  /// Titre de carte — H3
  /// Exemple : "Solde total"
  static TextStyle h3(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(isDark),
        letterSpacing: 0,
      );

  // ── Corps de texte ─────────────────────────────────────────────

  /// Texte principal — contenu standard
  static TextStyle bodyLarge(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary(isDark),
        height: 1.5,
      );

  /// Texte secondaire — descriptions, sous-titres
  static TextStyle bodyMedium(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(isDark),
        height: 1.4,
      );

  /// Texte petit — informations supplémentaires
  static TextStyle bodySmall(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(isDark),
        height: 1.3,
      );

  // ── Labels & boutons ───────────────────────────────────────────

  /// Label de bouton principal
  /// Exemple : "Ajouter une opération"
  static TextStyle boutonPrimaire() =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      );

  /// Label de bouton secondaire
  static TextStyle boutonSecondaire(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary(isDark),
        letterSpacing: 0.1,
      );

  /// Label — badges, chips, catégories
  static TextStyle label(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(isDark),
        letterSpacing: 0.2,
      );

  /// Hint — placeholders, textes désactivés
  static TextStyle hint(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textHintLight,
      );

  // ── Navigation ─────────────────────────────────────────────────

  /// Label de la bottom navigation bar (actif)
  static TextStyle navActif() =>
      GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  /// Label de la bottom navigation bar (inactif)
  static TextStyle navInactif(bool isDark) =>
      GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(isDark),
      );
}