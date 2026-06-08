import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/operation_model.dart';
import '../services/operation_service.dart';
import '../services/categorie_service.dart';
import '../services/compte_service.dart';
import '../utils/formatters.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

/// Service d'export des opérations en CSV.
///
/// Génère un fichier CSV et le partage via les apps
/// du téléphone (Email, WhatsApp, Drive...).
///
/// Utilisation :
///   final service = ExportService();
///   await service.exporterTout(devise: 'FCFA');
///   await service.exporterParMois(mois: 6, annee: 2026, devise: 'FCFA');
class ExportService {
  // ── Services ───────────────────────────────────────────────────
  final _operationService = OperationService();
  final _categorieService = CategorieService();
  final _compteService = CompteService();

  // ── En-têtes du CSV ────────────────────────────────────────────

  /// En-têtes des colonnes du fichier CSV
  static const List<String> _entetes = [
    'Date',
    'Heure',
    'Type',
    'Catégorie',
    'Compte',
    'Montant',
    'Devise',
    'Note',
  ];

  // ── Export complet ─────────────────────────────────────────────

  /// Exporte toutes les opérations en CSV.
  Future<ResultatExport> exporterTout({
    required String devise,
  }) async {
    final operations = _operationService.toutesLesOperations();
    return _genererEtPartager(
      operations: operations,
      devise: devise,
      nomFichier: 'operations_complet',
    );
  }

  /// Exporte les opérations d'un mois spécifique.
  Future<ResultatExport> exporterParMois({
    required int mois,
    required int annee,
    required String devise,
  }) async {
    final operations = _operationService.operationsParMois(
      mois: mois,
      annee: annee,
    );

    final nomMois = Formatters.nomMois(mois).toLowerCase();
    return _genererEtPartager(
      operations: operations,
      devise: devise,
      nomFichier: 'operations_${nomMois}_$annee',
    );
  }

  /// Exporte les opérations d'une période personnalisée.
  Future<ResultatExport> exporterParPeriode({
    required DateTime debut,
    required DateTime fin,
    required String devise,
  }) async {
    final toutes = _operationService.toutesLesOperations();

    // Filtrer selon la période
    final operations = toutes.where((op) {
      return op.date.isAfter(
            debut.subtract(const Duration(days: 1)),
          ) &&
          op.date.isBefore(
            fin.add(const Duration(days: 1)),
          );
    }).toList();

    return _genererEtPartager(
      operations: operations,
      devise: devise,
      nomFichier: 'operations_'
          '${debut.day}-${debut.month}-${debut.year}_'
          '${fin.day}-${fin.month}-${fin.year}',
    );
  }

  // ── Génération ─────────────────────────────────────────────────

  /// Génère le CSV et le partage.
  Future<ResultatExport> _genererEtPartager({
    required List<OperationModel> operations,
    required String devise,
    required String nomFichier,
  }) async {
    // Vérifier qu'il y a des données
    if (operations.isEmpty) {
      return ResultatExport(
        succes: false,
        message: 'Aucune opération à exporter',
        nombreOperations: 0,
      );
    }

    try {
      // Construire les lignes du CSV
      final lignes = _construireLignes(
        operations: operations,
        devise: devise,
      );

      // Convertir en string CSV
      final csvString = const ListToCsvConverter().convert(lignes);

      // Sauvegarder dans un fichier temporaire
      final fichier = await _sauvegarderFichier(
        contenu: csvString,
        nomFichier: nomFichier,
      );

      // Partager le fichier
      await Share.shareXFiles(
        [XFile(fichier.path)],
        subject: 'Export opérations — $nomFichier',
        text: 'Export de ${operations.length} opération(s) '
            'depuis Expense Tracker',
      );

      debugPrint(
        '✅ ExportService : ${operations.length} opérations exportées',
      );

      return ResultatExport(
        succes: true,
        message: '${operations.length} opération(s) exportée(s)',
        nombreOperations: operations.length,
        cheminFichier: fichier.path,
      );
    } catch (e) {
      debugPrint('❌ ExportService : erreur → $e');
      return ResultatExport(
        succes: false,
        message: 'Erreur lors de l\'export : $e',
        nombreOperations: 0,
      );
    }
  }

