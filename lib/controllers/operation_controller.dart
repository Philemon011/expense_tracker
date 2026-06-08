import 'package:expense_tracker/controllers/budget_controller.dart';
import 'package:expense_tracker/controllers/compte_controller.dart';
import 'package:expense_tracker/controllers/notification_controller.dart';
import 'package:expense_tracker/controllers/statistique_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/operation_model.dart';
import '../models/categorie_model.dart';
import '../models/compte_model.dart';
import '../services/operation_service.dart';
import '../services/categorie_service.dart';
import '../services/compte_service.dart';
import '../utils/constantes.dart';
import 'package:hive/hive.dart';

/// Controller principal des opérations.
///
/// Expose toutes les données réactives pour l'UI :
///   - Liste des opérations
///   - Solde total
///   - Totaux entrées/sorties du mois
///   - Opérations récentes
///   - Catégories et comptes
///
/// Utilisation dans un widget :
///   final ctrl = Get.find<OperationController>();
///   ctrl.soldeTotal → double
///   ctrl.operationsRecentes → List<OperationModel>
class OperationController extends GetxController {
  // ── Services ───────────────────────────────────────────────────
  final _operationService = OperationService();
  final _categorieService = CategorieService();
  final _compteService = CompteService();

  // ── État réactif ───────────────────────────────────────────────

  /// Toutes les opérations triées par date
  final _operations = <OperationModel>[].obs;

  /// Catégories disponibles
  final _categories = <CategorieModel>[].obs;

  /// Comptes disponibles
  final _comptes = <CompteModel>[].obs;

  /// Mois actuellement sélectionné pour les filtres
  final _moisSelectionne = DateTime.now().month.obs;

  /// Année actuellement sélectionnée pour les filtres
  final _anneeSelectionnee = DateTime.now().year.obs;

  /// Vrai pendant le chargement initial
  final _estEnChargement = true.obs;

  /// Devise de l'utilisateur
  final _devise = Constantes.deviseDefaut.obs;

  /// Nom de l'utilisateur
  final _nomUtilisateur = Constantes.nomUtilisateurDefaut.obs;

  // ── Getters publics ────────────────────────────────────────────

  List<OperationModel> get operations => _operations;
  List<CategorieModel> get categories => _categories;
  List<CompteModel> get comptes => _comptes;
  int get moisSelectionne => _moisSelectionne.value;
  int get anneeSelectionnee => _anneeSelectionnee.value;
  bool get estEnChargement => _estEnChargement.value;
  String get devise => _devise.value;
  String get nomUtilisateur => _nomUtilisateur.value;

// ── Variables observables calculées ───────────────────────────

  /// Solde total de tous les comptes
  final _soldeTotal = 0.0.obs;
  double get soldeTotal => _soldeTotal.value;

  /// Total des entrées du mois sélectionné
  final _totalEntreesMois = 0.0.obs;
  double get totalEntreesMois => _totalEntreesMois.value;

  /// Total des sorties du mois sélectionné
  final _totalSortiesMois = 0.0.obs;
  double get totalSortiesMois => _totalSortiesMois.value;

  /// 5 dernières opérations pour le dashboard
  final _operationsRecentes = <OperationModel>[].obs;
  List<OperationModel> get operationsRecentes => _operationsRecentes;

  /// Opérations du mois sélectionné
  final _operationsDuMois = <OperationModel>[].obs;
  List<OperationModel> get operationsDuMois => _operationsDuMois;

  /// Totaux par catégorie — graphique donut
  final _totauxParCategorie = <String, double>{}.obs;
  Map<String, double> get totauxParCategorie => _totauxParCategorie;

  /// Totaux entrées par mois — graphique barres
  final _totauxEntreesParMois = <int, double>{}.obs;
  Map<int, double> get totauxEntreesParMois => _totauxEntreesParMois;

  /// Totaux sorties par mois — graphique barres
  final _totauxSortiesParMois = <int, double>{}.obs;
  Map<int, double> get totauxSortiesParMois => _totauxSortiesParMois;

