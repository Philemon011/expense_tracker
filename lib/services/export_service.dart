import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/operation_model.dart';
import '../services/operation_service.dart';
import '../services/categorie_service.dart';
import '../services/compte_service.dart';
import '../utils/formatters.dart';

/// Service d'export CSV des opérations.
///
/// Utilisation :
///   Step 1 — Générer le CSV :
///     final resultat = await ExportService().generer(...)
///
///   Step 2a — Partager :
///     await ExportService().partager(resultat.cheminFichier)
///
///   Step 2b — Sauvegarder en local :
///     await ExportService().sauvegarderEnLocal(resultat.cheminFichier)
class ExportService {

  // ── Services ───────────────────────────────────────────────────
  final _operationService = OperationService();
  final _categorieService = CategorieService();
  final _compteService = CompteService();

  // ── En-têtes CSV ───────────────────────────────────────────────

  /// Colonnes du fichier CSV
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

  // ── STEP 1 : Récupérer les opérations ─────────────────────────

  /// Retourne toutes les opérations.
  List<OperationModel> toutesLesOperations() {
    return _operationService.toutesLesOperations();
  }

  /// Retourne les opérations d'un mois donné.
  List<OperationModel> operationsDuMois({
    required int mois,
    required int annee,
  }) {
    return _operationService.operationsParMois(
      mois: mois,
      annee: annee,
    );
  }

  /// Retourne les opérations entre deux dates.
  List<OperationModel> operationsParPeriode({
    required DateTime debut,
    required DateTime fin,
  }) {
    return _operationService
        .toutesLesOperations()
        .where((op) {
          final dateOp = DateTime(
            op.date.year,
            op.date.month,
            op.date.day,
          );
          final dateDebut = DateTime(
            debut.year,
            debut.month,
            debut.day,
          );
          final dateFin = DateTime(
            fin.year,
            fin.month,
            fin.day,
          );
          return !dateOp.isBefore(dateDebut) &&
              !dateOp.isAfter(dateFin);
        })
        .toList();
  }

  // ── STEP 2 : Générer le fichier CSV ────────────────────────────

  /// Génère un fichier CSV à partir d'une liste d'opérations.
  ///
  /// Retourne un [ResultatExport] avec :
  ///   - succes : true si le fichier a été créé
  ///   - cheminFichier : chemin du fichier temporaire
  ///   - nombreOperations : nombre de lignes exportées
  Future<ResultatExport> generer({
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

      // Convertir en texte CSV
      final csvString = const ListToCsvConverter().convert(lignes);

      // Sauvegarder dans un fichier temporaire
      final repertoireTemp = await getTemporaryDirectory();
      final horodatage = DateTime.now().millisecondsSinceEpoch;
      final chemin =
          '${repertoireTemp.path}/${nomFichier}_$horodatage.csv';

      final fichier = File(chemin);
      await fichier.writeAsString(csvString, encoding: utf8);

      debugPrint('✅ ExportService : CSV généré → $chemin');

      return ResultatExport(
        succes: true,
        message: '${operations.length} opération(s) exportée(s)',
        nombreOperations: operations.length,
        cheminFichier: chemin,
        nomFichier: '${nomFichier}_$horodatage',
      );

    } catch (e) {
      debugPrint('❌ ExportService : erreur génération → $e');
      return ResultatExport(
        succes: false,
        message: 'Erreur lors de la génération',
        nombreOperations: 0,
      );
    }
  }

  // ── STEP 3a : Partager ─────────────────────────────────────────

  /// Partage le fichier CSV via les apps du téléphone.
  ///
  /// Ouvre le sélecteur natif (WhatsApp, Email, Drive...)
  Future<void> partager(ResultatExport resultat) async {
    if (resultat.cheminFichier == null) return;

    await Share.shareXFiles(
      [XFile(resultat.cheminFichier!)],
      subject: 'Export — Expense Tracker',
      text: '${resultat.nombreOperations} opération(s) exportée(s)',
    );

    debugPrint('✅ ExportService : fichier partagé');
  }

  // ── STEP 3b : Sauvegarder en local ────────────────────────────