  /// Construit la liste des lignes du CSV.
  ///
  /// Première ligne = en-têtes
  /// Lignes suivantes = données des opérations
  List<List<dynamic>> _construireLignes({
    required List<OperationModel> operations,
    required String devise,
  }) {
    final lignes = <List<dynamic>>[];

    // ── Ligne d'en-têtes ──────────────────────────────────────
    lignes.add(_entetes);

    // ── Lignes de données ─────────────────────────────────────
    for (final op in operations) {
      // Récupérer les noms depuis les services
      final categorie = _categorieService.categorieParId(
        op.categorieId,
      );
      final compte = _compteService.compteParId(op.compteId);

      lignes.add([
        // Date — format DD/MM/YYYY
        '${op.date.day.toString().padLeft(2, '0')}/'
            '${op.date.month.toString().padLeft(2, '0')}/'
            '${op.date.year}',

        // Heure — format HH:MM
        '${op.date.hour.toString().padLeft(2, '0')}:'
            '${op.date.minute.toString().padLeft(2, '0')}',

        // Type — Revenu ou Dépense
        op.estEntree ? 'Revenu' : 'Dépense',

        // Catégorie
        categorie?.nom ?? 'Sans catégorie',

        // Compte
        compte?.nom ?? 'Sans compte',

        // Montant — positif pour entrée, négatif pour sortie
        op.estEntree ? op.montant : -op.montant,

        // Devise
        devise,

        // Note
        op.note ?? '',
      ]);
    }

    return lignes;
  }

  /// Sauvegarde le contenu CSV dans un fichier temporaire.
  Future<File> _sauvegarderFichier({
    required String contenu,
    required String nomFichier,
  }) async {
    // Répertoire temporaire de l'appareil
    final repertoire = await getTemporaryDirectory();

    // Créer le fichier avec horodatage
    final horodatage = DateTime.now().millisecondsSinceEpoch;
    final chemin = '${repertoire.path}/'
        '${nomFichier}_$horodatage.csv';

    final fichier = File(chemin);
    await fichier.writeAsString(contenu, encoding: utf8);

    debugPrint('✅ ExportService : fichier créé → $chemin');
    return fichier;
  }

  // ── Statistiques export ────────────────────────────────────────

  /// Retourne un résumé des données à exporter.
  ///
  /// Utile pour afficher un aperçu avant l'export.
  Map<String, dynamic> apercuExport({
    int? mois,
    int? annee,
  }) {
    final operations = (mois != null && annee != null)
        ? _operationService.operationsParMois(
            mois: mois,
            annee: annee,
          )
        : _operationService.toutesLesOperations();

    final totalEntrees = operations
        .where((op) => op.estEntree)
        .fold(0.0, (sum, op) => sum + op.montant);

    final totalSorties = operations
        .where((op) => op.estSortie)
        .fold(0.0, (sum, op) => sum + op.montant);

    return {
      'nombreOperations': operations.length,
      'totalEntrees': totalEntrees,
      'totalSorties': totalSorties,
      'premièreDate': operations.isNotEmpty ? operations.last.date : null,
      'dernièreDate': operations.isNotEmpty ? operations.first.date : null,
    };
  }

  /// Sauvegarde le CSV dans le dossier Téléchargements.
  ///
  /// Retourne le chemin du fichier sauvegardé.
  Future<ResultatExport> sauvegarderEnLocal({
    required String devise,
    int? mois,
    int? annee,
  }) async {
    try {
      // ── Demander la permission ───────────────────────────────
      final permission = await _demanderPermission();
      if (!permission) {
        return ResultatExport(
          succes: false,
          message: 'Permission de stockage refusée',
          nombreOperations: 0,
        );
      }

      // ── Récupérer les opérations ─────────────────────────────
      final operations = (mois != null && annee != null)
          ? _operationService.operationsParMois(
              mois: mois,
              annee: annee,
            )
          : _operationService.toutesLesOperations();

      if (operations.isEmpty) {
        return ResultatExport(
          succes: false,
          message: 'Aucune opération à exporter',
          nombreOperations: 0,
        );
      }

      // ── Générer le CSV ───────────────────────────────────────
      final lignes = _construireLignes(
        operations: operations,
        devise: devise,
      );
      final csvString = const ListToCsvConverter().convert(lignes);

      // ── Sauvegarder dans Téléchargements ─────────────────────
      final chemin = await _cheminTelechargements();
      final nomMois = (mois != null)
          ? '_${Formatters.nomMois(mois).toLowerCase()}_$annee'
          : '_complet';
      final horodatage = DateTime.now().millisecondsSinceEpoch;
      final nomFichier = 'expense_tracker$nomMois\_$horodatage.csv';
      final cheminComplet = '$chemin/$nomFichier';

      final fichier = File(cheminComplet);
      await fichier.writeAsString(csvString, encoding: utf8);

      debugPrint('✅ ExportService : sauvegardé → $cheminComplet');

      return ResultatExport(
        succes: true,
        message: 'Fichier sauvegardé dans Téléchargements\n$nomFichier',
        nombreOperations: operations.length,
        cheminFichier: cheminComplet,
      );
    } catch (e) {
      debugPrint('❌ ExportService : erreur sauvegarde → $e');
      return ResultatExport(
        succes: false,
        message: 'Erreur lors de la sauvegarde : $e',
        nombreOperations: 0,
      );
    }
  }