  // ── Cycle de vie ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Charger toutes les données au démarrage
    _chargerTout();
  }

  // ── Chargement des données ─────────────────────────────────────

  /// Charge toutes les données depuis Hive.
  Future<void> _chargerTout() async {
    _estEnChargement.value = true;
    try {
      await Future.wait([
        _chargerOperations(),
        _chargerCategories(),
        _chargerComptes(), // ← Vérifie que cette ligne est bien là
        _chargerPreferences(),
      ]);
    } catch (e) {
      debugPrint('❌ OperationController: erreur chargement → $e');
    } finally {
      _estEnChargement.value = false;
    }
  }

  /// Charge les opérations depuis Hive et recalcule tout
  Future<void> _chargerOperations() async {
    _operations.value = _operationService.toutesLesOperations();
    // Recalculer toutes les valeurs dérivées
    _recalculer();
  }

  /// Recalcule toutes les valeurs dérivées.
  ///
  /// Appelée après chaque modification des opérations
  /// pour mettre à jour tous les widgets Obx.
  void _recalculer() {
    final mois = _moisSelectionne.value;
    final annee = _anneeSelectionnee.value;

    // Recalculer les totaux
    _soldeTotal.value = _compteService.calculerSoldeTotal();
    _totalEntreesMois.value = _operationService.calculerTotalEntrees(
      mois: mois,
      annee: annee,
    );
    _totalSortiesMois.value = _operationService.calculerTotalSorties(
      mois: mois,
      annee: annee,
    );

    // Recalculer les listes
    _operationsRecentes.value =
        _operationService.dernieresOperations(limite: 5);
    _operationsDuMois.value = _operationService.operationsParMois(
      mois: mois,
      annee: annee,
    );

    // Recalculer les maps pour les graphiques
    _totauxParCategorie.value = _operationService.totauxParCategorie(
      mois: mois,
      annee: annee,
    );
    _totauxEntreesParMois.value = _operationService.totauxParMoisAnnee(
      annee: annee,
      type: TypeOperation.entree,
    );
    _totauxSortiesParMois.value = _operationService.totauxParMoisAnnee(
      annee: annee,
      type: TypeOperation.sortie,
    );
  }

  /// Charge les catégories depuis Hive
  Future<void> _chargerCategories() async {
    _categories.value = _categorieService.toutesLesCategories();
  }

  /// Charge les comptes depuis Hive
  Future<void> _chargerComptes() async {
    _comptes.value = _compteService.tousLesComptes();
  }

  /// Charge les préférences utilisateur
  Future<void> _chargerPreferences() async {
    final box = Hive.box(Constantes.boxPreferences);
    _devise.value = box.get(
      Constantes.cleDevise,
      defaultValue: Constantes.deviseDefaut,
    ) as String;
    _nomUtilisateur.value = box.get(
      Constantes.cleNomUtilisateur,
      defaultValue: Constantes.nomUtilisateurDefaut,
    ) as String;
  }

  // ── CRUD Opérations ────────────────────────────────────────────

  /// Ajoute une nouvelle opération.
  ///
  /// Met à jour la liste réactive après l'ajout.
  /// Ajoute une nouvelle opération.
Future<bool> ajouterOperation({
  required double montant,
  required TypeOperation type,
  required String categorieId,
  required String compteId,
  required DateTime date,
  String? note,
}) async {
  try {
    await _operationService.ajouterOperation(
      montant: montant,
      type: type,
      categorieId: categorieId,
      compteId: compteId,
      date: date,
      note: note,
    );

    await _chargerOperations();
    update();

    // Notifier tous les controllers dépendants
    if (Get.isRegistered<StatistiqueController>()) {
      Get.find<StatistiqueController>().rafraichir();
    }
    if (Get.isRegistered<BudgetController>()) {
      Get.find<BudgetController>().rafraichir();
    }
    // ── CORRECTION ──────────────────────────────────────────
    if (Get.isRegistered<CompteController>()) {
      await Get.find<CompteController>().rafraichir();
    }
    // Générer les notifications si nécessaire
if (Get.isRegistered<NotificationController>()) {
  Get.find<NotificationController>().verifierEtGenerer();
}


    return true;
  } catch (e) {
    debugPrint('❌ OperationController: erreur ajout → $e');
    return false;
  }
}

