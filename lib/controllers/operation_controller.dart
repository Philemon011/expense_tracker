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

  // ── Getters calculés ───────────────────────────────────────────

  /// Solde total de tous les comptes
  double get soldeTotal => _compteService.calculerSoldeTotal();

  /// Total des entrées du mois sélectionné
  double get totalEntreesMois => _operationService.calculerTotalEntrees(
        mois: _moisSelectionne.value,
        annee: _anneeSelectionnee.value,
      );

  /// Total des sorties du mois sélectionné
  double get totalSortiesMois => _operationService.calculerTotalSorties(
        mois: _moisSelectionne.value,
        annee: _anneeSelectionnee.value,
      );

  /// 5 dernières opérations pour le dashboard
  List<OperationModel> get operationsRecentes =>
      _operationService.dernieresOperations(limite: 5);

  /// Opérations du mois sélectionné
  List<OperationModel> get operationsDuMois =>
      _operationService.operationsParMois(
        mois: _moisSelectionne.value,
        annee: _anneeSelectionnee.value,
      );

  /// Totaux par catégorie pour le mois sélectionné
  /// Utilisé pour le graphique donut
  Map<String, double> get totauxParCategorie =>
      _operationService.totauxParCategorie(
        mois: _moisSelectionne.value,
        annee: _anneeSelectionnee.value,
      );

  /// Totaux par mois pour l'année sélectionnée
  /// Utilisé pour le graphique en barres
  Map<int, double> get totauxEntreesParMois =>
      _operationService.totauxParMoisAnnee(
        annee: _anneeSelectionnee.value,
        type: TypeOperation.entree,
      );

  Map<int, double> get totauxSortiesParMois =>
      _operationService.totauxParMoisAnnee(
        annee: _anneeSelectionnee.value,
        type: TypeOperation.sortie,
      );

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
      // Charger en parallèle pour être plus rapide
      await Future.wait([
        _chargerOperations(),
        _chargerCategories(),
        _chargerComptes(),
        _chargerPreferences(),
      ]);
    } catch (e) {
      debugPrint('❌ OperationController: erreur chargement → $e');
    } finally {
      _estEnChargement.value = false;
    }
  }

  /// Charge les opérations depuis Hive
  Future<void> _chargerOperations() async {
    _operations.value = _operationService.toutesLesOperations();
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

      // Rafraîchir les données après ajout
      await _chargerOperations();
      // Notifier GetX pour mettre à jour tous les widgets
      update();
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
    update();
  }

  /// Passe au mois précédent.
  void moisPrecedent() {
    if (_moisSelectionne.value == 1) {
      _moisSelectionne.value = 12;
      _anneeSelectionnee.value--;
    } else {
      _moisSelectionne.value--;
    }
    update();
  }

  /// Passe au mois suivant.
  /// Ne permet pas d'aller au-delà du mois courant.
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
    update();
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
  CompteModel? compteParId(String id) =>
      _compteService.compteParId(id);

  /// Retourne le solde d'un compte spécifique.
  double soldeCompte(String compteId) =>
      _compteService.calculerSolde(compteId);

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