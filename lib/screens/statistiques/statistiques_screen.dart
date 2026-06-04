import 'package:expense_tracker/screens/statistiques/budgets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/statistique_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/extensions.dart';
import '../../widgets/loading_skeleton.dart';
import 'widgets/graphique_barres.dart';
import 'widgets/graphique_courbe.dart';

/// Écran des statistiques financières.
///
/// Structure :
///   - Cartes comparatifs (revenus vs mois précédent)
///   - Graphique barres (revenus/dépenses par mois)
///   - Graphique courbe (évolution du solde)
class StatistiquesScreen extends StatelessWidget {
  const StatistiquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StatistiqueController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),

        // ── AppBar ───────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: AppColors.background(isDark),
          elevation: 0,
          title: Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          actions: [
            // Bouton budgets
Padding(
  padding: const EdgeInsets.only(right: AppSpacing.sm),
  child: GestureDetector(
    onTap: () => Get.to(
      () => const BudgetsScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    ),
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(
          AppSpacing.radiusSmall,
        ),
        boxShadow: AppSpacing.cardShadow(isDark),
      ),
      child: const Icon(
        Icons.savings_rounded,
        size: 18,
        color: AppColors.primary,
      ),
    ),
  ),
),
            // Bouton rafraîchir
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: GestureDetector(
                onTap: ctrl.rafraichir,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSmall,
                    ),
                    boxShadow: AppSpacing.cardShadow(isDark),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Corps ────────────────────────────────────────────────
        body: ctrl.estEnChargement
            ? SafeArea(
                child: Padding(
                  padding: AppSpacing.paddingPage,
                  child: Column(
                    children: [
                      const SkeletonCarteStatistique(hauteur: 120),
                      const SizedBox(height: AppSpacing.md),
                      const SkeletonCarteStatistique(hauteur: 260),
                      const SizedBox(height: AppSpacing.md),
                      const SkeletonCarteStatistique(hauteur: 280),
                    ],
                  ),
                ),
              )
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: ctrl.rafraichir,
                  color: AppColors.primary,
                  backgroundColor: AppColors.card(isDark),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [

                      // ── Cartes comparatifs ─────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: _CartesComparatifs(
                            ctrl: ctrl,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // ── Graphique barres ───────────────────────
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.xxl,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: GraphiqueBarres(),
                        ),
                      ),

                      // ── Graphique courbe ───────────────────────
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: GraphiqueCourbe(),
                        ),
                      ),

                      // ── Espace bas ─────────────────────────────
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

// ── Cartes comparatifs ─────────────────────────────────────────────

/// Section des cartes de comparatifs mois/mois.
class _CartesComparatifs extends StatelessWidget {
  const _CartesComparatifs({
    required this.ctrl,
    required this.isDark,
  });

  final StatistiqueController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // Carte revenus
        Expanded(
          child: _CarteComparatif(
            label: 'Revenus',
            montant: ctrl.totalEntreesMois,
            variation: ctrl.variationRevenus,
            devise: ctrl.devise,
            couleur: AppColors.entree,
            couleurFond: AppColors.entreeLight,
            icone: Icons.arrow_downward_rounded,
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: 0.2, end: 0),
        ),

        const SizedBox(width: AppSpacing.md),

        // Carte dépenses
        Expanded(
          child: _CarteComparatif(
            label: 'Dépenses',
            montant: ctrl.totalSortiesMois,
            variation: ctrl.variationDepenses,
            devise: ctrl.devise,
            couleur: AppColors.sortie,
            couleurFond: AppColors.sortieLight,
            icone: Icons.arrow_upward_rounded,
            isDark: isDark,
          )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
              )
              .slideY(
                begin: 0.2,
                end: 0,
                delay: const Duration(milliseconds: 100),
              ),
        ),
      ],
    );
  }
}

// ── Carte comparatif ───────────────────────────────────────────────

/// Carte affichant un total avec variation vs mois précédent.
class _CarteComparatif extends StatelessWidget {
  const _CarteComparatif({
    required this.label,
    required this.montant,
    required this.variation,
    required this.devise,
    required this.couleur,
    required this.couleurFond,
    required this.icone,
    required this.isDark,
  });

  final String label;
  final double montant;
  final double variation;
  final String devise;
  final Color couleur;
  final Color couleurFond;
  final IconData icone;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Couleur et icône de variation
    final estHausse = variation >= 0;

    // Pour les dépenses, une hausse est mauvaise
    final estBon = label == 'Revenus' ? estHausse : !estHausse;
    final couleurVariation =
        estBon ? AppColors.primary : AppColors.alerte;

    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Icône + label ──────────────────────────────────
          Row(
            children: [
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Montant ────────────────────────────────────────
          Text(
            Formatters.montantCompact(montant),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),

          Text(
            devise,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Variation vs mois précédent ────────────────────
          if (variation != 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: couleurVariation.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusFull,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    estHausse
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 12,
                    color: couleurVariation,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${estHausse ? '+' : ''}${variation.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: couleurVariation,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Pas de données précédentes',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary(isDark),
              ),
            ),
        ],
      ),
    );
  }
}