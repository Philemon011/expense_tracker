/// Constantes globales de l'application.
///
/// Centralise tous les noms de boîtes Hive et autres
/// valeurs fixes utilisées dans toute l'app.
abstract class Constantes {

  // ── Noms des boîtes Hive ───────────────────────────────────────

  /// Boîte des préférences utilisateur (thème, devise...)
  static const String boxPreferences = 'preferences';

  /// Boîte des opérations (entrées et sorties)
  static const String boxOperations = 'operations';

  /// Boîte des catégories
  static const String boxCategories = 'categories';

  /// Boîte des comptes
  static const String boxComptes = 'comptes';

  /// Boîte des budgets
  static const String boxBudgets = 'budgets';

  // ── Clés de préférences ────────────────────────────────────────

  /// Clé du thème dans la boîte préférences
  static const String cleTheme = 'isDark';

  /// Clé de la devise dans la boîte préférences
  static const String cleDevise = 'devise';

  /// Clé du nom d'utilisateur
  static const String cleNomUtilisateur = 'nomUtilisateur';

  // ── Valeurs par défaut ─────────────────────────────────────────

  /// Devise par défaut
  static const String deviseDefaut = 'FCFA';

  /// Nom d'utilisateur par défaut
  static const String nomUtilisateurDefaut = 'Utilisateur';

  /// Boîte des notifications in-app
static const String boxNotifications = 'notifications';
}