  /// Sauvegarde le fichier CSV dans le dossier Téléchargements.
  ///
  /// Android : /storage/emulated/0/Download/
  /// Retourne le chemin final du fichier sauvegardé.
  Future<ResultatSauvegarde> sauvegarderEnLocal(
    ResultatExport resultat,
  ) async {
    if (resultat.cheminFichier == null) {
      return ResultatSauvegarde(
        succes: false,
        message: 'Fichier introuvable',
      );
    }

    try {
      // Demander la permission si nécessaire
      final aPermission = await _verifierPermission();
      if (!aPermission) {
        return ResultatSauvegarde(
          succes: false,
          message: 'Permission de stockage refusée.\n'
              'Activez-la dans les paramètres de l\'app.',
        );
      }

      // Chemin de destination dans Téléchargements
      const cheminTelechargements =
          '/storage/emulated/0/Download';
      final nomFichierFinal =
          '${resultat.nomFichier ?? 'expense_tracker'}.csv';
      final cheminDestination =
          '$cheminTelechargements/$nomFichierFinal';

      // Copier le fichier temporaire vers Téléchargements
      await File(resultat.cheminFichier!).copy(cheminDestination);

      debugPrint(
        '✅ ExportService : sauvegardé → $cheminDestination',
      );

      return ResultatSauvegarde(
        succes: true,
        message: 'Fichier sauvegardé avec succès',
        cheminFichier: cheminDestination,
        nomFichier: nomFichierFinal,
      );

    } catch (e) {
      debugPrint('❌ ExportService : erreur sauvegarde → $e');
      return ResultatSauvegarde(
        succes: false,
        message: 'Erreur lors de la sauvegarde',
      );
    }
  }

  // ── Utilitaires privés ─────────────────────────────────────────

  /// Construit les lignes du CSV depuis les opérations.
  List<List<dynamic>> _construireLignes({
    required List<OperationModel> operations,
    required String devise,
  }) {
    final lignes = <List<dynamic>>[];

    // Ligne 1 — En-têtes des colonnes
    lignes.add(_entetes);

    // Lignes suivantes — Données
    for (final op in operations) {
      final categorie = _categorieService.categorieParId(
        op.categorieId,
      );
      final compte = _compteService.compteParId(op.compteId);

      lignes.add([
        // Date au format JJ/MM/AAAA
        '${op.date.day.toString().padLeft(2, '0')}/'
            '${op.date.month.toString().padLeft(2, '0')}/'
            '${op.date.year}',

        // Heure au format HH:MM
        '${op.date.hour.toString().padLeft(2, '0')}:'
            '${op.date.minute.toString().padLeft(2, '0')}',

        // Type — Revenu ou Dépense
        op.estEntree ? 'Revenu' : 'Dépense',

        // Nom de la catégorie
        categorie?.nom ?? 'Sans catégorie',

        // Nom du compte
        compte?.nom ?? 'Sans compte',

        // Montant — positif si entrée, négatif si sortie
        op.estEntree ? op.montant : -op.montant,

        // Devise
        devise,

        // Note libre
        op.note ?? '',
      ]);
    }

    return lignes;
  }

  /// Vérifie et demande la permission de stockage.
  ///
  /// Android 13+ (SDK 33+) — pas de permission nécessaire
  /// Android < 13 — demande permission WRITE_EXTERNAL_STORAGE
  Future<bool> _verifierPermission() async {
    if (!Platform.isAndroid) return true;

    // Android 13+ — accès libre aux téléchargements
    final sdkVersion = await _getAndroidSdkVersion();
    if (sdkVersion >= 33) return true;

    // Android < 13 — demander permission
    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    final resultat = await Permission.storage.request();
    return resultat.isGranted;
  }

  /// Retourne la version SDK Android.
  Future<int> _getAndroidSdkVersion() async {
    try {
      final result = await Process.run(
        'getprop',
        ['ro.build.version.sdk'],
      );
      return int.tryParse(
            result.stdout.toString().trim(),
          ) ??
          0;
    } catch (_) {
      // En cas d'erreur — supposer Android 13+
      return 33;
    }
  }

  // ── Aperçu avant export ────────────────────────────────────────

  /// Retourne le nombre d'opérations disponibles.
  ///
  /// Utilisé pour afficher un aperçu dans l'UI.
  int nombreOperations({int? mois, int? annee}) {
    if (mois != null && annee != null) {
      return operationsDuMois(mois: mois, annee: annee).length;
    }
    return toutesLesOperations().length;
  }
}

// ── Modèles de résultat ────────────────────────────────────────────

/// Résultat de la génération du CSV.
class ResultatExport {
  const ResultatExport({
    required this.succes,
    required this.message,
    required this.nombreOperations,
    this.cheminFichier,
    this.nomFichier,
  });

  /// Vrai si la génération a réussi
  final bool succes;

  /// Message de succès ou d'erreur
  final String message;

  /// Nombre d'opérations dans le CSV
  final int nombreOperations;

  /// Chemin du fichier temporaire généré
  final String? cheminFichier;

  /// Nom du fichier sans extension
  final String? nomFichier;
}

/// Résultat de la sauvegarde locale.
class ResultatSauvegarde {
  const ResultatSauvegarde({
    required this.succes,
    required this.message,
    this.cheminFichier,
    this.nomFichier,
  });

  /// Vrai si la sauvegarde a réussi
  final bool succes;

  /// Message de succès ou d'erreur
  final String message;

  /// Chemin complet du fichier sauvegardé
  final String? cheminFichier;

  /// Nom du fichier avec extension
  final String? nomFichier;
}