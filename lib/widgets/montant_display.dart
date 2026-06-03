import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/extensions.dart';

/// Tailles disponibles pour l'affichage du montant
enum TailleMontant { petit, moyen, grand }

/// Widget d'affichage d'un montant financier.
///
/// Gère automatiquement :
///   - Le formatage avec la devise
///   - La couleur selon le type (entrée/sortie/neutre)
///   - L'animation d'entrée
///   - Le signe +/- optionnel
///
/// Utilisations :
///   // Solde principal — grand, neutre
///   MontantDisplay(
///     montant: 1250000,
///     devise: 'FCFA',
///     taille: TailleMontant.grand,
///   )
///
///   // Montant entrée — moyen, coloré bleu
///   MontantDisplay(
///     montant: 500000,
///     devise: 'FCFA',
///     estEntree: true,
///     afficherSigne: true,
///   )
///
///   // Montant sortie — petit, coloré orange
///   MontantDisplay(
///     montant: 15000,
///     devise: 'FCFA',
///     estEntree: false,
///     taille: TailleMontant.petit,
///   )
class MontantDisplay extends StatelessWidget {
  const MontantDisplay({
    super.key,
    required this.montant,
    required this.devise,
    this.estEntree,
    this.afficherSigne = false,
    this.taille = TailleMontant.moyen,
    this.couleurPersonnalisee,
    this.avecAnimation = true,
    this.textAlign = TextAlign.start,
  });

  /// Valeur du montant à afficher (toujours positive)
  final double montant;

  /// Devise — ex: 'FCFA', 'EUR', 'USD'
  final String devise;

  /// Type d'opération :
  ///   true  → entrée (bleu)
  ///   false → sortie (orange)
  ///   null  → neutre (couleur texte normale)
  final bool? estEntree;

  /// Affiche le signe + ou - avant le montant
  final bool afficherSigne;

  /// Taille du texte : petit / moyen / grand
  final TailleMontant taille;

  /// Couleur personnalisée — écrase la couleur automatique
  final Color? couleurPersonnalisee;

  /// Active l'animation d'entrée (fadeIn + slideUp)
  final bool avecAnimation;

  /// Alignement du texte
  final TextAlign textAlign;

  // ── Couleur selon le type ──────────────────────────────────────

  Color _couleur(bool isDark) {
    // Couleur personnalisée prioritaire
    if (couleurPersonnalisee != null) return couleurPersonnalisee!;

    // Couleur selon le type d'opération
    if (estEntree == true) return AppColors.entree;
    if (estEntree == false) return AppColors.sortie;

    // Neutre — couleur texte principale
    return AppColors.textPrimary(isDark);
  }

  // ── Style selon la taille ──────────────────────────────────────

  TextStyle _style(bool isDark) {
    switch (taille) {
      case TailleMontant.grand:
        return AppTextStyles.montantPrincipal(isDark).copyWith(
          color: _couleur(isDark),
        );
      case TailleMontant.moyen:
        return AppTextStyles.montantMoyen(isDark).copyWith(
          color: _couleur(isDark),
        );
      case TailleMontant.petit:
        return AppTextStyles.montantPetit(
          isDark: isDark,
          isEntree: estEntree ?? true,
        ).copyWith(
          color: _couleur(isDark),
        );
    }
  }

  // ── Texte formaté ──────────────────────────────────────────────

  String get _texte {
    final montantFormate = Formatters.montant(montant, devise);

    if (!afficherSigne) return montantFormate;

    // Ajouter le signe si demandé
    if (estEntree == true) return '+ $montantFormate';
    if (estEntree == false) return '- $montantFormate';
    return montantFormate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final textWidget = Text(
      _texte,
      style: _style(isDark),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    // Sans animation — retourner directement
    if (!avecAnimation) return textWidget;

    // Avec animation — fadeIn + slide vers le haut
    return textWidget
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }
}

// ── Widget badge montant ───────────────────────────────────────────

/// Badge compact affichant un montant avec fond coloré.
///
/// Utilisé dans les listes d'opérations.
///
/// Exemple :
///   BadgeMontant(montant: 15000, estEntree: false, devise: 'FCFA')
///   → affiche "- 15 000 FCFA" sur fond orange clair
class BadgeMontant extends StatelessWidget {
  const BadgeMontant({
    super.key,
    required this.montant,
    required this.estEntree,
    required this.devise,
  });

  final double montant;
  final bool estEntree;
  final String devise;

  @override
  Widget build(BuildContext context) {
    final couleur = estEntree ? AppColors.entree : AppColors.sortie;
    final couleurFond = estEntree
        ? AppColors.entreeLight
        : AppColors.sortieLight;
    final signe = estEntree ? '+' : '-';
    final montantFormate = Formatters.montant(montant, devise);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: couleurFond,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$signe $montantFormate',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: couleur,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Widget résumé entrées/sorties ──────────────────────────────────

/// Affiche côte à côte le total des entrées et des sorties.
///
/// Utilisé sur le dashboard pour le résumé mensuel.
///
/// Exemple :
///   ResumeEntreesSorties(
///     totalEntrees: 1500000,
///     totalSorties: 850000,
///     devise: 'FCFA',
///   )
class ResumeEntreesSorties extends StatelessWidget {
  const ResumeEntreesSorties({
    super.key,
    required this.totalEntrees,
    required this.totalSorties,
    required this.devise,
  });

  final double totalEntrees;
  final double totalSorties;
  final String devise;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      children: [
        // ── Total entrées ──────────────────────────────────────
        Expanded(
          child: _ColonneResume(
            label: 'Revenus',
            montant: totalEntrees,
            devise: devise,
            estEntree: true,
            isDark: isDark,
          ),
        ),

        // Séparateur vertical
        Container(
          width: 1,
          height: 40,
          color: AppColors.border(isDark),
        ),

        // ── Total sorties ──────────────────────────────────────
        Expanded(
          child: _ColonneResume(
            label: 'Dépenses',
            montant: totalSorties,
            devise: devise,
            estEntree: false,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

/// Colonne individuelle du résumé entrées/sorties.
class _ColonneResume extends StatelessWidget {
  const _ColonneResume({
    required this.label,
    required this.montant,
    required this.devise,
    required this.estEntree,
    required this.isDark,
  });

  final String label;
  final double montant;
  final String devise;
  final bool estEntree;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final couleur = estEntree ? AppColors.entree : AppColors.sortie;
    final couleurFond = estEntree
        ? AppColors.entreeLight
        : AppColors.sortieLight;
    final icone = estEntree
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Label + icône
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: couleurFond,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, size: 14, color: couleur),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Montant
          MontantDisplay(
            montant: montant,
            devise: devise,
            estEntree: estEntree,
            taille: TailleMontant.petit,
            avecAnimation: true,
          ),
        ],
      ),
    );
  }
}