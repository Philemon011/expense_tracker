import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/compte_model.dart';
import '../models/operation_model.dart';
import '../utils/constantes.dart';

/// Service de gestion des comptes dans Hive.
///
/// Responsabilités :
///   - CRUD complet des comptes
///   - Calcul du solde réel (soldeInitial + opérations)
///   - Gestion du compte principal
///   - Protection contre la suppression de comptes actifs
class CompteService {

  // ── Accès aux boîtes Hive ──────────────────────────────────────

  Box<CompteModel> get _box =>
      Hive.box<CompteModel>(Constantes.boxComptes);

  Box<OperationModel> get _boxOperations =>
      Hive.box<OperationModel>(Constantes.boxOperations);

  final _uuid = const Uuid();

  // ── Lecture ────────────────────────────────────────────────────

  /// Retourne tous les comptes actifs (non archivés).
  List<CompteModel> tousLesComptes() {
    return _box.values
        .where((c) => !c.estArchive)
        .toList()
      ..sort((a, b) {
        // Le compte principal toujours en premier
        if (a.estPrincipal) return -1;
        if (b.estPrincipal) return 1;
        return a.nom.compareTo(b.nom);
      });
  }

  /// Retourne tous les comptes y compris les archivés.
  List<CompteModel> tousLesComptesAvecArchives() {
    return _box.values.toList()
      ..sort((a, b) => a.nom.compareTo(b.nom));
  }

  /// Retourne un compte par son id.
  CompteModel? compteParId(String id) => _box.get(id);

  /// Retourne le compte principal.
  /// Si aucun n'est marqué principal, retourne le premier.
  CompteModel? get comptePrincipal {
    try {
      return _box.values.firstWhere((c) => c.estPrincipal);
    } catch (_) {
      return _box.values.isNotEmpty ? _box.values.first : null;
    }
  }

  // ── Calculs de solde ───────────────────────────────────────────

  /// Calcule le solde réel d'un compte.
  ///
  /// Solde réel = soldeInitial + total entrées - total sorties
  /// Prend en compte TOUTES les opérations du compte.
  double calculerSolde(String compteId) {
    final compte = _box.get(compteId);
    if (compte == null) return 0.0;

    // Filtrer les opérations de ce compte
    final operations = _boxOperations.values
        .where((op) => op.compteId == compteId);

    double solde = compte.soldeInitial;

    for (final op in operations) {
      if (op.estEntree) {
        solde += op.montant;
      } else {
        solde -= op.montant;
      }
    }

    return solde;
  }

  /// Calcule le solde total de tous les comptes actifs combinés.
  ///
  /// Utilisé sur le dashboard pour afficher le solde global.
  double calculerSoldeTotal() {
    return tousLesComptes().fold(0.0, (total, compte) {
      return total + calculerSolde(compte.id);
    });
  }

  /// Retourne une map compteId → solde pour tous les comptes.
  ///
  /// Utile pour afficher la liste des comptes avec leur solde.
  Map<String, double> tousLesSoldes() {
    final Map<String, double> soldes = {};
    for (final compte in tousLesComptes()) {
      soldes[compte.id] = calculerSolde(compte.id);
    }
    return soldes;
  }

  // ── CRUD ───────────────────────────────────────────────────────

  /// Ajoute un nouveau compte.
  ///
  /// Si c'est le premier compte, il devient automatiquement principal.
  Future<CompteModel> ajouterCompte({
    required String nom,
    required TypeCompte type,
    required double soldeInitial,
    required int couleurValue,
    required int iconeCode,
    required String devise,
  }) async {
    // Premier compte = automatiquement principal
    final estPremier = _box.isEmpty;

    final compte = CompteModel(
      id: _uuid.v4(),
      nom: nom,
      type: type,
      soldeInitial: soldeInitial,
      couleurValue: couleurValue,
      iconeCode: iconeCode,
      devise: devise,
      estPrincipal: estPremier,
    );

    await _box.put(compte.id, compte);
    debugPrint('✅ CompteService : compte ajouté → ${compte.nom}');
    return compte;
  }

  /// Modifie un compte existant.
  Future<bool> modifierCompte(CompteModel compte) async {
    if (!_box.containsKey(compte.id)) {
      debugPrint('⚠️ CompteService : compte introuvable → ${compte.id}');
      return false;
    }

    await _box.put(compte.id, compte);
    debugPrint('✅ CompteService : compte modifié → ${compte.nom}');
    return true;
  }

  /// Définit un compte comme compte principal.
  ///
  /// L'ancien compte principal perd ce statut automatiquement.
  /// Un seul compte principal à la fois.
  Future<void> definirComptePrincipal(String compteId) async {
    // Retirer le statut principal de tous les comptes
    for (final compte in _box.values) {
      if (compte.estPrincipal && compte.id != compteId) {
        await _box.put(
          compte.id,
          compte.copyWith(estPrincipal: false),
        );
      }
    }

    // Définir le nouveau compte principal
    final compte = _box.get(compteId);
    if (compte != null) {
      await _box.put(
        compteId,
        compte.copyWith(estPrincipal: true),
      );
    }

    debugPrint('✅ CompteService : nouveau compte principal → $compteId');
  }

  /// Archive un compte (le cache sans le supprimer).
  ///
  /// On archive au lieu de supprimer pour garder
  /// l'historique des opérations intact.
  Future<bool> archiverCompte(String compteId) async {
    final compte = _box.get(compteId);
    if (compte == null) return false;

    // Impossible d'archiver le compte principal
    if (compte.estPrincipal) {
      debugPrint('⚠️ CompteService : impossible d\'archiver le compte principal');
      return false;
    }

    await _box.put(
      compteId,
      compte.copyWith(estArchive: true),
    );

    debugPrint('✅ CompteService : compte archivé → ${compte.nom}');
    return true;
  }

  /// Supprime définitivement un compte.
  ///
  /// Règles de sécurité :
  ///   - Impossible de supprimer le compte principal
  ///   - Impossible de supprimer un compte avec des opérations
  Future<({bool succes, String? erreur})> supprimerCompte(
    String compteId,
  ) async {
    final compte = _box.get(compteId);

    // Compte introuvable
    if (compte == null) {
      return (succes: false, erreur: 'Compte introuvable');
    }

    // Protection du compte principal
    if (compte.estPrincipal) {
      return (
        succes: false,
        erreur: 'Impossible de supprimer le compte principal',
      );
    }

    // Vérifier qu'aucune opération n'utilise ce compte
    final aDesOperations = _boxOperations.values
        .any((op) => op.compteId == compteId);

    if (aDesOperations) {
      return (
        succes: false,
        erreur: 'Ce compte contient des opérations. '
            'Archivez-le plutôt que de le supprimer.',
      );
    }

    await _box.delete(compteId);
    debugPrint('✅ CompteService : compte supprimé → $compteId');
    return (succes: true, erreur: null);
  }

  // ── Utilitaires ────────────────────────────────────────────────

  /// Vérifie si un nom de compte existe déjà.
  bool nomExisteDeja(String nom, {String? exclureId}) {
    return _box.values.any((c) {
      if (exclureId != null && c.id == exclureId) return false;
      return c.nom.toLowerCase() == nom.toLowerCase();
    });
  }

  /// Retourne le nombre d'opérations d'un compte.
  ///
  /// Utile pour savoir si on peut supprimer un compte.
  int nombreOperations(String compteId) {
    return _boxOperations.values
        .where((op) => op.compteId == compteId)
        .length;
  }

  /// Retourne le nombre total de comptes actifs.
  int get nombreComptes =>
      _box.values.where((c) => !c.estArchive).length;
}