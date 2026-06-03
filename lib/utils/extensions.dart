import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import 'formatters.dart';

// ── Extensions sur DateTime ────────────────────────────────────────

extension DateTimeExtension on DateTime {

  /// Vrai si la date est aujourd'hui
  ///
  /// Exemple : DateTime.now().estAujourdhui → true
  bool get estAujourdhui {
    final now = DateTime.now();
    return day == now.day &&
        month == now.month &&
        year == now.year;
  }

  /// Vrai si la date était hier
  bool get estHier {
    final hier = DateTime.now().subtract(const Duration(days: 1));
    return day == hier.day &&
        month == hier.month &&
        year == hier.year;
  }

  /// Vrai si la date est dans le mois courant
  bool get estCeMois {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  /// Vrai si la date est dans l'année courante
  bool get estCetteAnnee {
    return year == DateTime.now().year;
  }

  /// Retourne uniquement la partie date (sans l'heure)
  ///
  /// Exemple : DateTime(2026, 6, 3, 14, 35) → DateTime(2026, 6, 3)
  DateTime get dateUniquement => DateTime(year, month, day);

  /// Retourne le premier jour du mois
  DateTime get premierJourDuMois => DateTime(year, month, 1);

  /// Retourne le dernier jour du mois
  DateTime get dernierJourDuMois => DateTime(year, month + 1, 0);

  /// Formate la date en relatif — "Aujourd'hui", "Hier", "3 juin"
  String get relatif => Formatters.dateRelative(this);

  /// Formate la date en court — "03 juin"
  String get court => Formatters.dateCourte(this);

  /// Formate la date en complet — "lundi 3 juin 2026"
  String get complet => Formatters.dateComplete(this);

  /// Formate la date en mois + année — "Juin 2026"
  String get moisEtAnnee => Formatters.moisAnnee(this);

  /// Vrai si deux dates sont le même jour
  bool memeJourQue(DateTime autre) {
    return day == autre.day &&
        month == autre.month &&
        year == autre.year;
  }
}

// ── Extensions sur double ──────────────────────────────────────────

extension DoubleExtension on double {

  /// Formate le montant avec la devise donnée
  ///
  /// Exemple : 1250000.0.formате('FCFA') → "1 250 000 FCFA"
  String formate(String devise) => Formatters.montant(this, devise);

  /// Formate le montant en compact
  ///
  /// Exemple : 1250000.0.compact → "1,25M"
  String get compact => Formatters.montantCompact(this);

  /// Formate en pourcentage
  ///
  /// Exemple : 0.75.enPourcentage → "75%"
  String get enPourcentage => Formatters.pourcentage(this);

  /// Vrai si le montant est positif (> 0)
  bool get estPositif => this > 0;

  /// Vrai si le montant est négatif (< 0)
  bool get estNegatif => this < 0;

  /// Arrondit à 2 décimales
  double get arrondi2 => double.parse(toStringAsFixed(2));

  /// Retourne la valeur absolue
  double get absolu => abs();
}

// ── Extensions sur String ──────────────────────────────────────────

extension StringExtension on String {

  /// Met la première lettre en majuscule
  ///
  /// Exemple : "alimentation".capitalisé → "Alimentation"
  String get capitalise {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Vrai si la chaîne est vide ou ne contient que des espaces
  bool get estVide => trim().isEmpty;

  /// Vrai si la chaîne n'est pas vide
  bool get nEstPasVide => trim().isNotEmpty;

  /// Tronque la chaîne à une longueur maximale avec "..."
  ///
  /// Exemple : "Alimentation courses".tronque(10) → "Alimentati..."
  String tronque(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Vrai si la chaîne représente un nombre valide
  bool get estUnNombre => double.tryParse(this) != null;

  /// Convertit en double — retourne 0.0 si invalide
  double get enDouble => double.tryParse(this) ?? 0.0;
}

// ── Extensions sur BuildContext ────────────────────────────────────

extension BuildContextExtension on BuildContext {

  // ── Thème ──────────────────────────────────────────────────────

  /// Vrai si le mode sombre est actif
  ///
  /// Exemple : context.isDark → true / false
  bool get isDark =>
      Theme.of(this).brightness == Brightness.dark;

  /// Raccourci vers le ThemeData
  ThemeData get theme => Theme.of(this);

  /// Raccourci vers le ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ── Couleurs rapides ───────────────────────────────────────────

  /// Couleur de fond selon le thème actuel
  Color get couleurFond => AppColors.background(isDark);

  /// Couleur de carte selon le thème actuel
  Color get couleurCarte => AppColors.card(isDark);

  /// Couleur de texte principal selon le thème actuel
  Color get couleurTexte => AppColors.textPrimary(isDark);

  /// Couleur de texte secondaire selon le thème actuel
  Color get couleurTexteSecondaire => AppColors.textSecondary(isDark);

  /// Couleur de bordure selon le thème actuel
  Color get couleurBordure => AppColors.border(isDark);

  // ── Styles de texte rapides ────────────────────────────────────

  /// Style H1 selon le thème actuel
  TextStyle get styleH1 => AppTextStyles.h1(isDark);

  /// Style H2 selon le thème actuel
  TextStyle get styleH2 => AppTextStyles.h2(isDark);

  /// Style H3 selon le thème actuel
  TextStyle get styleH3 => AppTextStyles.h3(isDark);

  /// Style body large selon le thème actuel
  TextStyle get styleBody => AppTextStyles.bodyLarge(isDark);

  /// Style body medium selon le thème actuel
  TextStyle get styleBodyMedium => AppTextStyles.bodyMedium(isDark);

  // ── Dimensions ─────────────────────────────────────────────────

  /// Largeur de l'écran
  double get largeur => MediaQuery.of(this).size.width;

  /// Hauteur de l'écran
  double get hauteur => MediaQuery.of(this).size.height;

  /// Padding système (notch, barre de navigation...)
  EdgeInsets get paddingSysteme => MediaQuery.of(this).padding;

  // ── Navigation ─────────────────────────────────────────────────

  /// Ferme l'écran actuel
  void retour() => Navigator.of(this).pop();

  // ── Snackbars ──────────────────────────────────────────────────

  /// Affiche un snackbar de succès
  ///
  /// Exemple : context.snackbarSucces('Opération ajoutée')
  void snackbarSucces(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Affiche un snackbar d'erreur
  void snackbarErreur(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.alerte,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un snackbar d'information
  void snackbarInfo(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.entree,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation
  ///
  /// Retourne true si l'utilisateur confirme, false sinon.
  Future<bool> confirmer({
    required String titre,
    required String message,
    String texteBoutonConfirmer = 'Confirmer',
    String texteBoutonAnnuler = 'Annuler',
  }) async {
    final resultat = await showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(titre),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              texteBoutonAnnuler,
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              texteBoutonConfirmer,
              style: const TextStyle(
                color: AppColors.alerte,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return resultat ?? false;
  }
}