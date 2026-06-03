import 'package:hive/hive.dart';

// Indique à Hive que ce fichier contient un TypeAdapter.
// Le fichier généré s'appellera operation_model.g.dart
part 'operation_model.g.dart';

/// Types d'opération possibles.
///
/// entree → argent qui rentre (salaire, remboursement...)
/// sortie → argent qui sort (courses, loyer, transport...)
enum TypeOperation { entree, sortie }

/// Modèle d'une opération financière.
///
/// Une opération = une entrée ou une sortie d'argent.
/// Stockée localement dans Hive — fonctionne 100% offline.
///
/// Exemple :
///   OperationModel(
///     id: 'uuid-xxx',
///     montant: 1200.0,
///     type: TypeOperation.entree,
///     categorieId: 'uuid-cat',
///     compteId: 'uuid-compte',
///     date: DateTime.now(),
///     note: 'Salaire du mois',
///   )
@HiveType(typeId: 0) // typeId unique pour chaque modèle Hive
class OperationModel extends HiveObject {

  /// Identifiant unique généré par uuid
  @HiveField(0)
  final String id;

  /// Montant de l'opération (toujours positif)
  @HiveField(1)
  final double montant;

  /// Type : entree ou sortie
  @HiveField(2)
  final TypeOperation type;

  /// Référence vers la catégorie (id)
  @HiveField(3)
  final String categorieId;

  /// Référence vers le compte (id)
  @HiveField(4)
  final String compteId;

  /// Date de l'opération
  @HiveField(5)
  final DateTime date;

  /// Note optionnelle — description libre
  @HiveField(6)
  final String? note;

  /// Date de création dans l'app (pour le tri)
  @HiveField(7)
  final DateTime createdAt;

  OperationModel({
    required this.id,
    required this.montant,
    required this.type,
    required this.categorieId,
    required this.compteId,
    required this.date,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Getters utiles ─────────────────────────────────────────────

  /// Vrai si c'est une entrée d'argent
  bool get estEntree => type == TypeOperation.entree;

  /// Vrai si c'est une sortie d'argent
  bool get estSortie => type == TypeOperation.sortie;

  /// Montant signé — positif pour entrée, négatif pour sortie
  double get montantSigne => estEntree ? montant : -montant;

  // ── Copie avec modifications ───────────────────────────────────

  /// Crée une copie de l'opération avec certains champs modifiés.
  /// Utile pour la modification d'une opération existante.
  OperationModel copyWith({
    String? id,
    double? montant,
    TypeOperation? type,
    String? categorieId,
    String? compteId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return OperationModel(
      id: id ?? this.id,
      montant: montant ?? this.montant,
      type: type ?? this.type,
      categorieId: categorieId ?? this.categorieId,
      compteId: compteId ?? this.compteId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'OperationModel('
        'id: $id, '
        'montant: $montant, '
        'type: $type, '
        'date: $date'
        ')';
  }
}

/// Adapter Hive pour le type TypeOperation (enum).
///
/// Nécessaire car Hive ne sait pas stocker les enums nativement.
/// typeId: 1 — chaque adapter a un id unique
class TypeOperationAdapter extends TypeAdapter<TypeOperation> {
  @override
  final int typeId = 1;

  @override
  TypeOperation read(BinaryReader reader) {
    // Lire l'index de l'enum depuis Hive
    final index = reader.readByte();
    return TypeOperation.values[index];
  }

  @override
  void write(BinaryWriter writer, TypeOperation obj) {
    // Stocker l'index de l'enum dans Hive
    writer.writeByte(obj.index);
  }
}