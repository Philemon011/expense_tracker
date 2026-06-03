import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'categorie_model.g.dart';

/// Modèle d'une catégorie d'opération.
///
/// Une catégorie regroupe des opérations de même nature.
/// Exemples : Alimentation, Transport, Salaire, Loyer...
///
/// Chaque catégorie a :
///   - Un nom affiché à l'utilisateur
///   - Une icône (code du MaterialIcon)
///   - Une couleur (valeur int de la couleur Flutter)
///   - Un type (entree, sortie, ou les deux)
///   - Un flag pour savoir si c'est une catégorie par défaut
@HiveType(typeId: 2)
class CategorieModel extends HiveObject {

  /// Identifiant unique
  @HiveField(0)
  final String id;

  /// Nom de la catégorie — affiché dans l'UI
  @HiveField(1)
  final String nom;

  /// Code de l'icône MaterialIcons (ex: 0xe25a pour restaurant)
  /// Stocké en int car Hive ne stocke pas IconData directement
  @HiveField(2)
  final int iconeCode;

  /// Couleur de la catégorie stockée en int (ex: 0xFF4CAF7A)
  /// Stockée en int car Hive ne stocke pas Color directement
  @HiveField(3)
  final int couleurValue;

  /// Type d'opération associé à cette catégorie
  /// 'entree', 'sortie', ou 'les_deux'
  @HiveField(4)
  final String typeOperation;

  /// Vrai si c'est une catégorie installée par défaut
  /// False si créée par l'utilisateur
  @HiveField(5)
  final bool estParDefaut;

  /// Ordre d'affichage dans la liste
  @HiveField(6)
  final int ordre;

  CategorieModel({
    required this.id,
    required this.nom,
    required this.iconeCode,
    required this.couleurValue,
    required this.typeOperation,
    this.estParDefaut = false,
    this.ordre = 0,
  });

  // ── Getters utiles ─────────────────────────────────────────────

  /// Retourne l'icône Flutter depuis le code stocké
  IconData get icone => IconData(iconeCode, fontFamily: 'MaterialIcons');

  /// Retourne la couleur Flutter depuis la valeur stockée
  Color get couleur => Color(couleurValue);

  /// Vrai si cette catégorie accepte les entrées
  bool get accepteEntree =>
      typeOperation == 'entree' || typeOperation == 'les_deux';

  /// Vrai si cette catégorie accepte les sorties
  bool get accepteSortie =>
      typeOperation == 'sortie' || typeOperation == 'les_deux';

  // ── Copie avec modifications ───────────────────────────────────

  CategorieModel copyWith({
    String? id,
    String? nom,
    int? iconeCode,
    int? couleurValue,
    String? typeOperation,
    bool? estParDefaut,
    int? ordre,
  }) {
    return CategorieModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      iconeCode: iconeCode ?? this.iconeCode,
      couleurValue: couleurValue ?? this.couleurValue,
      typeOperation: typeOperation ?? this.typeOperation,
      estParDefaut: estParDefaut ?? this.estParDefaut,
      ordre: ordre ?? this.ordre,
    );
  }

  @override
  String toString() => 'CategorieModel(id: $id, nom: $nom)';
}

/// Catégories par défaut pré-installées au premier lancement.
///
/// Appelées dans HiveService lors de l'initialisation.
/// L'utilisateur ne peut pas supprimer ces catégories.
class CategoriesParDefaut {

  /// Liste complète des catégories par défaut
  static List<CategorieModel> get toutes => [
    ..._categoriesSortie,
    ..._categoriesEntree,
  ];

  /// Catégories de type sortie (dépenses)
  static final List<CategorieModel> _categoriesSortie = [
    CategorieModel(
      id: 'cat_alimentation',
      nom: 'Alimentation',
      iconeCode: Icons.restaurant_rounded.codePoint,
      couleurValue: 0xFFEF4444,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 1,
    ),
    CategorieModel(
      id: 'cat_transport',
      nom: 'Transport',
      iconeCode: Icons.directions_car_rounded.codePoint,
      couleurValue: 0xFF3B82F6,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 2,
    ),
    CategorieModel(
      id: 'cat_logement',
      nom: 'Logement',
      iconeCode: Icons.home_rounded.codePoint,
      couleurValue: 0xFF8B5CF6,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 3,
    ),
    CategorieModel(
      id: 'cat_sante',
      nom: 'Santé',
      iconeCode: Icons.favorite_rounded.codePoint,
      couleurValue: 0xFFF43F5E,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 4,
    ),
    CategorieModel(
      id: 'cat_loisirs',
      nom: 'Loisirs',
      iconeCode: Icons.sports_esports_rounded.codePoint,
      couleurValue: 0xFFF59E0B,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 5,
    ),
    CategorieModel(
      id: 'cat_shopping',
      nom: 'Shopping',
      iconeCode: Icons.shopping_bag_rounded.codePoint,
      couleurValue: 0xFFEC4899,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 6,
    ),
    CategorieModel(
      id: 'cat_education',
      nom: 'Éducation',
      iconeCode: Icons.school_rounded.codePoint,
      couleurValue: 0xFF06B6D4,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 7,
    ),
    CategorieModel(
      id: 'cat_factures',
      nom: 'Factures',
      iconeCode: Icons.receipt_long_rounded.codePoint,
      couleurValue: 0xFF6B7280,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 8,
    ),
    CategorieModel(
      id: 'cat_autres_sortie',
      nom: 'Autres dépenses',
      iconeCode: Icons.more_horiz_rounded.codePoint,
      couleurValue: 0xFF9CA3AF,
      typeOperation: 'sortie',
      estParDefaut: true,
      ordre: 9,
    ),
  ];

  /// Catégories de type entrée (revenus)
  static final List<CategorieModel> _categoriesEntree = [
    CategorieModel(
      id: 'cat_salaire',
      nom: 'Salaire',
      iconeCode: Icons.account_balance_wallet_rounded.codePoint,
      couleurValue: 0xFF4CAF7A,
      typeOperation: 'entree',
      estParDefaut: true,
      ordre: 10,
    ),
    CategorieModel(
      id: 'cat_freelance',
      nom: 'Freelance',
      iconeCode: Icons.laptop_rounded.codePoint,
      couleurValue: 0xFF3B82F6,
      typeOperation: 'entree',
      estParDefaut: true,
      ordre: 11,
    ),
    CategorieModel(
      id: 'cat_remboursement',
      nom: 'Remboursement',
      iconeCode: Icons.undo_rounded.codePoint,
      couleurValue: 0xFF06B6D4,
      typeOperation: 'entree',
      estParDefaut: true,
      ordre: 12,
    ),
    CategorieModel(
      id: 'cat_cadeau',
      nom: 'Cadeau reçu',
      iconeCode: Icons.card_giftcard_rounded.codePoint,
      couleurValue: 0xFFEC4899,
      typeOperation: 'entree',
      estParDefaut: true,
      ordre: 13,
    ),
    CategorieModel(
      id: 'cat_autres_entree',
      nom: 'Autres revenus',
      iconeCode: Icons.add_circle_rounded.codePoint,
      couleurValue: 0xFF9CA3AF,
      typeOperation: 'entree',
      estParDefaut: true,
      ordre: 14,
    ),
  ];
}