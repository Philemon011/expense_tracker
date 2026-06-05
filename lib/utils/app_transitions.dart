import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Transitions de navigation centralisées.
///
/// Utilisation :
///   Get.to(() => MonEcran(), ...AppTransitions.slideUp)
///   Get.to(() => MonEcran(), ...AppTransitions.fadeIn)
abstract class AppTransitions {

  // ── Slide vers le haut — pour les modals et formulaires ───────
  /// Utilisé pour : ajout opération, ajout compte, ajout budget
  static Map<String, dynamic> get slideUp => {
    'transition': Transition.downToUp,
    'duration': const Duration(milliseconds: 400),
    'curve': Curves.easeOut,
  };

  // ── Slide depuis la droite — pour la navigation en avant ──────
  /// Utilisé pour : détails, sous-écrans
  static Map<String, dynamic> get slideRight => {
    'transition': Transition.rightToLeft,
    'duration': const Duration(milliseconds: 300),
    'curve': Curves.easeOut,
  };

  // ── Fade — pour les écrans sans direction claire ──────────────
  /// Utilisé pour : transitions neutres
  static Map<String, dynamic> get fade => {
    'transition': Transition.fadeIn,
    'duration': const Duration(milliseconds: 250),
  };

  // ── Méthodes utilitaires ───────────────────────────────────────

  /// Navigue vers un écran avec slide vers le haut.
  /// Idéal pour les formulaires et modals.
  static Future<T?> versModal<T>(Widget ecran) {
    return Get.to<T>(
      () => ecran,
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    )!;
  }

  /// Navigue vers un écran avec slide depuis la droite.
  /// Idéal pour la navigation en profondeur.
  static Future<T?> versSousEcran<T>(Widget ecran) {
    return Get.to<T>(
      () => ecran,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    )!;
  }

  /// Navigue vers un écran avec fade.
  static Future<T?> versFade<T>(Widget ecran) {
    return Get.to<T>(
      () => ecran,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 250),
    )!;
  }
}