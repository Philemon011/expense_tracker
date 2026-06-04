import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/extensions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import 'ajouter_budget_screen.dart';
import 'widgets/carte_budget.dart';

/// Écran de gestion des budgets mensuels.
///
/// Affiche :
///   - Navigation mois précédent/suivant
///   - Résumé progression globale
///   - Liste des budgets avec progression individuelle
///   - Bouton ajout nouveau budget
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BudgetController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),

        // ── AppBar ───────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: AppColors.background(isDark),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary(isDark),
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Budgets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          actions: [
            // Bouton ajout
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: GestureDetector(
                onTap: ctrl.categoriesDisponibles.isEmpty
                    ? null
                    : () => Get.to(
                          () => const AjouterBudgetScreen(),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 400),
                        ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ctrl.categoriesDisponibles.isEmpty
                        ? AppColors.input(isDark)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSmall,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: ctrl.categoriesDisponibles.isEmpty
                        ? AppColors.textSecondary(isDark)
                        : Colors.white,
                    size: 20,
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
                    children: const [
                      SkeletonCarteStatistique(hauteur: 100),
                      SizedBox(height: AppSpacing.md),
                      SkeletonListe(nombreElements: 3),
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

                      // ── Navigateur de mois ─────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: _NavigateurMois(
                            mois: ctrl.mois,
                            annee: ctrl.annee,
                            estMoisCourant: ctrl.estMoisCourant,
                            onPrecedent: ctrl.moisPrecedent,
                            onSuivant: ctrl.moisSuivant,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // ── Résumé global ──────────────────────────
                      if (ctrl.budgets.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pagePaddingHorizontal,
                              AppSpacing.md,
                              AppSpacing.pagePaddingHorizontal,
                              0,
                            ),
                            child: _ResumeGlobal(
                              ctrl: ctrl,
                              isDark: isDark,
                            ),
                          ),
                        ),

                      // ── Alertes ────────────────────────────────
                      if (ctrl.aDesBudgetsDepasses)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pagePaddingHorizontal,
                              AppSpacing.md,
                              AppSpacing.pagePaddingHorizontal,
                              0,
                            ),
                            child: _BanniereAlerte(
                              nombreDepasses:
                                  ctrl.budgetsDepasses.length,
                              isDark: isDark,
                            ),
                          ),
                        ),

                      // ── Liste des budgets ──────────────────────
                      ctrl.budgets.isEmpty
                          ? SliverFillRemaining(
                              child: EmptyState.budgets(
                                onAjouter:
                                    ctrl.categoriesDisponibles.isEmpty
                                        ? null
                                        : () => Get.to(
                                              () =>
                                                  const AjouterBudgetScreen(),
                                              transition:
                                                  Transition.downToUp,
                                              duration: const Duration(
                                                  milliseconds: 400),
                                            ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pagePaddingHorizontal,
                                AppSpacing.md,
                                AppSpacing.pagePaddingHorizontal,
                                100,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final budget = ctrl.budgets[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: CarteBudget(
                                        budget: budget,
                                        devise: ctrl.devise,
                                        delaiAnimation: Duration(
                                          milliseconds: 80 * index,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: ctrl.budgets.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

// ── Navigateur de mois ─────────────────────────────────────────────

class _NavigateurMois extends StatelessWidget {
  const _NavigateurMois({
    required this.mois,
    required this.annee,
    required this.estMoisCourant,
    required this.onPrecedent,
    required this.onSuivant,
    required this.isDark,
  });

  final int mois;
  final int annee;
  final bool estMoisCourant;
  final VoidCallback onPrecedent;
  final VoidCallback onSuivant;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Précédent
        GestureDetector(
          onTap: onPrecedent,
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
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ),

        // Mois + année
        Text(
          '${Formatters.nomMois(mois)} $annee',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),

        // Suivant
        GestureDetector(
          onTap: estMoisCourant ? null : onSuivant,
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
              Icons.chevron_right_rounded,
              color: estMoisCourant
                  ? AppColors.textSecondary(isDark).withOpacity(0.3)
                  : AppColors.textPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Résumé global ──────────────────────────────────────────────────

/// Carte résumé de la progression globale de tous les budgets.
class _ResumeGlobal extends StatelessWidget {
  const _ResumeGlobal({
    required this.ctrl,
    required this.isDark,
  });

  final BudgetController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final progression = ctrl.progressionGlobale;
    final couleur = progression >= 1.0
        ? AppColors.alerte
        : progression >= 0.75
            ? AppColors.sortie
            : AppColors.primary;

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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget global',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              Text(
                '${(progression * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: couleur,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Barre progression globale
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.input(isDark),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusFull,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: 10,
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progression.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: couleur,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Montants
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatters.montant(ctrl.totalDepense, ctrl.devise)} dépensés',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              Text(
                'sur ${Formatters.montant(ctrl.totalBudgets, ctrl.devise)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.1, end: 0);
  }
}

// ── Bannière alerte ────────────────────────────────────────────────

/// Bannière d'alerte si des budgets sont dépassés.
class _BanniereAlerte extends StatelessWidget {
  const _BanniereAlerte({
    required this.nombreDepasses,
    required this.isDark,
  });

  final int nombreDepasses;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.alerte.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusCard,
        border: Border.all(
          color: AppColors.alerte.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_rounded,
            color: AppColors.alerte,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$nombreDepasses budget${nombreDepasses > 1 ? 's' : ''} '
              'dépassé${nombreDepasses > 1 ? 's' : ''} ce mois',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.alerte,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .shake(duration: const Duration(milliseconds: 400));
  }
}