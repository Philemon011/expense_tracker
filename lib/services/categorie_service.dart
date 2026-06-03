import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/categorie_model.dart';
import '../utils/constantes.dart';

/// Service de gestion des catégories dans Hive.
///
/// Règles importantes :
///   - Les catégories par défaut (estParDefaut: true)
///     ne peuvent PAS être supprimées
///   - L'utilisateur peut créer, modifier et supprimer
///     ses propres catégories uniquement
class CategorieService {

  // ── Accès à la boîte Hive ──────────────────────────────────────

  Box<CategorieModel> get _box =>
      Hive.box<CategorieModel>(Constantes.boxCategories);

  final _uuid = const Uuid();

  // ── Lecture ────────────────────────────────────────────────────

  /// Retourne toutes les catégories triées par ordre.
  List<CategorieModel> toutesLesCategories() {
    final categories = _box.values.toList();
    categories.sort((a, b) => a.ordre.compareTo(b.ordre));
    return categories;
  }

  /// Retourne les catégories compatibles avec les entrées.
  List<CategorieModel> categoriesPourEntrees() {
    return toutesLesCategories()
        .where((cat) => cat.accepteEntree)
        .toList();
  }

  /// Retourne les catégories compatibles avec les sorties.
  List<CategorieModel> categoriesPourSorties() {
    return toutesLesCategories()
        .where((cat) => cat.accepteSortie)
        .toList();
  }

  /// Retourne une catégorie par son id.
  /// Retourne null si elle n'existe pas.
  CategorieModel? categorieParId(String id) {
    return _box.get(id);
  }

  /// Retourne les catégories créées par l'utilisateur uniquement.
  List<CategorieModel> categoriesUtilisateur() {
    return toutesLesCategories()
        .where((cat) => !cat.estParDefaut)
        .toList();
  }

  // ── CRUD ───────────────────────────────────────────────────────

  /// Ajoute une nouvelle catégorie personnalisée.
  ///
  /// L'ordre est automatiquement défini à la fin de la liste.
  Future<CategorieModel> ajouterCategorie({
    required String nom,
    required int iconeCode,
    required int couleurValue,
    required String typeOperation,
  }) async {
    // Calculer l'ordre — à la fin de la liste existante
    final ordreMax = _box.values.isEmpty
        ? 0
        : _box.values.map((c) => c.ordre).reduce(
            (a, b) => a > b ? a : b,
          );

    final categorie = CategorieModel(
      id: _uuid.v4(),
      nom: nom,
      iconeCode: iconeCode,
      couleurValue: couleurValue,
      typeOperation: typeOperation,
      estParDefaut: false,  // Jamais par défaut si créée par l'utilisateur
      ordre: ordreMax + 1,
    );

    await _box.put(categorie.id, categorie);
    debugPrint('✅ CategorieService : catégorie ajoutée → ${categorie.nom}');
    return categorie;
  }

  /// Modifie une catégorie existante.
  ///
  /// Les catégories par défaut peuvent être modifiées
  /// (nom, icône, couleur) mais pas leur typeOperation.
  Future<bool> modifierCategorie(CategorieModel categorie) async {
    if (!_box.containsKey(categorie.id)) {
      debugPrint('⚠️ CategorieService : catégorie introuvable → ${categorie.id}');
      return false;
    }

    await _box.put(categorie.id, categorie);
    debugPrint('✅ CategorieService : catégorie modifiée → ${categorie.nom}');
    return true;
  }

  /// Supprime une catégorie personnalisée.
  ///
  /// Règle de sécurité : les catégories par défaut
  /// ne peuvent jamais être supprimées.
  /// Retourne un message d'erreur si la suppression est refusée.
  Future<({bool succes, String? erreur})> supprimerCategorie(
    String id,
  ) async {
    final categorie = _box.get(id);

    // Catégorie introuvable
    if (categorie == null) {
      return (succes: false, erreur: 'Catégorie introuvable');
    }

    // Protection des catégories par défaut
    if (categorie.estParDefaut) {
      return (
        succes: false,
        erreur: 'Les catégories par défaut ne peuvent pas être supprimées',
      );
    }

    await _box.delete(id);
    debugPrint('✅ CategorieService : catégorie supprimée → $id');
    return (succes: true, erreur: null);
  }

  // ── Utilitaires ────────────────────────────────────────────────

  /// Vérifie si un nom de catégorie existe déjà.
  ///
  /// Insensible à la casse.
  /// Utile pour éviter les doublons lors de la création.
  bool nomExisteDeja(String nom, {String? exclureId}) {
    return _box.values.any((cat) {
      if (exclureId != null && cat.id == exclureId) return false;
      return cat.nom.toLowerCase() == nom.toLowerCase();
    });
  }

  /// Retourne le nombre total de catégories.
  int get nombreTotal => _box.length;

  /// Retourne le nombre de catégories utilisateur.
  int get nombreUtilisateur =>
      _box.values.where((cat) => !cat.estParDefaut).length;
}