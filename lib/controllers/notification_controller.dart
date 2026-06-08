import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/constantes.dart';

/// Controller des notifications in-app.
///
/// Expose :
///   - Liste réactive des notifications
///   - Nombre de notifications non lues
///   - Méthodes de gestion (lire, supprimer...)
class NotificationController extends GetxController {

  // ── Service ────────────────────────────────────────────────────
  final _service = NotificationService();

  // ── État réactif ───────────────────────────────────────────────

  /// Toutes les notifications
  final _notifications = <NotificationModel>[].obs;
  List<NotificationModel> get notifications => _notifications;

  /// Nombre de notifications non lues
  final _nombreNonLues = 0.obs;
  int get nombreNonLues => _nombreNonLues.value;

  /// Vrai si au moins une notification non lue
  bool get aDesNonLues => _nombreNonLues.value > 0;

  /// Vrai pendant le chargement
  final _estEnChargement = false.obs;
  bool get estEnChargement => _estEnChargement.value;

  /// Devise de l'app
  final _devise = Constantes.deviseDefaut.obs;
  String get devise => _devise.value;

  // ── Cycle de vie ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _chargerDevise();
    _chargerNotifications();
  }

  // ── Chargement ─────────────────────────────────────────────────

  /// Charge la devise depuis les préférences.
  void _chargerDevise() {
    final box = Hive.box(Constantes.boxPreferences);
    _devise.value = box.get(
      Constantes.cleDevise,
      defaultValue: Constantes.deviseDefaut,
    ) as String;
  }

  /// Charge toutes les notifications depuis Hive.
  void _chargerNotifications() {
    _notifications.value = _service.toutesLesNotifications();
    _nombreNonLues.value = _service.nombreNonLues;
  }

  // ── Actions utilisateur ────────────────────────────────────────

  /// Marque une notification comme lue.
  Future<void> marquerCommeLue(String id) async {
    await _service.marquerCommeLue(id);
    _chargerNotifications();
  }

  /// Marque toutes les notifications comme lues.
  Future<void> toutMarquerCommeLu() async {
    await _service.toutMarquerCommeLu();
    _chargerNotifications();
  }

  /// Supprime une notification.
  Future<void> supprimerNotification(String id) async {
    await _service.supprimerNotification(id);
    _chargerNotifications();
  }

  /// Supprime toutes les notifications.
  Future<void> toutSupprimer() async {
    await _service.toutSupprimer();
    _chargerNotifications();
  }

  // ── Génération automatique ─────────────────────────────────────

  /// Vérifie et génère les notifications nécessaires.
  ///
  /// Appelée après chaque ajout/modification d'opération
  /// et au démarrage de l'app.
  Future<void> verifierEtGenerer() async {
    _estEnChargement.value = true;
    try {
      // Recharger la devise en cas de changement
      _chargerDevise();

      await _service.verifierEtGenerer(
        devise: _devise.value,
      );

      // Recharger les notifications après génération
      _chargerNotifications();
    } catch (e) {
      debugPrint('❌ NotificationController: erreur → $e');
    } finally {
      _estEnChargement.value = false;
    }
  }

  /// Rafraîchit les notifications.
  Future<void> rafraichir() async {
    await verifierEtGenerer();
  }

  // ── Getters utiles ─────────────────────────────────────────────

  /// Notifications non lues uniquement.
  List<NotificationModel> get nonLues =>
      _notifications.where((n) => !n.estLue).toList();

  /// Notifications lues uniquement.
  List<NotificationModel> get lues =>
      _notifications.where((n) => n.estLue).toList();

  /// Vrai si aucune notification.
  bool get estVide => _notifications.isEmpty;
}