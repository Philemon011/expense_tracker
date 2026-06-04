import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/compte_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import 'ajouter_compte_screen.dart';
import 'widgets/compte_card.dart';

/// Écran de gestion des comptes financiers.
///
/// Affiche :
///   - Solde total de tous les comptes
///   - Liste des comptes avec soldes individuels
///   - Bouton d'ajout de compte
///   - État vide si aucun compte
class ComptesScreen extends StatelessWidget {
  const ComptesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CompteController>();
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
            'Mes comptes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          actions: [
            // Bouton ajout compte
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: GestureDetector(
                onTap: () => Get.to(
                  () => const AjouterCompteScreen(),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 400),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSmall,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Corps ────────────────────────────────────────────────
        body: ctrl.estEnChargement
            ? const SafeArea(
                child: SkeletonListe(nombreElements: 3),
              )
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: ctrl.rafraichir,
                  color: AppColors.primary,
                  backgroundColor: AppColors.card(isDark),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [

                      // ── Carte solde total ──────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: _CarteSoldeTotal(
                            soldeTotal: ctrl.soldeTotal,
                            devise: ctrl.devise,
                            nombreComptes: ctrl.comptes.length,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // ── Titre section ──────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.xxl,
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.md,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tous les comptes',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              // Badge nombre de comptes
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  '${ctrl.comptes.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Liste des comptes ──────────────────────
                      ctrl.comptes.isEmpty
                          ? SliverFillRemaining(
                              child: EmptyState.comptes(
                                onAjouter: () => Get.to(
                                  () => const AjouterCompteScreen(),
                                  transition: Transition.downToUp,
                                  duration:
                                      const Duration(milliseconds: 400),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pagePaddingHorizontal,
                                0,
                                AppSpacing.pagePaddingHorizontal,
                                100,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final compte = ctrl.comptes[index];
                                    final solde =
                                        ctrl.soldeCompte(compte.id);

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: CompteCard(
                                        compte: compte,
                                        solde: solde,
                                        devise: ctrl.devise,
                                        delaiAnimation: Duration(
                                          milliseconds: 100 * index,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: ctrl.comptes.length,
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

// ── Carte solde total ──────────────────────────────────────────────

/// Carte affichant le solde total de tous les comptes.
class _CarteSoldeTotal extends StatelessWidget {
  const _CarteSoldeTotal({
    required this.soldeTotal,
    required this.devise,
    required this.nombreComptes,
    required this.isDark,
  });

  final double soldeTotal;
  final String devise;
  final int nombreComptes;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingCardLarge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Label
          Text(
            'Patrimoine total',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.75),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Montant
          Text(
            Formatters.montant(soldeTotal, devise),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Nombre de comptes
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 14,
                color: Colors.white70,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$nombreComptes compte${nombreComptes > 1 ? 's' : ''} actif${nombreComptes > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
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
  }
}