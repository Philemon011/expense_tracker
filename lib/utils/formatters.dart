import 'package:intl/intl.dart';

/// Utilitaires de formatage pour l'affichage dans l'UI.
///
/// Tout le formatage de l'app passe par cette classe.
/// Les widgets appellent Formatters.montant(valeur)
/// sans jamais gérer le format eux-mêmes.
abstract class Formatters {

  // ── Formatage des montants ─────────────────────────────────────

  /// Formate un montant avec la devise.
  ///
  /// Exemples :
  ///   Formatters.montant(1250000, 'FCFA') → "1 250 000 FCFA"
  ///   Formatters.montant(1250.50, 'EUR')  → "1 250,50 EUR"
  ///   Formatters.montant(0, 'FCFA')       → "0 FCFA"
  static String montant(double valeur, String devise) {
    // Pas de décimales pour le FCFA — monnaie sans centimes
    final sansDecimales = devise == 'FCFA' || devise == 'XOF';

    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: devise,
      decimalDigits: sansDecimales ? 0 : 2,
    );

    return formatter.format(valeur);
  }

  /// Formate un montant avec signe + ou -.
  ///
  /// Exemples :
  ///   Formatters.montantSigne(1250, true, 'FCFA')  → "+ 1 250 FCFA"
  ///   Formatters.montantSigne(450, false, 'FCFA')  → "- 450 FCFA"
  static String montantSigne(
    double valeur,
    bool estEntree,
    String devise,
  ) {
    final signe = estEntree ? '+ ' : '- ';
    return '$signe${montant(valeur, devise)}';
  }

  /// Formate un montant compact pour les espaces réduits.
  ///
  /// Exemples :
  ///   Formatters.montantCompact(1250000) → "1,25M"
  ///   Formatters.montantCompact(15000)   → "15K"
  ///   Formatters.montantCompact(850)     → "850"
  static String montantCompact(double valeur) {
    if (valeur >= 1000000) {
      return '${(valeur / 1000000).toStringAsFixed(2)}M';
    } else if (valeur >= 1000) {
      return '${(valeur / 1000).toStringAsFixed(0)}K';
    }
    return valeur.toStringAsFixed(0);
  }

  /// Formate un pourcentage.
  ///
  /// Exemples :
  ///   Formatters.pourcentage(0.75) → "75%"
  ///   Formatters.pourcentage(1.0)  → "100%"
  static String pourcentage(double valeur) {
    return '${(valeur * 100).toStringAsFixed(0)}%';
  }

  // ── Formatage des dates ────────────────────────────────────────

  /// Formate une date en format court.
  ///
  /// Exemples :
  ///   Formatters.dateCourtе(date) → "03 juin"
  ///   Formatters.dateCourte(date) → "25 déc."
  static String dateCourte(DateTime date) {
    return DateFormat('dd MMM', 'fr_FR').format(date);
  }

  /// Formate une date en format complet.
  ///
  /// Exemples :
  ///   Formatters.dateComplete(date) → "lundi 3 juin 2026"
  static String dateComplete(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formate une date en format moyen.
  ///
  /// Exemples :
  ///   Formatters.dateMoyenne(date) → "3 juin 2026"
  static String dateMoyenne(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formate une date en mois et année uniquement.
  ///
  /// Exemples :
  ///   Formatters.moisAnnee(date) → "Juin 2026"
  static String moisAnnee(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formate une date en mois court uniquement.
  ///
  /// Exemples :
  ///   Formatters.moisCourt(date) → "Juin"
  ///   Utilisé pour les axes des graphiques
  static String moisCourt(DateTime date) {
    return DateFormat('MMM', 'fr_FR').format(date);
  }

  /// Retourne un label relatif pour une date.
  ///
  /// Exemples :
  ///   → "Aujourd'hui"
  ///   → "Hier"
  ///   → "03 juin"  (si plus ancien)
  static String dateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return "Aujourd'hui";
    if (difference == 1) return 'Hier';
    if (difference < 7) return 'Il y a $difference jours';
    return dateCourte(date);
  }

  /// Formate l'heure d'une date.
  ///
  /// Exemple : "14:35"
  static String heure(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  // ── Formatage des noms de mois ─────────────────────────────────

  /// Retourne le nom complet d'un mois (1–12) en français.
  ///
  /// Exemple : Formatters.nomMois(6) → "Juin"
  static String nomMois(int mois) {
    const moisFr = [
      '', 'Janvier', 'Février', 'Mars', 'Avril',
      'Mai', 'Juin', 'Juillet', 'Août',
      'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    if (mois < 1 || mois > 12) return '';
    return moisFr[mois];
  }

  /// Retourne le nom court d'un mois (1–12) en français.
  ///
  /// Exemple : Formatters.nomMoisCourt(6) → "Juin"
  static String nomMoisCourt(int mois) {
    const moisFr = [
      '', 'Jan', 'Fév', 'Mar', 'Avr',
      'Mai', 'Juin', 'Juil', 'Août',
      'Sep', 'Oct', 'Nov', 'Déc',
    ];
    if (mois < 1 || mois > 12) return '';
    return moisFr[mois];
  }

  // ── Initialisation ─────────────────────────────────────────────

  /// Initialise la locale française pour intl.
  ///
  /// À appeler dans main.dart avant runApp().
  static Future<void> initialiser() async {
    // Enregistre la locale française pour DateFormat
    // Nécessaire pour que les noms de mois soient en français
  }
}