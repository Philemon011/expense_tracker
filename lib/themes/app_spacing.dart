import 'package:flutter/material.dart';

/// Système d'espacement de l'application.
///
/// Basé sur une grille de 4px — standard des apps premium.
///
/// Utilisation :
///   Padding(padding: AppSpacing.paddingPage)
///   SizedBox(height: AppSpacing.lg)
///   BorderRadius.circular(AppSpacing.radiusCard)
abstract class AppSpacing {

  // ── Unités de base ─────────────────────────────────────────────

  /// 4px — unité de base
  static const double xs = 4;

  /// 8px — espacement minimal entre éléments
  static const double sm = 8;

  /// 12px — espacement compact
  static const double md = 12;

  /// 16px — espacement standard
  static const double lg = 16;

  /// 20px — espacement confortable
  static const double xl = 20;

  /// 24px — espacement entre sections
  static const double xxl = 24;

  /// 32px — grand espacement
  static const double xxxl = 32;

  /// 48px — très grand espacement
  static const double huge = 48;

  // ── Padding de page ────────────────────────────────────────────

  /// Padding horizontal des écrans — marges latérales
  static const double pagePaddingHorizontal = 20;

  /// Padding vertical des écrans — marges haut/bas
  static const double pagePaddingVertical = 16;

  /// EdgeInsets complet pour les écrans
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(
    horizontal: pagePaddingHorizontal,
    vertical: pagePaddingVertical,
  );

  /// EdgeInsets horizontal uniquement
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: pagePaddingHorizontal,
  );

  // ── Padding des cartes ─────────────────────────────────────────

  /// Padding interne standard des cartes
  static const EdgeInsets paddingCard = EdgeInsets.all(lg);

  /// Padding interne large des cartes dashboard
  static const EdgeInsets paddingCardLarge = EdgeInsets.all(xxl);

  /// Padding des items de liste (operation_tile)
  static const EdgeInsets paddingListItem = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ── Espacements entre sections ─────────────────────────────────

  /// Espace entre deux sections d'un écran
  static const double sectionSpacing = xxl;

  /// Espace entre deux cartes
  static const double cardSpacing = md;

  /// Espace entre éléments d'une liste
  static const double listItemSpacing = sm;

  // ── Border radius ──────────────────────────────────────────────

  /// Rayon des cartes principales — arrondi doux
  static const double radiusCard = 16;

  /// Rayon des petits éléments — chips, badges
  static const double radiusSmall = 8;

  /// Rayon des boutons
  static const double radiusButton = 12;

  /// Rayon des inputs
  static const double radiusInput = 12;

  /// Rayon des icônes de catégorie
  static const double radiusIcon = 12;

  /// Rayon full — pilules, tags arrondis
  static const double radiusFull = 100;

  // ── Border radius en objets ────────────────────────────────────

  /// BorderRadius pour les cartes
  static final BorderRadius borderRadiusCard =
      BorderRadius.circular(radiusCard);

  /// BorderRadius pour les boutons
  static final BorderRadius borderRadiusButton =
      BorderRadius.circular(radiusButton);

  /// BorderRadius pour les inputs
  static final BorderRadius borderRadiusInput =
      BorderRadius.circular(radiusInput);

  /// BorderRadius pour les petits éléments
  static final BorderRadius borderRadiusSmall =
      BorderRadius.circular(radiusSmall);

  // ── Tailles fixes ──────────────────────────────────────────────

  /// Hauteur des boutons principaux
  static const double buttonHeight = 56;

  /// Hauteur des inputs
  static const double inputHeight = 56;

  /// Hauteur de la bottom navigation bar
  static const double bottomNavHeight = 70;

  /// Taille des icônes de navigation
  static const double navIconSize = 24;

  /// Taille des icônes de catégorie
  static const double categoryIconSize = 20;

  /// Taille des icônes dans les listes
  static const double listIconSize = 44;

  // ── Ombres ─────────────────────────────────────────────────────

  /// Ombre légère pour les cartes (mode clair)
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Ombre légère pour les cartes (mode sombre)
  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// Ombre pour les cartes selon le mode
  static List<BoxShadow> cardShadow(bool isDark) =>
      isDark ? cardShadowDark : cardShadowLight;
}