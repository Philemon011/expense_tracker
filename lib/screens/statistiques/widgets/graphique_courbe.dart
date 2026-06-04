import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/statistique_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/formatters.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/empty_state.dart';

/// Graphique courbe de l'évolution du solde.
///
/// Affiche l'évolution jour par jour du solde
/// sur le mois sélectionné.
class GraphiqueCourbe extends StatefulWidget {
  const GraphiqueCourbe({super.key});

  @override
  State<GraphiqueCourbe> createState() => _GraphiqueCourbeState();
}

class _GraphiqueCourbeState extends State<GraphiqueCourbe> {

  /// Index du point touché
  int _indexTouche = -1;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StatistiqueController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final evolution = ctrl.evolutionSolde;
      final mois = ctrl.mois;
      final annee = ctrl.annee;

      // Pas de données — état vide
      if (evolution.isEmpty) {
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
              _HeaderCourbe(
                mois: mois,
                annee: annee,
                isDark: isDark,
                onPrecedent: () => ctrl.changerMois(
                  mois == 1 ? 12 : mois - 1,
                ),
                onSuivant: () => ctrl.changerMois(
                  mois == 12 ? 1 : mois + 1,
                ),
                estMoisCourant: mois == DateTime.now().month &&
                    annee == DateTime.now().year,
              ),
              const SizedBox(height: AppSpacing.lg),
               SizedBox(
                height: 150,
                child: EmptyState.statistiques(),
              ),
            ],
          ),
        );
      }

      // Construire les points de la courbe
      final dates = evolution.keys.toList()..sort();
      final points = dates.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          evolution[entry.value]!,
        );
      }).toList();

      // Valeurs min/max pour les axes
      final valeurs = evolution.values.toList();
      final minY = valeurs.reduce((a, b) => a < b ? a : b);
      final maxY = valeurs.reduce((a, b) => a > b ? a : b);
      final ecart = maxY - minY;
      final minYAjuste = minY - (ecart * 0.1);
      final maxYAjuste = maxY + (ecart * 0.1);

      // Couleur de la courbe selon la tendance
      final estPositif = (evolution[dates.last] ?? 0) >=
          (evolution[dates.first] ?? 0);
      final couleurCourbe =
          estPositif ? AppColors.primary : AppColors.alerte;

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

            // ── Header avec sélecteur de mois ────────────────
            _HeaderCourbe(
              mois: mois,
              annee: annee,
              isDark: isDark,
              onPrecedent: () => ctrl.changerMois(
                mois == 1 ? 12 : mois - 1,
              ),
              onSuivant: () => ctrl.changerMois(
                mois == 12 ? 1 : mois + 1,
              ),
              estMoisCourant: mois == DateTime.now().month &&
                  annee == DateTime.now().year,
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Indicateur tendance ───────────────────────────
            _IndicateurTendance(
              soldeDebut: evolution[dates.first] ?? 0,
              soldeFin: evolution[dates.last] ?? 0,
              devise: ctrl.devise,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Graphique courbe ──────────────────────────────
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minYAjuste,
                  maxY: maxYAjuste,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.lineBarSpots == null) {
                          _indexTouche = -1;
                          return;
                        }
                        _indexTouche = response
                            .lineBarSpots!.first.spotIndex;
                      });
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.card(isDark),
                      tooltipRoundedRadius: AppSpacing.radiusSmall,
                      tooltipBorder: BorderSide(
                        color: AppColors.border(isDark),
                        width: 0.5,
                      ),
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final date = dates[spot.spotIndex];
                          return LineTooltipItem(
                            '${date.day} ${Formatters.nomMoisCourt(date.month)}\n',
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(isDark),
                            ),
                            children: [
                              TextSpan(
                                text: Formatters.montant(
                                  spot.y,
                                  ctrl.devise,
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: couleurCourbe,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    // Axe X — jours du mois
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (dates.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.xs,
                            ),
                            child: Text(
                              '${dates[index].day}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: ecart == 0
                        ? 100
                        : ecart / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border(isDark),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: couleurCourbe,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, index) {
                          final estTouche = index == _indexTouche;
                          return FlDotCirclePainter(
                            radius: estTouche ? 5 : 0,
                            color: couleurCourbe,
                            strokeWidth: 2,
                            strokeColor: AppColors.card(isDark),
                          );
                        },
                      ),
                      // Gradient sous la courbe
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            couleurCourbe.withOpacity(0.2),
                            couleurCourbe.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
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

// ── Header avec sélecteur de mois ─────────────────────────────────

/// Header du graphique courbe avec navigation mois.
class _HeaderCourbe extends StatelessWidget {
  const _HeaderCourbe({
    required this.mois,
    required this.annee,
    required this.isDark,
    required this.onPrecedent,
    required this.onSuivant,
    required this.estMoisCourant,
  });

  final int mois;
  final int annee;
  final bool isDark;
  final VoidCallback onPrecedent;
  final VoidCallback onSuivant;
  final bool estMoisCourant;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Titre
        Text(
          'Évolution du solde',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),

        // Navigation mois
        Row(
          children: [
            GestureDetector(
              onTap: onPrecedent,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.input(isDark),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSmall,
                  ),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${Formatters.nomMoisCourt(mois)} $annee',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: estMoisCourant ? null : onSuivant,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.input(isDark),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSmall,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: estMoisCourant
                      ? AppColors.textSecondary(isDark)
                          .withOpacity(0.3)
                      : AppColors.textPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Indicateur tendance ────────────────────────────────────────────

/// Affiche la variation du solde sur le mois.
class _IndicateurTendance extends StatelessWidget {
  const _IndicateurTendance({
    required this.soldeDebut,
    required this.soldeFin,
    required this.devise,
    required this.isDark,
  });

  final double soldeDebut;
  final double soldeFin;
  final String devise;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final variation = soldeFin - soldeDebut;
    final estPositif = variation >= 0;
    final couleur =
        estPositif ? AppColors.primary : AppColors.alerte;

    return Row(
      children: [

        // Solde actuel
        Text(
          Formatters.montant(soldeFin, devise),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Badge variation
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: couleur.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                estPositif
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: couleur,
              ),
              const SizedBox(width: 2),
              Text(
                Formatters.montantCompact(variation.abs()),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: couleur,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}