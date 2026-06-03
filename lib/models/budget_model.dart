import 'package:hive/hive.dart';

part 'budget_model.g.dart';

/// Modèle d'un budget mensuel par catégorie.
///
/// Un budget définit un plafond de dépenses pour une catégorie
/// sur un mois donné. L'app calcule le montant dépensé en temps
/// réel et alerte l'utilisateur en cas de dépassement.
///
/// Exemple :
///   Budget "Alimentation" → 150 000 FCFA / mois
///   Dépensé ce mois → 120 000 FCFA (80%)
///   Statut → ⚠️ Attention (> 75%)
@HiveType(typeId: 4)
class BudgetModel extends HiveObject {

  /// Identifiant unique
  @HiveField(0)
  final String id;

  /// Référence vers la catégorie concernée
  @HiveField(1)
  final String categorieId;

  /// Montant maximum autorisé pour ce budget
  @HiveField(2)
  final double montantMax;

  /// Mois concerné (1 = Janvier, 12 = Décembre)
  @HiveField(3)
  final int mois;

  /// Année concernée
  @HiveField(4)
  final int annee;

  /// Vrai si le budget se renouvelle automatiquement chaque mois
  @HiveField(5)
  final bool estRecurrent;

  /// Date de création du budget
  @HiveField(6)
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.categorieId,
    required this.montantMax,
    required this.mois,
    required this.annee,
    this.estRecurrent = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Getters utiles ─────────────────────────────────────────────

  /// Calcule le pourcentage consommé du budget.
  /// [montantDepense] est calculé par le controller en temps réel.
  double pourcentage(double montantDepense) {
    if (montantMax <= 0) return 0;
    return (montantDepense / montantMax).clamp(0.0, 1.0);
  }

  /// Montant restant disponible dans le budget.
  double montantRestant(double montantDepense) {
    return (montantMax - montantDepense).clamp(0, double.infinity);
  }

  /// Statut du budget selon le pourcentage consommé.
  /// Utilisé pour la couleur de la barre de progression.
  StatutBudget statut(double montantDepense) {
    final pct = pourcentage(montantDepense);
    if (pct >= 1.0) return StatutBudget.depasse;
    if (pct >= 0.75) return StatutBudget.attention;
    return StatutBudget.normal;
  }

  /// Nom du mois en français
  String get nomMois {
    const moisFr = [
      '', 'Janvier', 'Février', 'Mars', 'Avril',
      'Mai', 'Juin', 'Juillet', 'Août',
      'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return moisFr[mois];
  }

  /// Vrai si ce budget correspond au mois et à l'année donnés
  bool estPourPeriode(int mois, int annee) {
    return this.mois == mois && this.annee == annee;
  }

  // ── Copie avec modifications ───────────────────────────────────

  BudgetModel copyWith({
    String? id,
    String? categorieId,
    double? montantMax,
    int? mois,
    int? annee,
    bool? estRecurrent,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categorieId: categorieId ?? this.categorieId,
      montantMax: montantMax ?? this.montantMax,
      mois: mois ?? this.mois,
      annee: annee ?? this.annee,
      estRecurrent: estRecurrent ?? this.estRecurrent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'BudgetModel(id: $id, categorieId: $categorieId, '
      'montantMax: $montantMax, mois: $mois/$annee)';
}

/// Statut d'un budget selon sa consommation.
///
/// normal   → < 75% consommé  → vert
/// attention → 75–99% consommé → orange
/// depasse  → 100%+ consommé  → rouge
enum StatutBudget {
  normal,    // Tout va bien
  attention, // À surveiller
  depasse,   // Plafond dépassé
}