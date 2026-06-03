import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Contrôleur du thème (dark / light).
///
/// Utilisation dans un widget :
///   final themeCtrl = Get.find<ThemeController>();
///   bool isDark = themeCtrl.isDark;
///   themeCtrl.toggleTheme();
class ThemeController extends GetxController {

  // ── Constantes ─────────────────────────────────────────────────

  /// Nom de la boîte Hive pour les préférences
  static const String _boxName = 'preferences';

  /// Clé de stockage du thème dans Hive
  static const String _themeKey = 'isDark';

  // ── État réactif ───────────────────────────────────────────────

  /// Mode sombre activé ou non — observable par les widgets
  final _isDark = false.obs;

  /// Getter public — lit la valeur observable
  bool get isDark => _isDark.value;

  // ── Cycle de vie ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Charger le thème sauvegardé au démarrage
    _chargerThemeSauvegarde();
  }

  // ── Méthodes publiques ─────────────────────────────────────────

  /// Bascule entre le mode clair et le mode sombre.
  /// Sauvegarde automatiquement le choix dans Hive.
  void toggleTheme() {
    _isDark.value = !_isDark.value;
    // Appliquer le thème dans toute l'app via GetX
    Get.changeThemeMode(
      _isDark.value ? ThemeMode.dark : ThemeMode.light,
    );
    // Sauvegarder le choix pour la prochaine ouverture
    _sauvegarderTheme();
  }

  /// Force un thème spécifique.
  /// Utile pour initialiser depuis les préférences sauvegardées.
  void setTheme({required bool isDark}) {
    _isDark.value = isDark;
    Get.changeThemeMode(
      isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // ── Méthodes privées ───────────────────────────────────────────

  /// Charge le thème sauvegardé dans Hive.
  /// Si aucun thème n'est sauvegardé, utilise le mode clair par défaut.
  void _chargerThemeSauvegarde() {
    try {
      final box = Hive.box(_boxName);
      // false par défaut = mode clair au premier lancement
      final savedIsDark = box.get(_themeKey, defaultValue: false) as bool;
      setTheme(isDark: savedIsDark);
    } catch (e) {
      // En cas d'erreur, on reste en mode clair
      debugPrint('ThemeController: erreur chargement thème → $e');
    }
  }

  /// Sauvegarde le thème actuel dans Hive.
  void _sauvegarderTheme() {
    try {
      final box = Hive.box(_boxName);
      box.put(_themeKey, _isDark.value);
    } catch (e) {
      debugPrint('ThemeController: erreur sauvegarde thème → $e');
    }
  }
}