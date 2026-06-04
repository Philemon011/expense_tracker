import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/operation_model.dart';
import '../models/categorie_model.dart';
import '../services/operation_service.dart';
import '../services/categorie_service.dart';
import '../services/compte_service.dart';
import '../utils/constantes.dart';
import '../services/hive_service.dart';

/// Controller des statistiques et graphiques.
///
/// Prépare toutes les données pour :
///   - Graphique barres (revenus/dépenses par mois)
///   - Graphique donut (répartition par catégorie)
///   - Graphique courbe (évolution du solde)
///   - Comparatifs mois/mois
class StatistiqueController extends GetxController {

  // ── Services ───────────────────────────────────────────────────
  final _operationService = OperationService();
  final _categorieService = CategorieService();
  final _compteService = CompteService();

  // ── État réactif ───────────────────────────────────────────────

  /// Année sélectionnée pour les graphiques
  final _annee = DateTime.now().year.obs;
  int get annee => _annee.value;

  /// Mois sélectionné pour le donut et détails
  final _mois = DateTime.now().month.obs;
  int get mois => _mois.value;

  /// Vrai pendant le chargement
  final _estEnChargement = true.obs;
  bool get estEnChargement => _estEnChargement.value;

  /// Devise de l'app
  final _devise = Constantes.deviseDefaut.obs;
  String get devise => _devise.value;

  // ── Données graphique barres ───────────────────────────────────

  /// Totaux des entrées par mois (1→12)
  final _entreesParMois = <int, double>{}.obs;
  Map<int, double> get entreesParMois => _entreesParMois;

  /// Totaux des sorties par mois (1→12)
  final _sortiesParMois = <int, double>{}.obs;
  Map<int, double> get sortiesParMois => _sortiesParMois;

  // ── Données graphique donut ────────────────────────────────────

  /// Totaux par catégorie pour le mois sélectionné
  final _totauxParCategorie = <String, double>{}.obs;
  Map<String, double> get totauxParCategorie => _totauxParCategorie;

  // ── Données graphique courbe ───────────────────────────────────

  /// Évolution du solde jour par jour sur le mois sélectionné
  final _evolutionSolde = <DateTime, double>{}.obs;
  Map<DateTime, double> get evolutionSolde => _evolutionSolde;

  // ── Comparatifs ────────────────────────────────────────────────

  /// Total entrées mois sélectionné
  final _totalEntreesMois = 0.0.obs;
  double get totalEntreesMois => _totalEntreesMois.value;

  /// Total sorties mois sélectionné
  final _totalSortiesMois = 0.0.obs;
  double get totalSortiesMois => _totalSortiesMois.value;

  /// Total entrées mois précédent (pour comparatif)
  final _totalEntreesMoisPrecedent = 0.0.obs;
  double get totalEntreesMoisPrecedent => _totalEntreesMoisPrecedent.value;

  /// Total sorties mois précédent (pour comparatif)
  final _totalSortiesMoisPrecedent = 0.0.obs;
  double get totalSortiesMoisPrecedent => _totalSortiesMoisPrecedent.value;

