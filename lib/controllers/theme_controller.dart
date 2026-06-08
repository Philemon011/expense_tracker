import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

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
    // Écouter les changements de mode système en temps réel
  _ecouterModeSysteme();
  }

  // ── Méthodes publiques ─────────────────────────────────────────


  /// Écoute les changements de mode système (dark/light).
///
/// Si l'utilisateur n'a pas de préférence sauvegardée,
/// l'app suit automatiquement le mode système.
void _ecouterModeSysteme() {
  SchedulerBinding.instance.platformDispatcher
      .onPlatformBrightnessChanged = () {
    // Ne rien faire si l'utilisateur a une préférence sauvegardée
    final box = Hive.box(_boxName);
    if (box.containsKey(_themeKey)) return;

    // Suivre le mode système
    final modeSysteme = SchedulerBinding
        .instance.platformDispatcher.platformBrightness;
    final isDarkSysteme = modeSysteme == Brightness.dark;
    setTheme(isDark: isDarkSysteme);
  };
}

  /// Bascule entre le mode clair et le mode sombre.
void toggleTheme() {
  _isDark.value = !_isDark.value;

  // Appliquer le thème dans toute l'app
  Get.changeThemeMode(
    _isDark.value ? ThemeMode.dark : ThemeMode.light,
  );

  // Mettre à jour la status bar
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          _isDark.value ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          _isDark.value ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          _isDark.value ? Brightness.light : Brightness.dark,
    ),
  );

  // Sauvegarder le choix
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

    // Vérifier si l'utilisateur a déjà défini une préférence
    final aDejaSauvegarde = box.containsKey(_themeKey);

    if (aDejaSauvegarde) {
      // Utiliser la préférence sauvegardée dans l'app
      final savedIsDark = box.get(_themeKey) as bool;
      setTheme(isDark: savedIsDark);
    } else {
      // Première utilisation — suivre le mode système du téléphone
      final modeSysteme = SchedulerBinding
          .instance.platformDispatcher.platformBrightness;
      final isDarkSysteme = modeSysteme == Brightness.dark;
      setTheme(isDark: isDarkSysteme);
    }
  } catch (e) {
    debugPrint('ThemeController: erreur chargement thème → $e');
    // Fallback — mode clair
    setTheme(isDark: false);
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