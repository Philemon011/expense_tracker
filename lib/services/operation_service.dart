import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/operation_model.dart';
import '../utils/constantes.dart';

/// Service de gestion des opérations dans Hive.
///
/// Toutes les opérations CRUD passent par ce service.
/// Les controllers appellent ce service — jamais Hive directement.
///
/// Méthodes disponibles :
///   - ajouterOperation()
///   - modifierOperation()
///   - supprimerOperation()
///   - toutesLesOperations()
///   - operationsParMois()
///   - operationsParCompte()
///   - operationsParCategorie()
///   - calculerSolde()
///   - calculerTotalEntrees()
///   - calculerTotalSorties()
class OperationService {

  // ── Accès à la boîte Hive ──────────────────────────────────────

  /// Boîte Hive des opérations
  Box<OperationModel> get _box =>
      Hive.box<OperationModel>(Constantes.boxOperations);

  /// Générateur d'identifiants uniques
  final _uuid = const Uuid();

  // ── CRUD ───────────────────────────────────────────────────────

  /// Ajoute une nouvelle opération dans Hive.
  ///
  /// L'id est généré automatiquement par uuid.
  /// Retourne l'opération créée avec son id.
  Future<OperationModel> ajouterOperation({
    required double montant,
    required TypeOperation type,
    required String categorieId,
    required String compteId,
    required DateTime date,
    String? note,
  }) async {
    // Créer l'opération avec un id unique
    final operation = OperationModel(
      id: _uuid.v4(),
      montant: montant,
      type: type,
      categorieId: categorieId,
      compteId: compteId,
      date: date,
      note: note,
    );

    // Stocker dans Hive avec l'id comme clé
    await _box.put(operation.id, operation);

    debugPrint('✅ OperationService : opération ajoutée → ${operation.id}');
    return operation;
  }

  /// Modifie une opération existante.
  ///
  /// On remplace l'objet complet dans Hive.
  /// Retourne false si l'opération n'existe pas.
  Future<bool> modifierOperation(OperationModel operation) async {
    // Vérifier que l'opération existe
    if (!_box.containsKey(operation.id)) {
      debugPrint('⚠️ OperationService : opération introuvable → ${operation.id}');
      return false;
    }

    await _box.put(operation.id, operation);
    debugPrint('✅ OperationService : opération modifiée → ${operation.id}');
    return true;
  }

  /// Supprime une opération par son id.
  ///
  /// Retourne false si l'opération n'existe pas.
  Future<bool> supprimerOperation(String id) async {
    if (!_box.containsKey(id)) {
      debugPrint('⚠️ OperationService : opération introuvable → $id');
      return false;
    }

    await _box.delete(id);
    debugPrint('✅ OperationService : opération supprimée → $id');
    return true;
  }

  // ── Lecture ────────────────────────────────────────────────────

  /// Retourne toutes les opérations triées par date décroissante.
  /// La plus récente apparaît en premier.
  List<OperationModel> toutesLesOperations() {
    final operations = _box.values.toList();

    // Tri par date décroissante — plus récente en premier
    operations.sort((a, b) => b.date.compareTo(a.date));
    return operations;
  }

