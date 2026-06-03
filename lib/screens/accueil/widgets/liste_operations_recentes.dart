import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/operation_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/empty_state.dart';
import '../../operations/ajouter_operation_screen.dart';
import 'operation_tile.dart';

/// Liste des 5 dernières opérations — section du dashboard.
///
/// Contient :
///   - Header avec titre et lien "Voir tout"
///   - Liste des 5 dernières opérations
///   - État vide si aucune opération
class ListeOperationsRecentes extends StatelessWidget {
  const ListeOperationsRecentes({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();
    final navCtrl = Get.find<NavigationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final operations = ctrl.operationsRecentes;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ─────────────────────────────────────────────
          _HeaderSection(
            isDark: isDark,
            nombreOperations: operations.length,
            onVoirTout: () => navCtrl.allerOperations(),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Contenu ────────────────────────────────────────────
          if (operations.isEmpty)
            // État vide
            EmptyState.operations(
              onAjouter: () => Get.to(
                () => const AjouterOperationScreen(),
                transition: Transition.downToUp,
                duration: const Duration(milliseconds: 400),
              ),
            )
          else
            // Liste des opérations
            Column(
              children: List.generate(
                operations.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.sm,
                  ),
                  child: OperationTile(
                    operation: operations[index],
                    // Animation en cascade
                    delaiAnimation: Duration(
                      milliseconds: 50 * index,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

// ── Header de la section ───────────────────────────────────────────

/// Header avec titre et bouton "Voir tout".
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.isDark,
    required this.nombreOperations,
    required this.onVoirTout,
  });

  final bool isDark;
  final int nombreOperations;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // ── Titre + compteur ───────────────────────────────────
        Row(
          children: [
            Text(
              'Opérations récentes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),

            // Badge compteur si > 0
            if (nombreOperations > 0) ...[
              const SizedBox(width: AppSpacing.sm),
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
                  nombreOperations.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400)),

        // ── Lien Voir tout ─────────────────────────────────────
        GestureDetector(
          onTap: onVoirTout,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400)),
      ],
    );
  }
}