  // ── Cycle de vie ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _chargerTout();
  }

  // ── Chargement ─────────────────────────────────────────────────

  /// Charge et calcule toutes les statistiques.
  Future<void> _chargerTout() async {
    _estEnChargement.value = true;
    try {
      await Future.wait([
        _chargerDevise(),
        _calculerGraphiqueBarres(),
        _calculerGraphiqueDonut(),
        _calculerEvolutionSolde(),
        _calculerComparatifs(),
      ]);
    } catch (e) {
      debugPrint('❌ StatistiqueController: erreur → $e');
    } finally {
      _estEnChargement.value = false;
    }
  }

  /// Charge la devise depuis les préférences.
  Future<void> _chargerDevise() async {
    final box = HiveService.boxPreferences;
    _devise.value = box.get(
      Constantes.cleDevise,
      defaultValue: Constantes.deviseDefaut,
    ) as String;
  }

  // ── Calculs graphique barres ───────────────────────────────────

  /// Calcule les totaux entrées/sorties pour chaque mois
  /// de l'année sélectionnée.
  Future<void> _calculerGraphiqueBarres() async {
    _entreesParMois.value = _operationService.totauxParMoisAnnee(
      annee: _annee.value,
      type: TypeOperation.entree,
    );
    _sortiesParMois.value = _operationService.totauxParMoisAnnee(
      annee: _annee.value,
      type: TypeOperation.sortie,
    );
  }

  // ── Calculs graphique donut ────────────────────────────────────

  /// Calcule les totaux par catégorie pour le mois sélectionné.
  Future<void> _calculerGraphiqueDonut() async {
    _totauxParCategorie.value = _operationService.totauxParCategorie(
      mois: _mois.value,
      annee: _annee.value,
    );
    _totalEntreesMois.value = _operationService.calculerTotalEntrees(
      mois: _mois.value,
      annee: _annee.value,
    );
    _totalSortiesMois.value = _operationService.calculerTotalSorties(
      mois: _mois.value,
      annee: _annee.value,
    );
  }

  // ── Calculs évolution solde ────────────────────────────────────

  /// Calcule l'évolution du solde jour par jour
  /// sur le mois sélectionné.
  ///
  /// Commence depuis le solde initial de tous les comptes
  /// puis ajoute/soustrait chaque opération chronologiquement.
  Future<void> _calculerEvolutionSolde() async {
    final Map<DateTime, double> evolution = {};

    // Solde initial total de tous les comptes
    double soldeBase = _compteService.tousLesComptes().fold(
      0.0,
      (sum, c) => sum + c.soldeInitial,
    );

    // Toutes les opérations avant le mois sélectionné
    final operationsAvant = _operationService
        .toutesLesOperations()
        .where((op) {
          if (op.date.year < _annee.value) return true;
          if (op.date.year == _annee.value &&
              op.date.month < _mois.value) return true;
          return false;
        })
        .toList();

    // Calculer le solde de départ du mois
    for (final op in operationsAvant) {
      soldeBase += op.montantSigne;
    }

    // Opérations du mois sélectionné triées par date
    final operationsDuMois = _operationService
        .operationsParMois(
          mois: _mois.value,
          annee: _annee.value,
        )
        .reversed
        .toList();

    // Calculer le nombre de jours dans le mois
    final dernierJour = DateTime(
      _annee.value,
      _mois.value + 1,
      0,
    ).day;

    // Limite au jour courant si mois courant
    final now = DateTime.now();
    final estMoisCourant = _mois.value == now.month &&
        _annee.value == now.year;
    final joursACalculer = estMoisCourant ? now.day : dernierJour;

    double soldeJour = soldeBase;

    // Calculer le solde pour chaque jour du mois
    for (int jour = 1; jour <= joursACalculer; jour++) {
      final dateJour = DateTime(_annee.value, _mois.value, jour);

      // Ajouter les opérations de ce jour
      final opsJour = operationsDuMois.where((op) {
        return op.date.day == jour &&
            op.date.month == _mois.value &&
            op.date.year == _annee.value;
      });

      for (final op in opsJour) {
        soldeJour += op.montantSigne;
      }

      evolution[dateJour] = soldeJour;
    }

    _evolutionSolde.value = evolution;
  }

  // ── Calculs comparatifs ────────────────────────────────────────

  /// Calcule les totaux du mois précédent pour comparaison.
  Future<void> _calculerComparatifs() async {
    // Calculer le mois précédent
    final moisPrec = _mois.value == 1 ? 12 : _mois.value - 1;
    final anneePrec = _mois.value == 1
        ? _annee.value - 1
        : _annee.value;

    _totalEntreesMoisPrecedent.value =
        _operationService.calculerTotalEntrees(
      mois: moisPrec,
      annee: anneePrec,
    );
    _totalSortiesMoisPrecedent.value =
        _operationService.calculerTotalSorties(
      mois: moisPrec,
      annee: anneePrec,
    );
  }

  // ── Navigation période ─────────────────────────────────────────

  /// Change l'année sélectionnée.
  void changerAnnee(int annee) {
    _annee.value = annee;
    rafraichir();
  }

  /// Change le mois sélectionné.
  void changerMois(int mois) {
    _mois.value = mois;
    _calculerGraphiqueDonut();
    _calculerEvolutionSolde();
    _calculerComparatifs();
  }

  /// Passe à l'année précédente.
  void anneePrecedente() {
    _annee.value--;
    rafraichir();
  }

  /// Passe à l'année suivante — bloqué à l'année courante.
  void anneeSuivante() {
    if (_annee.value >= DateTime.now().year) return;
    _annee.value++;
    rafraichir();
  }

  // ── Getters utiles ─────────────────────────────────────────────

  /// Retourne une catégorie par son id.
  CategorieModel? categorieParId(String id) =>
      _categorieService.categorieParId(id);

  /// Variation en % des dépenses vs mois précédent.
  ///
  /// Positif = augmentation, négatif = diminution.
  double get variationDepenses {
    if (_totalSortiesMoisPrecedent.value == 0) return 0;
    return ((_totalSortiesMois.value -
                _totalSortiesMoisPrecedent.value) /
            _totalSortiesMoisPrecedent.value) *
        100;
  }

  /// Variation en % des revenus vs mois précédent.
  double get variationRevenus {
    if (_totalEntreesMoisPrecedent.value == 0) return 0;
    return ((_totalEntreesMois.value -
                _totalEntreesMoisPrecedent.value) /
            _totalEntreesMoisPrecedent.value) *
        100;
  }

  /// Vrai si l'année sélectionnée est l'année courante.
  bool get estAnneeCourante =>
      _annee.value == DateTime.now().year;

  /// Rafraîchit toutes les statistiques.
  Future<void> rafraichir() async {
    await _chargerTout();
  }
}