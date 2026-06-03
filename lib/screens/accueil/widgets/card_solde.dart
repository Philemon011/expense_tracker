import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/operation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/formatters.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/montant_display.dart';

/// Carte principale du dashboard affichant le solde total.
///
/// Contient :
///   - Navigation mois précédent/suivant
///   - Solde total animé
///   - Barre de progression entrées vs sorties
///   - Résumé revenus et dépenses du mois
class CardSolde extends StatelessWidget {
  const CardSolde({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final devise = ctrl.devise;
      final solde = ctrl.soldeTotal;
      final entrees = ctrl.totalEntreesMois;
      final sorties = ctrl.totalSortiesMois;
      final mois = ctrl.moisSelectionne;
      final annee = ctrl.anneeSelectionnee;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Dégradé vert premium
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              const Color(0xFF2D7A52),
            ],
          ),
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [

            // ── Cercles décoratifs glassmorphism ──────────────
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Contenu principal ─────────────────────────────
            Padding(
              padding: AppSpacing.paddingCardLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Navigateur de mois ─────────────────────
                  _NavigateurMois(
                    mois: mois,
                    annee: annee,
                    estMoisCourant: ctrl.estMoisCourant,
                    onPrecedent: ctrl.moisPrecedent,
                    onSuivant: ctrl.moisSuivant,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Label solde ────────────────────────────
                  Text(
                    'Solde total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // ── Montant principal ──────────────────────
                  MontantDisplay(
                    montant: solde,
                    devise: devise,
                    taille: TailleMontant.grand,
                    couleurPersonnalisee: Colors.white,
                    avecAnimation: true,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Barre progression entrées vs sorties ───
                  _BarreProgression(
                    entrees: entrees,
                    sorties: sorties,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Résumé entrées / sorties ───────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ColonneResume(
                          label: 'Revenus',
                          montant: entrees,
                          devise: devise,
                          icone: Icons.arrow_downward_rounded,
                          couleur: Colors.white,
                          couleurFond: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _ColonneResume(
                          label: 'Dépenses',
                          montant: sorties,
                          devise: devise,
                          icone: Icons.arrow_upward_rounded,
                          couleur: Colors.white,
                          couleurFond: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 500))
          .slideY(
            begin: 0.1,
            end: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
    });
  }
}

// ── Navigateur de mois ─────────────────────────────────────────────

/// Barre de navigation entre les mois.
class _NavigateurMois extends StatelessWidget {
  const _NavigateurMois({
    required this.mois,
    required this.annee,
    required this.estMoisCourant,
    required this.onPrecedent,
    required this.onSuivant,
  });

  final int mois;
  final int annee;
  final bool estMoisCourant;
  final VoidCallback onPrecedent;
  final VoidCallback onSuivant;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Bouton mois précédent
        _BoutonNavMois(
          icone: Icons.chevron_left_rounded,
          onTap: onPrecedent,
        ),

        // Mois et année affichés
        Text(
          '${Formatters.nomMois(mois)} $annee',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // Bouton mois suivant — désactivé si mois courant
        _BoutonNavMois(
          icone: Icons.chevron_right_rounded,
          onTap: estMoisCourant ? null : onSuivant,
          desactive: estMoisCourant,
        ),
      ],
    );
  }
}

/// Bouton de navigation entre les mois.
class _BoutonNavMois extends StatelessWidget {
  const _BoutonNavMois({
    required this.icone,
    required this.onTap,
    this.desactive = false,
  });

  final IconData icone;
  final VoidCallback? onTap;
  final bool desactive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(desactive ? 0.05 : 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        child: Icon(
          icone,
          color: Colors.white.withOpacity(desactive ? 0.3 : 1.0),
          size: 20,
        ),
      ),
    );
  }
}

// ── Barre de progression entrées vs sorties ────────────────────────

/// Barre visuelle montrant la proportion entrées/sorties.
class _BarreProgression extends StatelessWidget {
  const _BarreProgression({
    required this.entrees,
    required this.sorties,
  });

  final double entrees;
  final double sorties;

  @override
  Widget build(BuildContext context) {
    // Calculer la proportion entrées
    final total = entrees + sorties;
    final proportionEntrees = total > 0 ? entrees / total : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Barre de progression
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                // Partie entrées — blanc
                Expanded(
                  flex: (proportionEntrees * 100).round(),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                // Partie sorties — blanc transparent
                Expanded(
                  flex: ((1 - proportionEntrees) * 100).round(),
                  child: Container(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .scaleX(
              begin: 0,
              end: 1,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
            ),
      ],
    );
  }
}

// ── Colonne résumé revenus/dépenses ───────────────────────────────

/// Colonne affichant le total d'un type d'opération.
class _ColonneResume extends StatelessWidget {
  const _ColonneResume({
    required this.label,
    required this.montant,
    required this.devise,
    required this.icone,
    required this.couleur,
    required this.couleurFond,
  });

  final String label;
  final double montant;
  final String devise;
  final IconData icone;
  final Color couleur;
  final Color couleurFond;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // Icône
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: couleurFond,
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusSmall,
            ),
          ),
          child: Icon(icone, size: 16, color: couleur),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Label + montant
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.montant(montant, devise),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}