  /// Retourne les opérations d'un mois et d'une année donnés.
  ///
  /// Utilisé pour le dashboard et les statistiques mensuelles.
  List<OperationModel> operationsParMois({
    required int mois,
    required int annee,
  }) {
    return _box.values.where((op) {
      return op.date.month == mois && op.date.year == annee;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Retourne les opérations d'un compte spécifique.
  List<OperationModel> operationsParCompte(String compteId) {
    return _box.values
        .where((op) => op.compteId == compteId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Retourne les opérations d'une catégorie spécifique.
  List<OperationModel> operationsParCategorie(String categorieId) {
    return _box.values
        .where((op) => op.categorieId == categorieId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Retourne les N dernières opérations.
  ///
  /// Utilisé sur le dashboard pour les opérations récentes.
  List<OperationModel> dernieresOperations({int limite = 5}) {
    final toutes = toutesLesOperations();
    if (toutes.length <= limite) return toutes;
    return toutes.sublist(0, limite);
  }

  /// Recherche des opérations par note (texte libre).
  ///
  /// Insensible à la casse — cherche dans la note uniquement.
  List<OperationModel> rechercherParNote(String query) {
    if (query.isEmpty) return toutesLesOperations();

    final queryLower = query.toLowerCase();
    return _box.values
        .where((op) =>
            op.note != null &&
            op.note!.toLowerCase().contains(queryLower))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Filtre les opérations selon plusieurs critères combinés.
  ///
  /// Tous les paramètres sont optionnels.
  /// Si null, le filtre n'est pas appliqué.
  List<OperationModel> filtrer({
    int? mois,
    int? annee,
    TypeOperation? type,
    String? categorieId,
    String? compteId,
    String? recherche,
  }) {
    return _box.values.where((op) {
      // Filtre par mois
      if (mois != null && op.date.month != mois) return false;

      // Filtre par année
      if (annee != null && op.date.year != annee) return false;

      // Filtre par type (entrée ou sortie)
      if (type != null && op.type != type) return false;

      // Filtre par catégorie
      if (categorieId != null && op.categorieId != categorieId) return false;

      // Filtre par compte
      if (compteId != null && op.compteId != compteId) return false;

      // Filtre par recherche dans la note
      if (recherche != null && recherche.isNotEmpty) {
        if (op.note == null) return false;
        if (!op.note!.toLowerCase().contains(recherche.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ── Calculs financiers ─────────────────────────────────────────

  /// Calcule le solde total de tous les comptes.
  ///
  /// Solde = solde initial de tous les comptes
  ///       + total entrées - total sorties
  /// Note : les soldes initiaux sont gérés par CompteService.
  double calculerTotalEntrees({int? mois, int? annee}) {
    final ops = (mois != null && annee != null)
        ? operationsParMois(mois: mois, annee: annee)
        : toutesLesOperations();

    return ops
        .where((op) => op.estEntree)
        .fold(0.0, (sum, op) => sum + op.montant);
  }

  /// Calcule le total des sorties.
  double calculerTotalSorties({int? mois, int? annee}) {
    final ops = (mois != null && annee != null)
        ? operationsParMois(mois: mois, annee: annee)
        : toutesLesOperations();

    return ops
        .where((op) => op.estSortie)
        .fold(0.0, (sum, op) => sum + op.montant);
  }

  /// Calcule le total dépensé pour une catégorie sur un mois donné.
  ///
  /// Utilisé par BudgetService pour la progression des budgets.
  double calculerDepensesCategorie({
    required String categorieId,
    required int mois,
    required int annee,
  }) {
    return _box.values
        .where((op) =>
            op.estSortie &&
            op.categorieId == categorieId &&
            op.date.month == mois &&
            op.date.year == annee)
        .fold(0.0, (sum, op) => sum + op.montant);
  }

  /// Calcule le solde d'un compte spécifique.
  ///
  /// Solde compte = soldeInitial + entrées - sorties du compte
  double calculerSoldeCompte({
    required String compteId,
    required double soldeInitial,
  }) {
    final ops = operationsParCompte(compteId);
    final entrees = ops
        .where((op) => op.estEntree)
        .fold(0.0, (sum, op) => sum + op.montant);
    final sorties = ops
        .where((op) => op.estSortie)
        .fold(0.0, (sum, op) => sum + op.montant);

    return soldeInitial + entrees - sorties;
  }

  /// Retourne les totaux par catégorie pour un mois donné.
  ///
  /// Utilisé pour le graphique donut des statistiques.
  /// Retourne un Map : categorieId → montant total
  Map<String, double> totauxParCategorie({
    required int mois,
    required int annee,
    TypeOperation type = TypeOperation.sortie,
  }) {
    final ops = operationsParMois(mois: mois, annee: annee)
        .where((op) => op.type == type);

    final Map<String, double> totaux = {};
    for (final op in ops) {
      totaux[op.categorieId] = (totaux[op.categorieId] ?? 0) + op.montant;
    }
    return totaux;
  }

  /// Retourne les totaux par mois pour une année donnée.
  ///
  /// Utilisé pour le graphique en barres des statistiques.
  /// Retourne une liste de 12 valeurs (une par mois).
  Map<int, double> totauxParMoisAnnee({
    required int annee,
    required TypeOperation type,
  }) {
    final Map<int, double> totaux = {
      for (int i = 1; i <= 12; i++) i: 0.0,
    };

    for (final op in _box.values) {
      if (op.date.year == annee && op.type == type) {
        totaux[op.date.month] = (totaux[op.date.month] ?? 0) + op.montant;
      }
    }
    return totaux;
  }
}