import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/operation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/formatters.dart';
import '../../../utils/extensions.dart';

/// Carte de résumé rapide du mois.
///
/// Affiche 3 indicateurs clés en mini-cartes :
///   - Nombre d'opérations du mois
///   - Plus grosse dépense du mois
///   - Moyenne journalière des dépenses
class CardResume extends StatelessWidget {
  const CardResume({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final devise = ctrl.devise;
      final operations = ctrl.operationsDuMois;

      // ── Calculs des indicateurs ────────────────────────────────

      // Nombre total d'opérations du mois
      final nombreOperations = operations.length;

      // Plus grosse dépense du mois
      final sorties = operations.where((op) => op.estSortie).toList();
      final plusGrosseSortie = sorties.isEmpty
          ? 0.0
          : sorties
              .map((op) => op.montant)
              .reduce((a, b) => a > b ? a : b);

      // Moyenne journalière des dépenses
      // Basée sur le nombre de jours écoulés dans le mois
      final now = DateTime.now();
      final joursEcoules = ctrl.estMoisCourant
          ? now.day
          : DateTime(
              ctrl.anneeSelectionnee,
              ctrl.moisSelectionne + 1,
              0,
            ).day;

      final moyenneJournaliere = joursEcoules > 0
          ? ctrl.totalSortiesMois / joursEcoules
          : 0.0;

      // ── Données des indicateurs ────────────────────────────────
      final indicateurs = [
        _IndicateurData(
          icone: Icons.receipt_long_rounded,
          couleur: AppColors.primary,
          couleurFond: AppColors.primaryLight,
          label: 'Opérations',
          valeur: nombreOperations.toString(),
          unite: 'ce mois',
        ),
        _IndicateurData(
          icone: Icons.arrow_upward_rounded,
          couleur: AppColors.sortie,
          couleurFond: AppColors.sortieLight,
          label: 'Plus grosse',
          valeur: Formatters.montantCompact(plusGrosseSortie),
          unite: 'dépense',
        ),
        _IndicateurData(
          icone: Icons.today_rounded,
          couleur: AppColors.entree,
          couleurFond: AppColors.entreeLight,
          label: 'Moyenne',
          valeur: Formatters.montantCompact(moyenneJournaliere),
          unite: 'par jour',
        ),
      ];

      return Row(
        children: List.generate(
          indicateurs.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                // Espacement entre les cartes
                left: index == 0 ? 0 : AppSpacing.xs,
                right: index == indicateurs.length - 1
                    ? 0
                    : AppSpacing.xs,
              ),
              child: _MiniCard(
                data: indicateurs[index],
                isDark: isDark,
              )
                  // Animation en cascade — délai selon l'index
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    duration: const Duration(milliseconds: 400),
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: Duration(milliseconds: 100 * index),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Mini carte indicateur ──────────────────────────────────────────

/// Carte individuelle d'un indicateur.
class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.data,
    required this.isDark,
  });

  final _IndicateurData data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Icône ────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.couleurFond,
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
            ),
            child: Icon(
              data.icone,
              size: 18,
              color: data.couleur,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Valeur principale ─────────────────────────────────
          Text(
            data.valeur,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // ── Label ─────────────────────────────────────────────
          Text(
            data.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(isDark),
            ),
          ),

          // ── Unité ─────────────────────────────────────────────
          Text(
            data.unite,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(isDark).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Données d'un indicateur ────────────────────────────────────────

/// Données d'un indicateur de la card résumé.
class _IndicateurData {
  const _IndicateurData({
    required this.icone,
    required this.couleur,
    required this.couleurFond,
    required this.label,
    required this.valeur,
    required this.unite,
  });

  /// Icône de l'indicateur
  final IconData icone;

  /// Couleur de l'icône
  final Color couleur;

  /// Couleur de fond de l'icône
  final Color couleurFond;

  /// Label de l'indicateur
  final String label;

  /// Valeur principale affichée
  final String valeur;

  /// Unité ou précision de la valeur
  final String unite;
}