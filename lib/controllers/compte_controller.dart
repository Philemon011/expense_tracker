import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/compte_model.dart';
import '../services/compte_service.dart';
import '../services/hive_service.dart';
import '../utils/constantes.dart';
import 'operation_controller.dart';
/// Controller dédié à la gestion des comptes.
///
/// Expose :
///   - Liste réactive des comptes
///   - Soldes calculés en temps réel
///   - CRUD complets
///   - Gestion du compte principal
class CompteController extends GetxController {

  // ── Service ────────────────────────────────────────────────────
  final _compteService = CompteService();

  // ── État réactif ───────────────────────────────────────────────

  /// Liste de tous les comptes actifs
  final _comptes = <CompteModel>[].obs;
  List<CompteModel> get comptes => _comptes;

  /// Soldes calculés par compte — Map compteId → solde
  final _soldes = <String, double>{}.obs;
  Map<String, double> get soldes => _soldes;

  /// Solde total de tous les comptes
  final _soldeTotal = 0.0.obs;
  double get soldeTotal => _soldeTotal.value;

  /// Vrai pendant le chargement
  final _estEnChargement = true.obs;
  bool get estEnChargement => _estEnChargement.value;

  /// Devise de l'app
  final _devise = Constantes.deviseDefaut.obs;
  String get devise => _devise.value;

  // ── Cycle de vie ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _chargerTout();
  }

  // ── Chargement ─────────────────────────────────────────────────

  /// Charge tous les comptes et recalcule les soldes.
  Future<void> _chargerTout() async {
    _estEnChargement.value = true;
    try {
      await Future.wait([
        _chargerComptes(),
        _chargerDevise(),
      ]);
    } catch (e) {
      debugPrint('❌ CompteController: erreur → $e');
    } finally {
      _estEnChargement.value = false;
    }
  }

  /// Charge les comptes depuis Hive et recalcule les soldes.
  Future<void> _chargerComptes() async {
    _comptes.value = _compteService.tousLesComptes();
    _recalculerSoldes();
  }

  /// Recalcule les soldes de tous les comptes.
  void _recalculerSoldes() {
    final Map<String, double> soldes = {};
    double total = 0;

    for (final compte in _comptes) {
      final solde = _compteService.calculerSolde(compte.id);
      soldes[compte.id] = solde;
      total += solde;
    }

    _soldes.value = soldes;
    _soldeTotal.value = total;
  }

  /// Charge la devise depuis les préférences.
  Future<void> _chargerDevise() async {
    final box = HiveService.boxPreferences;
    _devise.value = box.get(
      Constantes.cleDevise,
      defaultValue: Constantes.deviseDefaut,
    ) as String;
  }

  // ── CRUD ───────────────────────────────────────────────────────

  /// Ajoute un nouveau compte.
Future<bool> ajouterCompte({
  required String nom,
  required TypeCompte type,
  required double soldeInitial,
  required int couleurValue,
  required int iconeCode,
}) async {
  try {
    // Vérifier nom unique
    if (_compteService.nomExisteDeja(nom)) {
      Get.snackbar(
        'Erreur',
        'Un compte avec ce nom existe déjà',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    await _compteService.ajouterCompte(
      nom: nom,
      type: type,
      soldeInitial: soldeInitial,
      couleurValue: couleurValue,
      iconeCode: iconeCode,
      devise: _devise.value,
    );

    await _chargerComptes();

    // Notifier OperationController — synchroniser les comptes
    if (Get.isRegistered<OperationController>()) {
      await Get.find<OperationController>().rafraichir();
    }

    return true;
  } catch (e) {
    debugPrint('❌ CompteController: erreur ajout → $e');
    return false;
  }
}

  /// Modifie un compte existant.
Future<bool> modifierCompte(CompteModel compte) async {
  try {
    final succes = await _compteService.modifierCompte(compte);
    if (succes) {
      await _chargerComptes();
      // Notifier OperationController — synchroniser les comptes
      if (Get.isRegistered<OperationController>()) {
        await Get.find<OperationController>().rafraichir();
      }
    }
    return succes;
  } catch (e) {
    debugPrint('❌ CompteController: erreur modification → $e');
    return false;
  }
}

  /// Définit un compte comme principal.
  Future<void> definirComptePrincipal(String compteId) async {
    await _compteService.definirComptePrincipal(compteId);
    await _chargerComptes();
  }

  /// Archive un compte.
Future<bool> archiverCompte(String compteId) async {
  final succes = await _compteService.archiverCompte(compteId);
  if (succes) {
    await _chargerComptes();
    // Notifier OperationController — synchroniser les comptes
    if (Get.isRegistered<OperationController>()) {
      await Get.find<OperationController>().rafraichir();
    }
  }
  return succes;
}

  /// Supprime un compte.
  Future<({bool succes, String? erreur})> supprimerCompte(
    String compteId,
  ) async {
    final resultat = await _compteService.supprimerCompte(compteId);
    if (resultat.succes) await _chargerComptes();
    return resultat;
  }

  // ── Utilitaires ────────────────────────────────────────────────

  /// Retourne le solde d'un compte spécifique.
  double soldeCompte(String compteId) =>
      _soldes[compteId] ?? 0.0;

  /// Retourne un compte par son id.
  CompteModel? compteParId(String id) =>
      _compteService.compteParId(id);

  /// Retourne le nombre d'opérations d'un compte.
  int nombreOperations(String compteId) =>
      _compteService.nombreOperations(compteId);

  /// Rafraîchit toutes les données.
  Future<void> rafraichir() async {
    await _chargerTout();
  }
}