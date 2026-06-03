import 'package:flutter/material.dart';

/// Toutes les couleurs de l'application.
/// 
/// Règle : ne jamais écrire une couleur directement dans un widget.
/// Toujours utiliser AppColors.nomDeLaCouleur.
abstract class AppColors {

  // ── Couleur principale ─────────────────────────────────────────
  /// Vert premium — couleur dominante de l'app
  static const primary = Color(0xFF4CAF7A);

  /// Vert foncé — pour les états hover/pressed
  static const primaryDark = Color(0xFF3D9668);

  /// Vert très clair — fond des badges et chips verts
  static const primaryLight = Color(0xFFE8F5EE);

  // ── Couleurs sémantiques ───────────────────────────────────────
  /// Bleu — revenus / entrées d'argent
  static const entree = Color(0xFF3B82F6);

  /// Fond bleu clair — badge entrée
  static const entreeLight = Color(0xFFEFF6FF);

  /// Orange — dépenses / sorties d'argent
  static const sortie = Color(0xFFF59E0B);

  /// Fond orange clair — badge sortie
  static const sortieLight = Color(0xFFFFFBEB);

  /// Rouge — alertes, dépassement de budget
  static const alerte = Color(0xFFEF4444);

  /// Fond rouge clair — badge alerte
  static const alerteLight = Color(0xFFFEF2F2);

  // ── Fonds — Mode clair ─────────────────────────────────────────
  /// Fond principal de l'app (mode clair)
  static const backgroundLight = Color(0xFFF7F8FA);

  /// Fond des cartes (mode clair)
  static const cardLight = Color(0xFFFFFFFF);

  /// Fond des inputs (mode clair)
  static const inputLight = Color(0xFFF3F4F6);

  // ── Fonds — Mode sombre ────────────────────────────────────────
  /// Fond principal de l'app (mode sombre)
  static const backgroundDark = Color(0xFF0F1117);

  /// Fond des cartes (mode sombre)
  static const cardDark = Color(0xFF1C1F2A);

  /// Fond des inputs (mode sombre)
  static const inputDark = Color(0xFF252836);

  /// Fond secondaire (mode sombre) — séparateurs, sous-sections
  static const surfaceDark = Color(0xFF1A1D27);

  // ── Textes — Mode clair ────────────────────────────────────────
  /// Titre principal (mode clair)
  static const textPrimaryLight = Color(0xFF111827);

  /// Texte secondaire / labels (mode clair)
  static const textSecondaryLight = Color(0xFF6B7280);

  /// Texte désactivé / placeholder (mode clair)
  static const textHintLight = Color(0xFFD1D5DB);

  // ── Textes — Mode sombre ───────────────────────────────────────
  /// Titre principal (mode sombre)
  static const textPrimaryDark = Color(0xFFF9FAFB);

  /// Texte secondaire / labels (mode sombre)
  static const textSecondaryDark = Color(0xFF9CA3AF);

  /// Texte désactivé / placeholder (mode sombre)
  static const textHintDark = Color(0xFF4B5563);

  // ── Bordures ───────────────────────────────────────────────────
  /// Bordure légère (mode clair)
  static const borderLight = Color(0xFFE5E7EB);

  /// Bordure légère (mode sombre)
  static const borderDark = Color(0xFF2D3144);

  // ── Ombres ─────────────────────────────────────────────────────
  /// Ombre très légère pour les cartes (mode clair)
  static const shadowLight = Color(0x0A000000);

  /// Ombre très légère pour les cartes (mode sombre)
  static const shadowDark = Color(0x1A000000);

  // ── Méthodes utilitaires ───────────────────────────────────────

  /// Retourne la couleur de fond selon le mode actuel
  static Color background(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;

  /// Retourne la couleur de carte selon le mode actuel
  static Color card(bool isDark) =>
      isDark ? cardDark : cardLight;

  /// Retourne la couleur de texte principal selon le mode actuel
  static Color textPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  /// Retourne la couleur de texte secondaire selon le mode actuel
  static Color textSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;

  /// Retourne la couleur de bordure selon le mode actuel
  static Color border(bool isDark) =>
      isDark ? borderDark : borderLight;

  /// Retourne la couleur d'input selon le mode actuel
  static Color input(bool isDark) =>
      isDark ? inputDark : inputLight;
}