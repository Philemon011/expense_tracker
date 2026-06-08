import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../models/budget_model.dart';
import '../models/operation_model.dart';
import '../utils/constantes.dart';
import '../utils/formatters.dart';
import 'budget_service.dart';
import 'operation_service.dart';

/// Service de gestion des notifications in-app.
///
/// Responsabilités :
///   - CRUD notifications dans Hive
///   - Génération automatique selon les événements
///   - Éviter les doublons
///   - Limiter à 50 notifications max
class NotificationService {

  // ── Accès à la boîte Hive ──────────────────────────────────────
  Box<NotificationModel> get _box =>
      Hive.box<NotificationModel>(Constantes.boxNotifications);

  final _uuid = const Uuid();
  final _budgetService = BudgetService();
  final _operationService = OperationService();

  // ── Constantes ─────────────────────────────────────────────────

  /// Nombre maximum de notifications stockées
  static const int _maxNotifications = 50;

  /// Seuil pour une grosse dépense (en % du budget total)
  static const double _seuilGrosseDepense = 50000;

  // ── Lecture ────────────────────────────────────────────────────

  /// Retourne toutes les notifications triées par date décroissante.
  List<NotificationModel> toutesLesNotifications() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Retourne les notifications non lues.
  List<NotificationModel> notificationsNonLues() {
    return _box.values
        .where((n) => !n.estLue)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Nombre de notifications non lues.
  int get nombreNonLues =>
      _box.values.where((n) => !n.estLue).length;

  // ── CRUD ───────────────────────────────────────────────────────

  /// Marque une notification comme lue.
  Future<void> marquerCommeLue(String id) async {
    final notif = _box.get(id);
    if (notif == null) return;
    notif.estLue = true;
    await notif.save();
  }

  /// Marque toutes les notifications comme lues.
  Future<void> toutMarquerCommeLu() async {
    for (final notif in _box.values) {
      if (!notif.estLue) {
        notif.estLue = true;
        await notif.save();
      }
    }
  }

  /// Supprime une notification.
  Future<void> supprimerNotification(String id) async {
    await _box.delete(id);
  }

  /// Supprime toutes les notifications.
  Future<void> toutSupprimer() async {
    await _box.clear();
  }

  // ── Génération automatique ─────────────────────────────────────

  /// Vérifie et génère les notifications nécessaires.
  ///
  /// À appeler après chaque ajout/modification d'opération
  /// et au démarrage de l'app.
  Future<void> verifierEtGenerer({
    required String devise,
  }) async {
    await Future.wait([
      _verifierBudgets(devise: devise),
      _verifierGrossesDepenses(devise: devise),
      _verifierResumeMensuel(devise: devise),
    ]);

    // Nettoyer si trop de notifications
    await _nettoyerAnciennesNotifications();
  }

  // ── Vérification budgets ───────────────────────────────────────

  /// Vérifie tous les budgets du mois et génère les alertes.
  Future<void> _verifierBudgets({required String devise}) async {
    final now = DateTime.now();
    final budgets = _budgetService.budgetsDuMois(
      mois: now.month,
      annee: now.year,
    );

    for (final budget in budgets) {
      final progression = _budgetService.budgetAvecProgression(budget);

      if (progression.statut == StatutBudget.depasse) {
        await _genererNotifBudgetDepasse(
          budget: budget,
          montantDepense: progression.montantDepense,
          devise: devise,
        );
      } else if (progression.statut == StatutBudget.attention) {
        await _genererNotifBudgetAlerte(
          budget: budget,
          pourcentage: progression.pourcentage,
          devise: devise,
        );
      }
    }
  }

  /// Génère une notification de budget dépassé.
  /// Évite les doublons — une seule par budget par mois.
  Future<void> _genererNotifBudgetDepasse({
    required BudgetModel budget,
    required double montantDepense,
    required String devise,
  }) async {
    // Clé unique pour éviter les doublons
    final cleUnique = 'budget_depasse_${budget.id}_'
        '${DateTime.now().month}_${DateTime.now().year}';

    // Vérifier si déjà générée
    final existeDeja = _box.values.any(
      (n) => n.donneeId == cleUnique,
    );
    if (existeDeja) return;

    await _ajouterNotification(
      type: TypeNotification.budgetDepasse,
      titre: 'Budget dépassé !',
      message: 'Votre budget a été dépassé de '
          '${Formatters.montant(
            montantDepense - budget.montantMax,
            devise,
          )}.',
      donneeId: cleUnique,
    );
  }

  /// Génère une notification d'alerte budget (75%).
  Future<void> _genererNotifBudgetAlerte({
    required BudgetModel budget,
    required double pourcentage,
    required String devise,
  }) async {
    final cleUnique = 'budget_alerte_${budget.id}_'
        '${DateTime.now().month}_${DateTime.now().year}';

    final existeDeja = _box.values.any(
      (n) => n.donneeId == cleUnique,
    );
    if (existeDeja) return;

    await _ajouterNotification(
      type: TypeNotification.budgetAlerte,
      titre: 'Budget presque atteint',
      message: 'Vous avez consommé '
          '${(pourcentage * 100).toStringAsFixed(0)}% '
          'de votre budget ce mois-ci.',
      donneeId: cleUnique,
    );
  }

  // ── Vérification grosses dépenses ─────────────────────────────

  /// Vérifie les grosses dépenses récentes.
  Future<void> _verifierGrossesDepenses({
    required String devise,
  }) async {
    final now = DateTime.now();
    final operations = _operationService.operationsParMois(
      mois: now.month,
      annee: now.year,
    );

    // Filtrer les sorties importantes
    final grossesSorties = operations.where(
      (op) => op.estSortie && op.montant >= _seuilGrosseDepense,
    );

    for (final op in grossesSorties) {
      final cleUnique = 'grosse_depense_${op.id}';

      final existeDeja = _box.values.any(
        (n) => n.donneeId == cleUnique,
      );
      if (existeDeja) continue;

      await _ajouterNotification(
        type: TypeNotification.grosseDepense,
        titre: 'Dépense importante enregistrée',
        message: 'Une dépense de ${Formatters.montant(
          op.montant,
          devise,
        )} a été enregistrée${op.note != null
            ? ' : ${op.note}'
            : '.'}',
        donneeId: cleUnique,
      );
    }
  }

  // ── Résumé mensuel ─────────────────────────────────────────────

  /// Génère un résumé mensuel au début de chaque mois.
  Future<void> _verifierResumeMensuel({
    required String devise,
  }) async {
    final now = DateTime.now();

    // Générer le résumé du mois précédent
    // seulement les 3 premiers jours du mois
    if (now.day > 3) return;

    final moisPrec = now.month == 1 ? 12 : now.month - 1;
    final anneePrec = now.month == 1 ? now.year - 1 : now.year;

    final cleUnique = 'resume_${moisPrec}_$anneePrec';

    final existeDeja = _box.values.any(
      (n) => n.donneeId == cleUnique,
    );
    if (existeDeja) return;

    // Calculer les totaux du mois précédent
    final entrees = _operationService.calculerTotalEntrees(
      mois: moisPrec,
      annee: anneePrec,
    );
    final sorties = _operationService.calculerTotalSorties(
      mois: moisPrec,
      annee: anneePrec,
    );

    // Ne générer que si des opérations existent
    if (entrees == 0 && sorties == 0) return;

    final solde = entrees - sorties;
    final estPositif = solde >= 0;

    await _ajouterNotification(
      type: TypeNotification.resumeMensuel,
      titre: 'Résumé de ${Formatters.nomMois(moisPrec)}',
      message: 'Revenus : ${Formatters.montant(entrees, devise)} • '
          'Dépenses : ${Formatters.montant(sorties, devise)} • '
          'Solde : ${estPositif ? '+' : ''}'
          '${Formatters.montant(solde, devise)}',
      donneeId: cleUnique,
    );
  }

  // ── Utilitaires privés ─────────────────────────────────────────

  /// Ajoute une notification dans Hive.
  Future<void> _ajouterNotification({
    required TypeNotification type,
    required String titre,
    required String message,
    String? donneeId,
  }) async {
    final notif = NotificationModel(
      id: _uuid.v4(),
      type: type,
      titre: titre,
      message: message,
      date: DateTime.now(),
      donneeId: donneeId,
    );

    await _box.put(notif.id, notif);
    debugPrint('✅ NotificationService : notif ajoutée → $titre');
  }

  /// Supprime les notifications les plus anciennes
  /// si on dépasse la limite de 50.
  Future<void> _nettoyerAnciennesNotifications() async {
    if (_box.length <= _maxNotifications) return;

    // Trier par date et supprimer les plus anciennes
    final triees = _box.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final aSupprimer = triees.take(
      _box.length - _maxNotifications,
    );

    for (final notif in aSupprimer) {
      await _box.delete(notif.id);
    }

    debugPrint(
      '✅ NotificationService : nettoyage — '
      '${aSupprimer.length} notification(s) supprimée(s)',
    );
  }
}