/// Modifie une opération existante.
Future<bool> modifierOperation(OperationModel operation) async {
  try {
    final succes = await _operationService.modifierOperation(operation);
    if (succes) {
      await _chargerOperations();
      update();

      if (Get.isRegistered<StatistiqueController>()) {
        Get.find<StatistiqueController>().rafraichir();
      }
      if (Get.isRegistered<BudgetController>()) {
        Get.find<BudgetController>().rafraichir();
      }
      // ── CORRECTION ────────────────────────────────────────
      if (Get.isRegistered<CompteController>()) {
        await Get.find<CompteController>().rafraichir();
      }

      // Générer les notifications si nécessaire
if (Get.isRegistered<NotificationController>()) {
  Get.find<NotificationController>().verifierEtGenerer();
}
    }
    return succes;
  } catch (e) {
    debugPrint('❌ OperationController: erreur modification → $e');
    return false;
  }
}

/// Supprime une opération par son id.
Future<bool> supprimerOperation(String id) async {
  try {
    final succes = await _operationService.supprimerOperation(id);
    if (succes) {
      await _chargerOperations();
      update();

      if (Get.isRegistered<StatistiqueController>()) {
        Get.find<StatistiqueController>().rafraichir();
      }
      if (Get.isRegistered<BudgetController>()) {
        Get.find<BudgetController>().rafraichir();
      }
      // ── CORRECTION ────────────────────────────────────────
      if (Get.isRegistered<CompteController>()) {
        await Get.find<CompteController>().rafraichir();
      }

      // Générer les notifications si nécessaire
if (Get.isRegistered<NotificationController>()) {
  Get.find<NotificationController>().verifierEtGenerer();
}
    }
    return succes;
  } catch (e) {
    debugPrint('❌ OperationController: erreur suppression → $e');
    return false;
  }
}

  // ── Filtres ────────────────────────────────────────────────────

  /// Change le mois sélectionné pour les filtres.
  void changerMois(int mois, int annee) {
    _moisSelectionne.value = mois;
    _anneeSelectionnee.value = annee;
    _recalculer(); // ← Ajouter
  }

  /// Passe au mois précédent.
  void moisPrecedent() {
    if (_moisSelectionne.value == 1) {
      _moisSelectionne.value = 12;
      _anneeSelectionnee.value--;
    } else {
      _moisSelectionne.value--;
    }
    _recalculer(); // ← Ajouter
  }

  /// Passe au mois suivant.
  void moisSuivant() {
    final now = DateTime.now();
    final estMoisCourant = _moisSelectionne.value == now.month &&
        _anneeSelectionnee.value == now.year;

    if (estMoisCourant) return;

    if (_moisSelectionne.value == 12) {
      _moisSelectionne.value = 1;
      _anneeSelectionnee.value++;
    } else {
      _moisSelectionne.value++;
    }
    _recalculer(); // ← Ajouter
  }

  /// Vrai si le mois sélectionné est le mois courant
  bool get estMoisCourant {
    final now = DateTime.now();
    return _moisSelectionne.value == now.month &&
        _anneeSelectionnee.value == now.year;
  }

  // ── Utilitaires ────────────────────────────────────────────────

  /// Retourne une catégorie par son id.
  CategorieModel? categorieParId(String id) =>
      _categorieService.categorieParId(id);

  /// Retourne un compte par son id.
  CompteModel? compteParId(String id) => _compteService.compteParId(id);

  /// Retourne le solde d'un compte spécifique.
  double soldeCompte(String compteId) => _compteService.calculerSolde(compteId);

  /// Met à jour le nom de l'utilisateur.
  Future<void> mettreAJourNom(String nom) async {
    final box = Hive.box(Constantes.boxPreferences);
    await box.put(Constantes.cleNomUtilisateur, nom);
    _nomUtilisateur.value = nom;
  }

  /// Met à jour la devise.
  Future<void> mettreAJourDevise(String devise) async {
    final box = Hive.box(Constantes.boxPreferences);
    await box.put(Constantes.cleDevise, devise);
    _devise.value = devise;
    update();
  }

  /// Rafraîchit toutes les données manuellement.
  /// Appelé après des modifications importantes.
  Future<void> rafraichir() async {
    await _chargerTout();
    update();
  }
}
