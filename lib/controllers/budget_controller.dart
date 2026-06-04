
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/budget_model.dart';
import '../models/categorie_model.dart';
import '../services/budget_service.dart';
import '../services/categorie_service.dart';
import '../services/hive_service.dart';
import '../utils/constantes.dart';

/// Controller de gestion des budgets.
///
/// Expose :
///   - Liste réactive des budgets du mois
///   - Progression calculée en temps réel
///   - Alertes et dépassements
///   - CRUD complet
class BudgetController extends GetxController {

  // ── Services ───────────────────────────────────────────────────
  final _budgetService = BudgetService();
  final _categorieService = CategorieService();

  // ── État réactif ───────────────────────────────────────────────

  /// Budgets du mois courant avec progression
  final _budgets = <BudgetAvecProgression>[].obs;
  List<BudgetAvecProgression> get budgets => _budgets;

  /// Vrai pendant le chargement
  final _estEnChargement = true.obs;
  bool get estEnChargement => _estEnChargement.value;

  /// Devise de l'app
  final _devise = Constantes.deviseDefaut.obs;
  String get devise => _devise.value;

  /// Mois affiché — par défaut mois courant
  final _mois = DateTime.now().month.obs;
  int get mois => _mois.value;

  /// Année affichée
  final _annee = DateTime.now().year.obs;
  int get annee => _annee.value;

  // ── Cycle de vie ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initialiser();
  }

  // ── Initialisation ─────────────────────────────────────────────

  Future<void> _initialiser() async {
    _estEnChargement.value = true;
    try {
      // Renouveler les budgets récurrents si nécessaire
      await _budgetService.renouvellerBudgetsRecurrents();
      await Future.wait([
        _chargerBudgets(),
        _chargerDevise(),
      ]);
    } catch (e) {
      debugPrint('❌ BudgetController: erreur → $e');
    } finally {
      _estEnChargement.value = false;
    }
  }

  // ── Chargement ─────────────────────────────────────────────────

  /// Charge les budgets du mois sélectionné avec progression.
  Future<void> _chargerBudgets() async {
    final budgets = _budgetService.budgetsDuMois(
      mois: _mois.value,
      annee: _annee.value,
    );

    // Calculer la progression de chaque budget
    _budgets.value = budgets
        .map((b) => _budgetService.budgetAvecProgression(b))
        .toList()
      ..sort((a, b) {
        // Trier par statut : dépassé > attention > normal
        final ordre = {
          StatutBudget.depasse: 0,
          StatutBudget.attention: 1,
          StatutBudget.normal: 2,
        };
        return ordre[a.statut]!.compareTo(ordre[b.statut]!);
      });
  }

  Future<void> _chargerDevise() async {
    final box = HiveService.boxPreferences;
    _devise.value = box.get(
      Constantes.cleDevise,
      defaultValue: Constantes.deviseDefaut,
    ) as String;
  }

  // ── Navigation période ─────────────────────────────────────────

  /// Passe au mois précédent.
  void moisPrecedent() {
    if (_mois.value == 1) {
      _mois.value = 12;
      _annee.value--;
    } else {
      _mois.value--;
    }
    _chargerBudgets();
  }

  /// Passe au mois suivant — bloqué au mois courant.
  void moisSuivant() {
    final now = DateTime.now();
    if (_mois.value == now.month && _annee.value == now.year) return;
    if (_mois.value == 12) {
      _mois.value = 1;
      _annee.value++;
    } else {
      _mois.value++;
    }
    _chargerBudgets();
  }

  /// Vrai si le mois affiché est le mois courant.
  bool get estMoisCourant {
    final now = DateTime.now();
    return _mois.value == now.month && _annee.value == now.year;
  }

  // ── CRUD ───────────────────────────────────────────────────────

  /// Ajoute un nouveau budget.
  Future<bool> ajouterBudget({
    required String categorieId,
    required double montantMax,
    bool estRecurrent = true,
  }) async {
    try {
      final resultat = await _budgetService.ajouterBudget(
        categorieId: categorieId,
        montantMax: montantMax,
        mois: _mois.value,
        annee: _annee.value,
        estRecurrent: estRecurrent,
      );

      if (!resultat.succes) {
        // Afficher l'erreur via snackbar GetX
        Get.snackbar(
          'Erreur',
          resultat.erreur ?? 'Une erreur est survenue',
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return false;
      }

      await _chargerBudgets();
      return true;
    } catch (e) {
      debugPrint('❌ BudgetController: erreur ajout → $e');
      return false;
    }
  }

  /// Modifie un budget existant.
  Future<bool> modifierBudget(BudgetModel budget) async {
    try {
      final succes = await _budgetService.modifierBudget(budget);
      if (succes) await _chargerBudgets();
      return succes;
    } catch (e) {
      debugPrint('❌ BudgetController: erreur modification → $e');
      return false;
    }
  }

  /// Supprime un budget.
  Future<bool> supprimerBudget(String id) async {
    try {
      final succes = await _budgetService.supprimerBudget(id);
      if (succes) await _chargerBudgets();
      return succes;
    } catch (e) {
      debugPrint('❌ BudgetController: erreur suppression → $e');
      return false;
    }
  }

  // ── Getters utiles ─────────────────────────────────────────────

  /// Retourne une catégorie par son id.
  CategorieModel? categorieParId(String id) =>
      _categorieService.categorieParId(id);

  /// Budgets dépassés du mois courant.
  List<BudgetAvecProgression> get budgetsDepasses =>
      _budgets.where((b) => b.estDepasse).toList();

  /// Budgets en alerte du mois courant.
  List<BudgetAvecProgression> get budgetsEnAlerte =>
      _budgets.where((b) => b.estEnAlerte).toList();

  /// Vrai si au moins un budget est dépassé.
  bool get aDesBudgetsDepasses => budgetsDepasses.isNotEmpty;

  /// Total des montants max de tous les budgets.
  double get totalBudgets =>
      _budgets.fold(0.0, (sum, b) => sum + b.budget.montantMax);

  /// Total dépensé sur tous les budgets.
  double get totalDepense =>
      _budgets.fold(0.0, (sum, b) => sum + b.montantDepense);

  /// Progression globale de tous les budgets.
  double get progressionGlobale {
    if (totalBudgets == 0) return 0;
    return (totalDepense / totalBudgets).clamp(0.0, 1.0);
  }

  /// Catégories disponibles pour créer un budget.
  /// Exclut celles qui ont déjà un budget ce mois.
  List<CategorieModel> get categoriesDisponibles {
    final categoriesAvecBudget =
        _budgets.map((b) => b.budget.categorieId).toSet();

    return _categorieService
        .categoriesPourSorties()
        .where((c) => !categoriesAvecBudget.contains(c.id))
        .toList();
  }

  /// Rafraîchit toutes les données.
  Future<void> rafraichir() async {
    await _chargerBudgets();
  }
}