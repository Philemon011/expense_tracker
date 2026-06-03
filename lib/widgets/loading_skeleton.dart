import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_colors.dart';
import '../themes/app_spacing.dart';
import '../utils/extensions.dart';

/// Bloc skeleton de base — rectangle animé.
///
/// Utilisé pour construire des skeletons complexes.
///
/// Utilisation :
///   SkeletonBloc(width: 200, height: 20)
///   SkeletonBloc(width: double.infinity, height: 16, rayon: 8)
class SkeletonBloc extends StatelessWidget {
  const SkeletonBloc({
    super.key,
    this.width,
    required this.height,
    this.rayon = 8,
  });

  /// Largeur du bloc — null = prend toute la largeur
  final double? width;

  /// Hauteur du bloc
  final double height;

  /// Rayon des coins
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Couleur de base du skeleton selon le thème
    final couleurBase = isDark
        ? const Color(0xFF2D3144)
        : const Color(0xFFE5E7EB);

    // Couleur de brillance (shimmer)
    final couleurShimmer = isDark
        ? const Color(0xFF3D4460)
        : const Color(0xFFF3F4F6);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: couleurBase,
        borderRadius: BorderRadius.circular(rayon),
      ),
    )
    // Animation shimmer — la brillance se déplace de gauche à droite
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(
      duration: const Duration(milliseconds: 1200),
      color: couleurShimmer,
      angle: 0.2,
    );
  }
}

// ── Skeleton Dashboard ─────────────────────────────────────────────

/// Skeleton de l'écran d'accueil (dashboard).
///
/// Reproduit la structure du dashboard pendant le chargement :
///   - Carte solde principal
///   - Résumé revenus/dépenses
///   - Liste des opérations récentes
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBloc(width: 120, height: 14),
                  const SizedBox(height: 6),
                  const SkeletonBloc(width: 180, height: 22),
                ],
              ),
              const Spacer(),
              // Avatar notification
              const SkeletonBloc(
                width: 40,
                height: 40,
                rayon: 20,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Carte solde ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingCardLarge,
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF2D3144)
                  : const Color(0xFFE5E7EB),
              borderRadius: AppSpacing.borderRadiusCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBloc(width: 100, height: 14),
                const SizedBox(height: 12),
                const SkeletonBloc(width: 220, height: 40),
                const SizedBox(height: 20),
                // Résumé revenus/dépenses
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBloc(width: 80, height: 12),
                          SizedBox(height: 6),
                          SkeletonBloc(
                            width: double.infinity,
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBloc(width: 80, height: 12),
                          SizedBox(height: 6),
                          SkeletonBloc(
                            width: double.infinity,
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Titre section opérations récentes ───────────────
          const SkeletonBloc(width: 160, height: 18),

          const SizedBox(height: AppSpacing.md),

          // ── Liste opérations ─────────────────────────────────
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: const SkeletonOperationTile(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Operation Tile ────────────────────────────────────────

/// Skeleton d'un élément de liste d'opération.
///
/// Reproduit la structure d'un OperationTile :
///   - Icône catégorie (cercle)
///   - Nom + catégorie (deux lignes)
///   - Montant aligné à droite
class SkeletonOperationTile extends StatelessWidget {
  const SkeletonOperationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingListItem,
      decoration: BoxDecoration(
        color: AppColors.card(context.isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(context.isDark),
      ),
      child: Row(
        children: [

          // Icône catégorie — cercle
          const SkeletonBloc(
            width: AppSpacing.listIconSize,
            height: AppSpacing.listIconSize,
            rayon: AppSpacing.radiusIcon,
          ),

          const SizedBox(width: AppSpacing.md),

          // Nom + catégorie
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBloc(width: 140, height: 14),
                SizedBox(height: 6),
                SkeletonBloc(width: 90, height: 12),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Montant + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              SkeletonBloc(width: 80, height: 14),
              SizedBox(height: 6),
              SkeletonBloc(width: 50, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Liste générique ───────────────────────────────────────

/// Skeleton générique pour une liste d'éléments.
///
/// Affiche N éléments skeleton identiques.
///
/// Utilisation :
///   SkeletonListe(nombreElements: 5)
class SkeletonListe extends StatelessWidget {
  const SkeletonListe({
    super.key,
    this.nombreElements = 5,
  });

  /// Nombre d'éléments skeleton à afficher
  final int nombreElements;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: nombreElements,
      separatorBuilder: (_, __) => const SizedBox(
        height: AppSpacing.sm,
      ),
      itemBuilder: (_, __) => const SkeletonOperationTile(),
    );
  }
}

// ── Skeleton Carte statistique ─────────────────────────────────────

/// Skeleton d'une carte de statistique (graphique).
///
/// Reproduit la structure d'une carte avec graphique :
///   - Titre
///   - Zone graphique
class SkeletonCarteStatistique extends StatelessWidget {
  const SkeletonCarteStatistique({
    super.key,
    this.hauteur = 200,
  });

  /// Hauteur de la zone graphique
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.card(context.isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(context.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Titre + période
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonBloc(width: 130, height: 16),
              SkeletonBloc(width: 80, height: 14),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Zone graphique
          SkeletonBloc(
            width: double.infinity,
            height: hauteur,
            rayon: AppSpacing.radiusSmall,
          ),
        ],
      ),
    );
  }
}