  /// Demande la permission de stockage selon la version Android.
  Future<bool> _demanderPermission() async {
    // Android 13+ — pas besoin de permission pour les téléchargements
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) return true;

      // Android < 13 — demander permission stockage
      final status = await Permission.storage.request();
      return status.isGranted;
    }

    // iOS — pas de permission nécessaire pour les documents
    return true;
  }

  /// Retourne la version Android.
  Future<int> _getAndroidVersion() async {
    try {
      // Lire la version depuis les propriétés système
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Retourne le chemin du dossier Téléchargements.
  Future<String> _cheminTelechargements() async {
    if (Platform.isAndroid) {
      // Dossier Téléchargements Android
      return '/storage/emulated/0/Download';
    } else {
      // iOS — dossier Documents de l'app
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }




  /// Génère le CSV et retourne le fichier temporaire.
/// Sans partager ni sauvegarder — juste générer.
Future<ResultatExport> generer({
  required List<OperationModel> operations,
  required String devise,
  required String nomFichier,
}) async {
  if (operations.isEmpty) {
    return ResultatExport(
      succes: false,
      message: 'Aucune opération à exporter',
      nombreOperations: 0,
    );
  }

  try {
    final lignes = _construireLignes(
      operations: operations,
      devise: devise,
    );
    final csvString = const ListToCsvConverter().convert(lignes);
    final fichier = await _sauvegarderFichier(
      contenu: csvString,
      nomFichier: nomFichier,
    );

    return ResultatExport(
      succes: true,
      message: '${operations.length} opération(s) exportée(s)',
      nombreOperations: operations.length,
      cheminFichier: fichier.path,
    );
  } catch (e) {
    return ResultatExport(
      succes: false,
      message: 'Erreur lors de la génération : $e',
      nombreOperations: 0,
    );
  }
}

/// Partage un fichier CSV déjà généré.
Future<void> partager(String cheminFichier) async {
  await Share.shareXFiles(
    [XFile(cheminFichier)],
    subject: 'Export opérations — Expense Tracker',
    text: 'Export depuis Expense Tracker',
  );
}

// / Sauvegarde un fichier CSV dans les Téléchargements.
// Future<ResultatExport> sauvegarderEnLocal(
//   String cheminFichier,
//   String nomFichier,
// ) async {
//   try {
//     final permission = await _demanderPermission();
//     if (!permission) {
//       return ResultatExport(
//         succes: false,
//         message: 'Permission de stockage refusée',
//         nombreOperations: 0,
//       );
//     }

//     final cheminDest =
//         '/storage/emulated/0/Download/$nomFichier.csv';

//     // Copier le fichier temporaire vers Téléchargements
//     await File(cheminFichier).copy(cheminDest);

//     return ResultatExport(
//       succes: true,
//       message: 'Sauvegardé dans Téléchargements',
//       nombreOperations: 0,
//       cheminFichier: cheminDest,
//     );
//   } catch (e) {
//     return ResultatExport(
//       succes: false,
//       message: 'Erreur : $e',
//       nombreOperations: 0,
//     );
//   }
// }
}

// ── Résultat d'export ──────────────────────────────────────────────

/// Résultat d'une opération d'export.
class ResultatExport {
  const ResultatExport({
    required this.succes,
    required this.message,
    required this.nombreOperations,
    this.cheminFichier,
  });

  /// Vrai si l'export a réussi
  final bool succes;

  /// Message de succès ou d'erreur
  final String message;

  /// Nombre d'opérations exportées
  final int nombreOperations;

  /// Chemin du fichier généré
  final String? cheminFichier;
}
