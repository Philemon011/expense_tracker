import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

/// Types de notifications disponibles.
enum TypeNotification {
  budgetDepasse,    // Budget dépassé — rouge
  budgetAlerte,     // Budget à 75% — orange
  grosseDepense,    // Dépense importante — bleu
  resumeMensuel,    // Résumé du mois — vert
}

/// Modèle d'une notification in-app.
///
/// Stockée localement dans Hive.
/// Générée automatiquement selon les événements financiers.
@HiveType(typeId: 6)
class NotificationModel extends HiveObject {

  /// Identifiant unique
  @HiveField(0)
  final String id;

  /// Type de notification
  @HiveField(1)
  final TypeNotification type;

  /// Titre court de la notification
  @HiveField(2)
  final String titre;

  /// Message détaillé
  @HiveField(3)
  final String message;

  /// Date de création
  @HiveField(4)
  final DateTime date;

  /// Vrai si l'utilisateur a lu la notification
  @HiveField(5)
  bool estLue;

  /// Données supplémentaires — ex: id du budget concerné
  @HiveField(6)
  final String? donneeId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    required this.date,
    this.estLue = false,
    this.donneeId,
  });

  // ── Getters utiles ─────────────────────────────────────────────

  /// Couleur selon le type de notification
  Color get couleur {
    switch (type) {
      case TypeNotification.budgetDepasse:
        return const Color(0xFFEF4444);
      case TypeNotification.budgetAlerte:
        return const Color(0xFFF59E0B);
      case TypeNotification.grosseDepense:
        return const Color(0xFF3B82F6);
      case TypeNotification.resumeMensuel:
        return const Color(0xFF4CAF7A);
    }
  }

  /// Icône selon le type de notification
  IconData get icone {
    switch (type) {
      case TypeNotification.budgetDepasse:
        return Icons.warning_rounded;
      case TypeNotification.budgetAlerte:
        return Icons.info_rounded;
      case TypeNotification.grosseDepense:
        return Icons.trending_up_rounded;
      case TypeNotification.resumeMensuel:
        return Icons.bar_chart_rounded;
    }
  }

  /// Fond coloré selon le type
  Color get couleurFond {
    switch (type) {
      case TypeNotification.budgetDepasse:
        return const Color(0xFFFEF2F2);
      case TypeNotification.budgetAlerte:
        return const Color(0xFFFFFBEB);
      case TypeNotification.grosseDepense:
        return const Color(0xFFEFF6FF);
      case TypeNotification.resumeMensuel:
        return const Color(0xFFE8F5EE);
    }
  }

  @override
  String toString() =>
      'NotificationModel(id: $id, type: $type, titre: $titre)';
}

/// Adapter Hive pour TypeNotification
class TypeNotificationAdapter extends TypeAdapter<TypeNotification> {
  @override
  final int typeId = 7;

  @override
  TypeNotification read(BinaryReader reader) {
    return TypeNotification.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TypeNotification obj) {
    writer.writeByte(obj.index);
  }
}