import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../models/operation_model.dart';
import '../utils/constantes.dart';

/// Service de gestion des budgets dans Hive.
///
/// Responsabilités :
///   - CRUD complet des budgets
///   - Calcul du montant dépensé par rapport au budget
///   - Renouvellement mensuel automatique des budgets récurrents
///   - Détection des dépassements et alertes
class BudgetService {

  // ── Accès aux boîtes Hive ──────────────────────────────────────

  Box<BudgetModel> get _box =>
      Hive.box<BudgetModel>(Constantes.boxBudgets);

  Box<OperationModel> get _boxOperations =>
      Hive.box<OperationModel>(Constantes.boxOperations);

  final _uuid = const Uuid();

  // ── Lecture ────────────────────────────────────────────────────

  /// Retourne tous les budgets du mois et de l'année donnés.
  List<BudgetModel> budgetsDuMois({
    required int mois,
    required int annee,
  }) {
    return _box.values
        .where((b) => b.estPourPeriode(mois, annee))
        .toList();
  }

  /// Retourne le budget du mois courant.
  List<BudgetModel> get budgetsMoisCourant {
    final now = DateTime.now();
    return budgetsDuMois(mois: now.month, annee: now.year);
  }

  /// Retourne un budget par son id.
  BudgetModel? budgetParId(String id) => _box.get(id);

