import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/operation_model.dart';
import '../models/categorie_model.dart';
import '../models/compte_model.dart';
import '../models/budget_model.dart';
import '../utils/constantes.dart';

/// Service central de gestion de Hive.
///
/// Responsabilités :
///   1. Enregistrer tous les TypeAdapters
///   2. Ouvrir toutes les boîtes
///   3. Insérer les données par défaut au premier lancement
///
/// Utilisation :
///   await HiveService.initialiser();  // dans main.dart
///   final box = HiveService.boxOperations;  // accès aux boîtes
class HiveService {

  // ── Accès aux boîtes ───────────────────────────────────────────
  // Getters statiques — accessibles partout dans l'app
  // sans avoir à réécrire Hive.box(nom) à chaque fois

  /// Boîte des préférences utilisateur
  static Box get boxPreferences =>
      Hive.box(Constantes.boxPreferences);

  /// Boîte des opérations (entrées/sorties)
  static Box get boxOperations =>
      Hive.box(Constantes.boxOperations);

  /// Boîte des catégories
  static Box get boxCategories =>
      Hive.box(Constantes.boxCategories);

  /// Boîte des comptes
  static Box get boxComptes =>
      Hive.box(Constantes.boxComptes);

  /// Boîte des budgets
  static Box get boxBudgets =>
      Hive.box(Constantes.boxBudgets);

  // ── Initialisation principale ──────────────────────────────────

  /// Initialise complètement Hive.
  ///
  /// Ordre obligatoire :
  ///   1. Enregistrer les adapters
  ///   2. Ouvrir les boîtes
  ///   3. Insérer les données par défaut si premier lancement
  ///
  /// Appelée une seule fois dans main.dart avant runApp().
  static Future<void> initialiser() async {
    // Étape 1 — Enregistrer tous les TypeAdapters
    _enregistrerAdapters();

    // Étape 2 — Ouvrir toutes les boîtes en parallèle
    await _ouvrirBoites();

    // Étape 3 — Insérer les données par défaut si nécessaire
    await _initialiserDonneesParDefaut();

    debugPrint('✅ HiveService : initialisation terminée');
  }

  // ── Étape 1 : Enregistrement des adapters ─────────────────────

  /// Enregistre tous les TypeAdapters nécessaires.
  ///
  /// Doit être appelé AVANT l'ouverture des boîtes.
  /// Chaque modèle et enum stocké dans Hive a son adapter.
  static void _enregistrerAdapters() {
    // Adapter pour OperationModel
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OperationModelAdapter());
    }

    // Adapter pour l'enum TypeOperation
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TypeOperationAdapter());
    }

    // Adapter pour CategorieModel
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategorieModelAdapter());
    }

    // Adapter pour CompteModel
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CompteModelAdapter());
    }

    // Adapter pour BudgetModel
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }

    // Adapter pour l'enum TypeCompte
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(TypeCompteAdapter());
    }

    debugPrint('✅ HiveService : adapters enregistrés');
  }

  // ── Étape 2 : Ouverture des boîtes ────────────────────────────

  /// Ouvre toutes les boîtes Hive en parallèle.
  ///
  /// Les boîtes typées permettent à Hive de valider
  /// automatiquement les types des objets stockés.
  static Future<void> _ouvrirBoites() async {
    await Future.wait([
      // Boîte simple pour les préférences (pas de modèle)
      Hive.openBox(Constantes.boxPreferences),

      // Boîtes typées pour les modèles
      Hive.openBox<OperationModel>(Constantes.boxOperations),
      Hive.openBox<CategorieModel>(Constantes.boxCategories),
      Hive.openBox<CompteModel>(Constantes.boxComptes),
      Hive.openBox<BudgetModel>(Constantes.boxBudgets),
    ]);

    debugPrint('✅ HiveService : boîtes ouvertes');
  }

  // ── Étape 3 : Données par défaut ──────────────────────────────

  /// Insère les données par défaut au premier lancement.
  ///
  /// Vérifie d'abord si les données existent déjà
  /// pour éviter les doublons à chaque démarrage.
  static Future<void> _initialiserDonneesParDefaut() async {
    await _initialiserCategories();
    await _initialiserComptes();
    debugPrint('✅ HiveService : données par défaut prêtes');
  }

  /// Insère les catégories par défaut si la boîte est vide.
  static Future<void> _initialiserCategories() async {
    final box = Hive.box<CategorieModel>(Constantes.boxCategories);

    // Ne rien faire si des catégories existent déjà
    if (box.isNotEmpty) return;

    // Insérer chaque catégorie avec son id comme clé
    for (final categorie in CategoriesParDefaut.toutes) {
      await box.put(categorie.id, categorie);
    }

    debugPrint(
      '✅ HiveService : ${CategoriesParDefaut.toutes.length} '
      'catégories insérées',
    );
  }

  /// Insère les comptes par défaut si la boîte est vide.
  static Future<void> _initialiserComptes() async {
    final box = Hive.box<CompteModel>(Constantes.boxComptes);

    // Ne rien faire si des comptes existent déjà
    if (box.isNotEmpty) return;

    // Récupérer la devise depuis les préférences
    final devise = boxPreferences.get(
      Constantes.cleDevise,
      defaultValue: Constantes.deviseDefaut,
    ) as String;

    // Insérer chaque compte avec son id comme clé
    for (final compte in ComptesParDefaut.get(devise)) {
      await box.put(compte.id, compte);
    }

    debugPrint('✅ HiveService : comptes par défaut insérés');
  }

  // ── Utilitaires ────────────────────────────────────────────────

  /// Vérifie si c'est le premier lancement de l'app.
  ///
  /// Utilisé pour afficher un écran d'onboarding (future feature).
  static bool get estPremierLancement {
    return boxPreferences.get(
      'premierLancement',
      defaultValue: true,
    ) as bool;
  }

  /// Marque l'app comme déjà lancée.
  static Future<void> marquerLancementEffectue() async {
    await boxPreferences.put('premierLancement', false);
  }

  /// Ferme toutes les boîtes proprement.
  ///
  /// À appeler uniquement à la fermeture de l'app.
  static Future<void> fermerTout() async {
    await Hive.close();
    debugPrint('✅ HiveService : toutes les boîtes fermées');
  }

  /// Supprime toutes les données — ATTENTION irréversible.
  ///
  /// Utilisé uniquement pour les tests ou la réinitialisation
  /// complète depuis les paramètres.
  static Future<void> toutEffacer() async {
    await boxOperations.clear();
    await boxCategories.clear();
    await boxComptes.clear();
    await boxBudgets.clear();
    // On ne touche pas aux préférences utilisateur
    debugPrint('⚠️ HiveService : toutes les données effacées');
  }
}