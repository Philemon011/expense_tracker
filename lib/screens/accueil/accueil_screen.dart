import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/operation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../widgets/loading_skeleton.dart';
import '../operations/ajouter_operation_screen.dart';
import 'widgets/card_solde.dart';
import 'widgets/card_resume.dart';
import 'widgets/graphique_donut.dart';
import 'widgets/liste_operations_recentes.dart';

/// Écran d'accueil — Dashboard principal.
///
/// Structure :
///   - Header (Bonjour + icône notif)
///   - CardSolde (solde total + navigation mois)
///   - CardResume (3 indicateurs clés)
///   - GraphiqueDonut (dépenses par catégorie)
///   - ListeOperationsRecentes (5 dernières opérations)
///   - FAB (ajout rapide d'opération)
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),

        // ── Corps principal ──────────────────────────────────────
        body: ctrl.estEnChargement
            // Skeleton pendant le chargement
            ? const SafeArea(child: SkeletonDashboard())
            // Contenu réel
            : SafeArea(
                child: RefreshIndicator(
                  // Pull to refresh
                  onRefresh: ctrl.rafraichir,
                  color: AppColors.primary,
                  backgroundColor: AppColors.card(isDark),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [

                      // ── Header ─────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: _Header(
                            nomUtilisateur: ctrl.nomUtilisateur,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // ── Card Solde ──────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.xxl,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: const CardSolde(),
                        ),
                      ),

                      // ── Card Résumé ─────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.md,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: const CardResume(),
                        ),
                      ),

                      // ── Graphique Donut ─────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.xxl,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: const GraphiqueDonut(),
                        ),
                      ),

                      // ── Opérations récentes ─────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingHorizontal,
                            AppSpacing.xxl,
                            AppSpacing.pagePaddingHorizontal,
                            0,
                          ),
                          child: const ListeOperationsRecentes(),
                        ),
                      ),

                      // ── Espace bas de page ──────────────────────
                      // Évite que le FAB cache le dernier élément
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ),

        // ── FAB — Ajout rapide ───────────────────────────────────
        floatingActionButton: _FabAjout(isDark: isDark),
      );
    });
  }
}

// ── Header ─────────────────────────────────────────────────────────

/// Header du dashboard avec salutation et icône notification.
class _Header extends StatelessWidget {
  const _Header({
    required this.nomUtilisateur,
    required this.isDark,
  });

  final String nomUtilisateur;
  final bool isDark;

  /// Retourne la salutation selon l'heure du jour
  String get _salutation {
    final heure = DateTime.now().hour;
    if (heure < 12) return 'Bonjour';
    if (heure < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // ── Salutation ────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _salutation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              nomUtilisateur,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400))
            .slideX(
              begin: -0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            ),

        // ── Icône notification ────────────────────────────────
        _BoutonNotification(isDark: isDark)
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400))
            .slideX(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}

// ── Bouton Notification ────────────────────────────────────────────

/// Bouton de notification avec badge.
class _BoutonNotification extends StatelessWidget {
  const _BoutonNotification({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Future feature — notifications
        context.snackbarInfo('Aucune nouvelle notification');
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          boxShadow: AppSpacing.cardShadow(isDark),
        ),
        child: Stack(
          children: [
            // Icône cloche
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 22,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            // Badge point vert
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAB Ajout rapide ───────────────────────────────────────────────

/// Bouton flottant pour ajouter une opération rapidement.
class _FabAjout extends StatelessWidget {
  const _FabAjout({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.to(
          () => const AjouterOperationScreen(),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 400),
        );
      },
      backgroundColor: AppColors.primary,
      elevation: 4,
      // Icône + label
      icon: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 22,
      ),
      label: const Text(
        'Ajouter',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.5,
          end: 0,
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }
}