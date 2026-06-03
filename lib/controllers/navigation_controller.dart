import 'package:get/get.dart';
import 'package:flutter/services.dart';

/// Contrôleur de navigation principale.
///
/// Gère l'index de l'onglet actif de la bottom nav bar.
/// Observable — tous les widgets qui lisent l'index
/// se mettent à jour automatiquement.
class NavigationController extends GetxController {

  /// Index de l'onglet actif (0 à 3)
  final _indexActuel = 0.obs;

  /// Getter public
  int get indexActuel => _indexActuel.value;

  // ── Constantes des index ───────────────────────────────────────

  static const int indexAccueil = 0;
  static const int indexOperations = 1;
  static const int indexStatistiques = 2;
  static const int indexProfil = 3;

  // ── Navigation ─────────────────────────────────────────────────

  /// Change l'onglet actif.
  ///
  /// Vibre légèrement si l'onglet change.
  /// Ne fait rien si on tape sur l'onglet déjà actif.
  void allerA(int index) {
    if (_indexActuel.value == index) return;
    HapticFeedback.selectionClick();
    _indexActuel.value = index;
  }

  /// Raccourcis de navigation
  void allerAccueil() => allerA(indexAccueil);
  void allerOperations() => allerA(indexOperations);
  void allerStatistiques() => allerA(indexStatistiques);
  void allerProfil() => allerA(indexProfil);
}