  /// Retourne le budget d'une catégorie pour un mois donné.
  /// Retourne null si aucun budget n'est défini.
  BudgetModel? budgetPourCategorie({
    required String categorieId,
    required int mois,
    required int annee,
  }) {
    try {
      return _box.values.firstWhere(
        (b) => b.categorieId == categorieId &&
               b.estPourPeriode(mois, annee),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Calculs ────────────────────────────────────────────────────

  /// Calcule le montant dépensé pour un budget donné.
  ///
  /// Additionne toutes les sorties de la catégorie
  /// sur la période du budget.
  double montantDepense(BudgetModel budget) {
    return _boxOperations.values
        .where((op) =>
            op.estSortie &&
            op.categorieId == budget.categorieId &&
            op.date.month == budget.mois &&
            op.date.year == budget.annee)
        .fold(0.0, (sum, op) => sum + op.montant);
  }

  /// Retourne les données complètes d'un budget avec
  /// le montant dépensé calculé en temps réel.
  ///
  /// Retourne un objet structuré prêt pour l'UI.
  BudgetAvecProgression budgetAvecProgression(BudgetModel budget) {
    final depense = montantDepense(budget);
    return BudgetAvecProgression(
      budget: budget,
      montantDepense: depense,
      pourcentage: budget.pourcentage(depense),
      montantRestant: budget.montantRestant(depense),
      statut: budget.statut(depense),
    );
  }

  /// Retourne tous les budgets du mois courant avec progression.
  ///
  /// Triés par statut : dépassés en premier, puis en alerte.
  List<BudgetAvecProgression> budgetsMoisCourantAvecProgression() {
    final budgets = budgetsMoisCourant
        .map((b) => budgetAvecProgression(b))
        .toList();

    // Trier par priorité : dépassé > attention > normal
    budgets.sort((a, b) {
      final ordreStatut = {
        StatutBudget.depasse: 0,
        StatutBudget.attention: 1,
        StatutBudget.normal: 2,
      };
      return ordreStatut[a.statut]!.compareTo(ordreStatut[b.statut]!);
    });

    return budgets;
  }

  /// Retourne les budgets dépassés du mois courant.
  ///
  /// Utilisé pour afficher les alertes sur le dashboard.
  List<BudgetAvecProgression> budgetsDepasses() {
    return budgetsMoisCourantAvecProgression()
        .where((b) => b.statut == StatutBudget.depasse)
        .toList();
  }

  /// Retourne les budgets en alerte (75%–99% consommés).
  List<BudgetAvecProgression> budgetsEnAlerte() {
    return budgetsMoisCourantAvecProgression()
        .where((b) => b.statut == StatutBudget.attention)
        .toList();
  }

  // ── CRUD ───────────────────────────────────────────────────────

  /// Ajoute un nouveau budget.
  ///
  /// Vérifie qu'il n'existe pas déjà un budget pour
  /// cette catégorie sur cette période.
  Future<({bool succes, String? erreur, BudgetModel? budget})>
      ajouterBudget({
    required String categorieId,
    required double montantMax,
    required int mois,
    required int annee,
    bool estRecurrent = true,
  }) async {
    // Vérifier qu'aucun budget n'existe déjà pour cette catégorie/période
    final existeDeja = budgetPourCategorie(
      categorieId: categorieId,
      mois: mois,
      annee: annee,
    );

    if (existeDeja != null) {
      return (
        succes: false,
        erreur: 'Un budget existe déjà pour cette catégorie ce mois-ci',
        budget: null,
      );
    }

    final budget = BudgetModel(
      id: _uuid.v4(),
      categorieId: categorieId,
      montantMax: montantMax,
      mois: mois,
      annee: annee,
      estRecurrent: estRecurrent,
    );

    await _box.put(budget.id, budget);
    debugPrint('✅ BudgetService : budget ajouté → ${budget.id}');
    return (succes: true, erreur: null, budget: budget);
  }

  /// Modifie un budget existant.
  Future<bool> modifierBudget(BudgetModel budget) async {
    if (!_box.containsKey(budget.id)) {
      debugPrint('⚠️ BudgetService : budget introuvable → ${budget.id}');
      return false;
    }

    await _box.put(budget.id, budget);
    debugPrint('✅ BudgetService : budget modifié → ${budget.id}');
    return true;
  }

  /// Supprime un budget.
  Future<bool> supprimerBudget(String id) async {
    if (!_box.containsKey(id)) {
      debugPrint('⚠️ BudgetService : budget introuvable → $id');
      return false;
    }

    await _box.delete(id);
    debugPrint('✅ BudgetService : budget supprimé → $id');
    return true;
  }

  // ── Renouvellement mensuel ─────────────────────────────────────

  /// Renouvelle automatiquement les budgets récurrents.
  ///
  /// À appeler au démarrage de l'app pour créer les budgets
  /// du mois courant à partir des budgets récurrents du mois
  /// précédent.
  Future<void> renouvellerBudgetsRecurrents() async {
    final now = DateTime.now();
    final moisCourant = now.month;
    final anneeCourante = now.year;

    // Calculer le mois précédent
    final moisPrecedent = moisCourant == 1 ? 12 : moisCourant - 1;
    final anneePrecedente = moisCourant == 1
        ? anneeCourante - 1
        : anneeCourante;

    // Récupérer les budgets récurrents du mois précédent
    final budgetsPrecedents = budgetsDuMois(
      mois: moisPrecedent,
      annee: anneePrecedente,
    ).where((b) => b.estRecurrent).toList();

    int renouveles = 0;

    for (final budgetPrecedent in budgetsPrecedents) {
      // Vérifier qu'il n'existe pas déjà pour ce mois
      final existeDeja = budgetPourCategorie(
        categorieId: budgetPrecedent.categorieId,
        mois: moisCourant,
        annee: anneeCourante,
      );

      if (existeDeja != null) continue;

      // Créer le budget pour le mois courant
      final nouveauBudget = BudgetModel(
        id: _uuid.v4(),
        categorieId: budgetPrecedent.categorieId,
        montantMax: budgetPrecedent.montantMax,
        mois: moisCourant,
        annee: anneeCourante,
        estRecurrent: true,
      );

      await _box.put(nouveauBudget.id, nouveauBudget);
      renouveles++;
    }

    if (renouveles > 0) {
      debugPrint(
        '✅ BudgetService : $renouveles budget(s) renouvelé(s) '
        'pour $moisCourant/$anneeCourante',
      );
    }
  }

  // ── Utilitaires ────────────────────────────────────────────────

  /// Retourne le nombre de budgets actifs ce mois.
  int get nombreBudgetsMoisCourant => budgetsMoisCourant.length;

  /// Vrai s'il existe au moins un budget dépassé ce mois.
  bool get aDesBudgetsDepasses => budgetsDepasses().isNotEmpty;

  /// Vrai s'il existe au moins un budget en alerte ce mois.
  bool get aDesBudgetsEnAlerte => budgetsEnAlerte().isNotEmpty;
}

// ── Classe de données ──────────────────────────────────────────────

/// Données complètes d'un budget avec sa progression calculée.
///
/// Objet prêt à l'emploi pour l'UI — pas besoin de recalculer
/// dans les widgets.
class BudgetAvecProgression {

  /// Le budget source
  final BudgetModel budget;

  /// Montant dépensé calculé depuis les opérations
  final double montantDepense;

  /// Pourcentage consommé (0.0 à 1.0)
  final double pourcentage;

  /// Montant restant disponible
  final double montantRestant;

  /// Statut actuel du budget
  final StatutBudget statut;

  const BudgetAvecProgression({
    required this.budget,
    required this.montantDepense,
    required this.pourcentage,
    required this.montantRestant,
    required this.statut,
  });

  /// Vrai si le budget est dépassé
  bool get estDepasse => statut == StatutBudget.depasse;

  /// Vrai si le budget est en alerte
  bool get estEnAlerte => statut == StatutBudget.attention;

  /// Pourcentage en format lisible — ex: "75%"
  String get pourcentageTexte =>
      '${(pourcentage * 100).toStringAsFixed(0)}%';
}