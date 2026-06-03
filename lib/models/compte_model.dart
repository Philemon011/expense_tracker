import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'compte_model.g.dart';

/// Types de compte disponibles.
enum TypeCompte {
  bancaire,     // Compte bancaire classique
  especes,      // Argent liquide
  mobileMoney,  // Mobile money (Wave, Orange Money...)
  epargne,      // Compte épargne
  autre,        // Autre type de compte
}

/// Modèle d'un compte financier.
///
/// Un compte représente un endroit où l'argent est stocké.
/// Chaque opération est obligatoirement rattachée à un compte.
///
/// Exemples :
///   - Compte bancaire CIB
///   - Espèces (portefeuille)
///   - Wave / Orange Money
@HiveType(typeId: 3)
class CompteModel extends HiveObject {

  /// Identifiant unique
  @HiveField(0)
  final String id;

  /// Nom du compte — affiché dans l'UI
  @HiveField(1)
  final String nom;

  /// Type de compte
  @HiveField(2)
  final TypeCompte type;

  /// Solde initial du compte à sa création
  @HiveField(3)
  final double soldeInitial;

  /// Couleur du compte stockée en int
  @HiveField(4)
  final int couleurValue;

  /// Code de l'icône MaterialIcons
  @HiveField(5)
  final int iconeCode;

  /// Devise du compte (FCFA, EUR, USD...)
  @HiveField(6)
  final String devise;

  /// Vrai si c'est le compte principal (sélectionné par défaut)
  @HiveField(7)
  final bool estPrincipal;

  /// Vrai si le compte est archivé (caché mais conservé)
  @HiveField(8)
  final bool estArchive;

  /// Date de création du compte
  @HiveField(9)
  final DateTime createdAt;

  CompteModel({
    required this.id,
    required this.nom,
    required this.type,
    required this.soldeInitial,
    required this.couleurValue,
    required this.iconeCode,
    required this.devise,
    this.estPrincipal = false,
    this.estArchive = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Getters utiles ─────────────────────────────────────────────

  /// Retourne la couleur Flutter depuis la valeur stockée
  Color get couleur => Color(couleurValue);

  /// Retourne l'icône Flutter depuis le code stocké
  IconData get icone => IconData(iconeCode, fontFamily: 'MaterialIcons');

  /// Nom lisible du type de compte en français
  String get typeNom {
    switch (type) {
      case TypeCompte.bancaire:
        return 'Compte bancaire';
      case TypeCompte.especes:
        return 'Espèces';
      case TypeCompte.mobileMoney:
        return 'Mobile Money';
      case TypeCompte.epargne:
        return 'Épargne';
      case TypeCompte.autre:
        return 'Autre';
    }
  }

  // ── Copie avec modifications ───────────────────────────────────

  CompteModel copyWith({
    String? id,
    String? nom,
    TypeCompte? type,
    double? soldeInitial,
    int? couleurValue,
    int? iconeCode,
    String? devise,
    bool? estPrincipal,
    bool? estArchive,
    DateTime? createdAt,
  }) {
    return CompteModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      soldeInitial: soldeInitial ?? this.soldeInitial,
      couleurValue: couleurValue ?? this.couleurValue,
      iconeCode: iconeCode ?? this.iconeCode,
      devise: devise ?? this.devise,
      estPrincipal: estPrincipal ?? this.estPrincipal,
      estArchive: estArchive ?? this.estArchive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'CompteModel(id: $id, nom: $nom, type: $type)';
}

/// Adapter Hive pour l'enum TypeCompte
class TypeCompteAdapter extends TypeAdapter<TypeCompte> {
  @override
  final int typeId = 5;

  @override
  TypeCompte read(BinaryReader reader) {
    return TypeCompte.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TypeCompte obj) {
    writer.writeByte(obj.index);
  }
}

/// Comptes par défaut créés au premier lancement.
class ComptesParDefaut {

  /// Retourne la liste des comptes par défaut.
  /// La devise est passée en paramètre depuis les préférences.
  static List<CompteModel> get(String devise) => [
    CompteModel(
      id: 'compte_principal',
      nom: 'Compte principal',
      type: TypeCompte.bancaire,
      soldeInitial: 0,
      couleurValue: 0xFF4CAF7A,
      iconeCode: Icons.account_balance_rounded.codePoint,
      devise: devise,
      estPrincipal: true,
    ),
    CompteModel(
      id: 'compte_especes',
      nom: 'Espèces',
      type: TypeCompte.especes,
      soldeInitial: 0,
      couleurValue: 0xFFF59E0B,
      iconeCode: Icons.wallet_rounded.codePoint,
      devise: devise,
    ),
  ];
}