import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/operation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/formatters.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/empty_state.dart';

/// Graphique donut des dépenses par catégorie.
///
/// Affiche la répartition des sorties du mois
/// sous forme de graphique circulaire avec légende.
class GraphiqueDonut extends StatefulWidget {
  const GraphiqueDonut({super.key});

  @override
  State<GraphiqueDonut> createState() => _GraphiqueDonutState();
}

class _GraphiqueDonutState extends State<GraphiqueDonut> {

  /// Index de la section touchée (-1 = aucune)
  int _indexTouche = -1;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final devise = ctrl.devise;
      final totauxParCategorie = ctrl.totauxParCategorie;

      // ── Construire les données du donut ────────────────────────

      // Filtrer les catégories avec montant > 0
      final donnees = totauxParCategorie.entries
          .where((e) => e.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Pas de données — afficher état vide
if (donnees.isEmpty) {
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
        _TitreSection(isDark: isDark),
        const SizedBox(height: AppSpacing.lg),
        // Remplacer SizedBox fixe par un padding simple
         Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: EmptyState.statistiques(),
        ),
      ],
    ),
  );
}

      // Couleurs pour les sections du donut
      final couleurs = _genererCouleurs(donnees.length, ctrl, isDark);

      // Total pour calculer les pourcentages
      final total = donnees.fold(0.0, (sum, e) => sum + e.value);

      // Construire les sections du donut
      final sections = List.generate(donnees.length, (index) {
        final estTouche = index == _indexTouche;
        final entry = donnees[index];
        final pourcentage = (entry.value / total * 100);

        return PieChartSectionData(
          value: entry.value,
          color: couleurs[index],
          // Section agrandie si touchée
          radius: estTouche ? 55 : 45,
          // Afficher le % si section touchée
          title: estTouche
              ? '${pourcentage.toStringAsFixed(1)}%'
              : '',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          // Espace entre les sections
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 2,
          ),
        );
      });

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

            // ── Titre de la section ──────────────────────────
            _TitreSection(isDark: isDark),

            const SizedBox(height: AppSpacing.lg),

            // ── Graphique + légende ──────────────────────────
            Row(
              children: [

                // Graphique donut
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      // Trou au centre
                      centerSpaceRadius: 35,
                      // Espacement entre sections
                      sectionsSpace: 2,
                      // Gestion du tap
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _indexTouche = -1;
                              return;
                            }
                            _indexTouche = response
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                    swapAnimationDuration:
                        const Duration(milliseconds: 300),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                ),

                const SizedBox(width: AppSpacing.lg),

                // Légende
                Expanded(
                  child: _Legende(
                    donnees: donnees,
                    couleurs: couleurs,
                    total: total,
                    devise: devise,
                    indexTouche: _indexTouche,
                    isDark: isDark,
                    ctrl: ctrl,
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
    });
  }

  /// Génère une liste de couleurs pour les sections.
  ///
  /// Utilise la couleur de la catégorie si disponible,
  /// sinon une couleur de la palette par défaut.
  List<Color> _genererCouleurs(
    int nombre,
    OperationController ctrl,
    bool isDark,
  ) {
    // Palette de couleurs de secours
    const palette = [
      Color(0xFF4CAF7A),
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFFF97316),
      Color(0xFF6366F1),
    ];

    return List.generate(nombre, (index) {
      return palette[index % palette.length];
    });
  }
}

// ── Titre de la section ────────────────────────────────────────────

class _TitreSection extends StatelessWidget {
  const _TitreSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dépenses par catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        // Badge "Ce mois"
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: const Text(
            'Ce mois',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Légende ────────────────────────────────────────────────────────

/// Légende du graphique donut.
///
/// Liste les catégories avec leur couleur et leur montant.
class _Legende extends StatelessWidget {
  const _Legende({
    required this.donnees,
    required this.couleurs,
    required this.total,
    required this.devise,
    required this.indexTouche,
    required this.isDark,
    required this.ctrl,
  });

  final List<MapEntry<String, double>> donnees;
  final List<Color> couleurs;
  final double total;
  final String devise;
  final int indexTouche;
  final bool isDark;
  final OperationController ctrl;

  @override
  Widget build(BuildContext context) {
    // Afficher max 5 catégories dans la légende
    final nombreAffiche = donnees.length > 5 ? 5 : donnees.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(nombreAffiche, (index) {
        final entry = donnees[index];
        final categorie = ctrl.categorieParId(entry.key);
        final nomCategorie = categorie?.nom ?? 'Autre';
        final pourcentage = entry.value / total * 100;
        final estTouche = index == indexTouche;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: estTouche ? AppSpacing.sm : 0,
              vertical: estTouche ? AppSpacing.xs : 0,
            ),
            decoration: BoxDecoration(
              color: estTouche
                  ? couleurs[index].withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Row(
              children: [

                // Indicateur couleur
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: couleurs[index],
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Nom catégorie
                Expanded(
                  child: Text(
                    nomCategorie,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: estTouche
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.textPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Pourcentage
                Text(
                  '${pourcentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: couleurs[index],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}