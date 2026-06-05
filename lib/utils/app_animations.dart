import 'package:flutter/material.dart';

/// Constantes d'animations de l'application.
///
/// Utilisation :
///   .animate().fadeIn(duration: AppAnimations.rapide)
///   AnimatedContainer(duration: AppAnimations.standard)
abstract class AppAnimations {

  // ── Durées ─────────────────────────────────────────────────────

  /// 150ms — micro-interactions (press, toggle)
  static const Duration microInteraction =
      Duration(milliseconds: 150);

  /// 200ms — changements d'état rapides
  static const Duration rapide = Duration(milliseconds: 200);

  /// 300ms — transitions standard
  static const Duration standard = Duration(milliseconds: 300);

  /// 400ms — entrées d'écrans et cartes
  static const Duration entree = Duration(milliseconds: 400);

  /// 500ms — animations complexes
  static const Duration lente = Duration(milliseconds: 500);

  /// 600ms — barres de progression
  static const Duration progression = Duration(milliseconds: 600);

  /// 800ms — animations d'accroche (barre entrées/sorties)
  static const Duration accroche = Duration(milliseconds: 800);

  // ── Courbes ────────────────────────────────────────────────────

  /// Courbe standard — entrée douce, sortie douce
  static const Curve standard_curve = Curves.easeInOut;

  /// Courbe entrée — accélération puis décélération
  static const Curve entree_curve = Curves.easeOut;

  /// Courbe rebond — effet élastique pour les icônes
  static const Curve rebond = Curves.elasticOut;

  /// Courbe overshoot — léger dépassement
  static const Curve overshoot = Curves.easeOutBack;

  // ── Délais en cascade ──────────────────────────────────────────

  /// Délai entre chaque élément d'une liste
  static Duration cascade(int index, {int baseMs = 50}) {
    return Duration(milliseconds: baseMs * index);
  }

  /// Délai entre chaque carte d'une grille
  static Duration casadeGrille(int index, {int baseMs = 80}) {
    return Duration(milliseconds: baseMs * index);
  }

  // ── Configurations flutter_animate prêtes à l'emploi ──────────

  /// Animation d'entrée standard pour une carte.
  ///
  /// Utilisation :
  ///   MonWidget()
  ///     .animate(delay: AppAnimations.cascade(index))
  ///     .then()
  ///     .fadeIn(duration: AppAnimations.entree)
  ///     .slideY(begin: 0.1, end: 0)
  static const double slideYDebut = 0.1;
  static const double slideXDebut = 0.1;
}