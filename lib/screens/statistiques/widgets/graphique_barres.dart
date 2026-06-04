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

/// Graphique en barres des revenus et dépenses par mois.
///
/// Affiche les 12 mois de l'année sélectionnée.
/// Barres côte à côte : bleu = revenus, orange = dépenses.
class GraphiqueBarres extends StatefulWidget {
  const GraphiqueBarres({super.key});

  @override
  State<GraphiqueBarres> createState() => _GraphiqueBarresState();
}

class _GraphiqueBarresState extends State<GraphiqueBarres> {

  /// Index du mois touché (-1 = aucun)
  int _moisTouche = -1;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StatistiqueController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final entreesParMois = ctrl.entreesParMois;
      final sortiesParMois = ctrl.sortiesParMois;
      final annee = ctrl.annee;

      // Valeur max pour l'axe Y
      final maxValeur = [
        ...entreesParMois.values,
        ...sortiesParMois.values,
      ].fold(0.0, (max, val) => val > max ? val : max);

      // Éviter division par zéro
      final maxY = maxValeur == 0 ? 100.0 : maxValeur * 1.2;

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

            // ── Header ──────────────────────────────────────────
            _HeaderGraphique(
              annee: annee,
              estAnneeCourante: ctrl.estAnneeCourante,
              onPrecedent: ctrl.anneePrecedente,
              onSuivant: ctrl.anneeSuivante,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Légende ──────────────────────────────────────────
            _Legende(isDark: isDark),

            const SizedBox(height: AppSpacing.lg),

            // ── Graphique ────────────────────────────────────────
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.spot == null) {
                          _moisTouche = -1;
                          return;
                        }
                        _moisTouche =
                            response.spot!.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.card(isDark),
                      tooltipRoundedRadius: AppSpacing.radiusSmall,
                      tooltipBorder: BorderSide(
                        color: AppColors.border(isDark),
                        width: 0.5,
                      ),
                      getTooltipItem: (group, groupIndex,
                          rod, rodIndex) {
                        final estEntree = rodIndex == 0;
                        final moisNom = Formatters.nomMoisCourt(
                          groupIndex + 1,
                        );
                        final montant = Formatters.montant(
                          rod.toY,
                          ctrl.devise,
                        );
                        return BarTooltipItem(
                          '$moisNom\n',
                          TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDark),
                          ),
                          children: [
                            TextSpan(
                              text: montant,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: estEntree
                                    ? AppColors.entree
                                    : AppColors.sortie,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    // Axe X — noms des mois
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final mois = value.toInt() + 1;
                          final estActif = mois == DateTime.now().month &&
                              ctrl.estAnneeCourante;
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.xs,
                            ),
                            child: Text(
                              Formatters.nomMoisCourt(mois),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: estActif
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: estActif
                                    ? AppColors.primary
                                    : AppColors.textSecondary(isDark),
                              ),
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    // Axe Y — masqué
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
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border(isDark),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  // Groupes de barres — un par mois
                  barGroups: List.generate(12, (index) {
                    final mois = index + 1;
                    final entrees = entreesParMois[mois] ?? 0;
                    final sorties = sortiesParMois[mois] ?? 0;
                    final estTouche = _moisTouche == index;
                    final estMoisActuel =
                        mois == DateTime.now().month &&
                            ctrl.estAnneeCourante;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        // Barre revenus — bleue
                        BarChartRodData(
                          toY: entrees,
                          color: AppColors.entree.withOpacity(
                            estTouche ? 1.0 : 0.75,
                          ),
                          width: estMoisActuel ? 8 : 6,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        // Barre dépenses — orange
                        BarChartRodData(
                          toY: sorties,
                          color: AppColors.sortie.withOpacity(
                            estTouche ? 1.0 : 0.75,
                          ),
                          width: estMoisActuel ? 8 : 6,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                      // Espacement entre les groupes
                      barsSpace: 2,
                    );
                  }),
                ),
                swapAnimationDuration:
                    const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),

            // ── Détail mois touché ───────────────────────────────
            if (_moisTouche >= 0)
              _DetailMois(
                mois: _moisTouche + 1,
                annee: annee,
                entrees: entreesParMois[_moisTouche + 1] ?? 0,
                sorties: sortiesParMois[_moisTouche + 1] ?? 0,
                devise: ctrl.devise,
                isDark: isDark,
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

// ── Header du graphique ────────────────────────────────────────────

/// Header avec navigation entre les années.
class _HeaderGraphique extends StatelessWidget {
  const _HeaderGraphique({
    required this.annee,
    required this.estAnneeCourante,
    required this.onPrecedent,
    required this.onSuivant,
    required this.isDark,
  });

  final int annee;
  final bool estAnneeCourante;
  final VoidCallback onPrecedent;
  final VoidCallback onSuivant;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Titre
        Text(
          'Revenus & Dépenses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),

        // Navigation année
        Row(
          children: [
            // Précédent
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

            // Année
            Text(
              '$annee',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Suivant — désactivé si année courante
            GestureDetector(
              onTap: estAnneeCourante ? null : onSuivant,
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
                  color: estAnneeCourante
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

// ── Légende ────────────────────────────────────────────────────────

/// Légende du graphique barres.
class _Legende extends StatelessWidget {
  const _Legende({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Revenus
        _ItemLegende(
          couleur: AppColors.entree,
          label: 'Revenus',
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.lg),
        // Dépenses
        _ItemLegende(
          couleur: AppColors.sortie,
          label: 'Dépenses',
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Item individuel de la légende.
class _ItemLegende extends StatelessWidget {
  const _ItemLegende({
    required this.couleur,
    required this.label,
    required this.isDark,
  });

  final Color couleur;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ],
    );
  }
}

// ── Détail mois ────────────────────────────────────────────────────

/// Détail du mois touché sur le graphique.
class _DetailMois extends StatelessWidget {
  const _DetailMois({
    required this.mois,
    required this.annee,
    required this.entrees,
    required this.sorties,
    required this.devise,
    required this.isDark,
  });

  final int mois;
  final int annee;
  final double entrees;
  final double sorties;
  final String devise;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final solde = entrees - sorties;
    final estPositif = solde >= 0;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.input(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Mois
          Text(
            '${Formatters.nomMois(mois)} $annee',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),

          // Revenus
          _ColonneDetail(
            label: 'Revenus',
            montant: entrees,
            devise: devise,
            couleur: AppColors.entree,
          ),

          // Dépenses
          _ColonneDetail(
            label: 'Dépenses',
            montant: sorties,
            devise: devise,
            couleur: AppColors.sortie,
          ),

          // Solde du mois
          _ColonneDetail(
            label: 'Solde',
            montant: solde.abs(),
            devise: devise,
            couleur: estPositif ? AppColors.primary : AppColors.alerte,
            prefixe: estPositif ? '+' : '-',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 200))
        .slideY(begin: 0.2, end: 0);
  }
}

/// Colonne de détail d'un mois.
class _ColonneDetail extends StatelessWidget {
  const _ColonneDetail({
    required this.label,
    required this.montant,
    required this.devise,
    required this.couleur,
    this.prefixe = '',
  });

  final String label;
  final double montant;
  final String devise;
  final Color couleur;
  final String prefixe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$prefixe${Formatters.montantCompact(montant)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: couleur,
          ),
        ),
      ],
    );
  }
}