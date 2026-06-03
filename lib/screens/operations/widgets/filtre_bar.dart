import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/categorie_model.dart';
import '../../../models/operation_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';

/// Barre de filtres horizontale pour l'écran opérations.
///
/// Filtres disponibles :
///   - Type : Tous / Revenus / Dépenses
///   - Catégorie : liste horizontale des catégories
///
/// Utilisation :
///   FiltreBar(
///     typeFiltre: _typeFiltre,
///     categorieFiltree: _categorieFiltree,
///     categories: ctrl.categories,
///     isDark: isDark,
///     onTypeChanged: (type) => setState(() => _typeFiltre = type),
///     onCategorieChanged: (cat) => setState(() => _categorieFiltree = cat),
///   )
class FiltreBar extends StatelessWidget {
  const FiltreBar({
    super.key,
    required this.typeFiltre,
    required this.categorieFiltree,
    required this.categories,
    required this.isDark,
    required this.onTypeChanged,
    required this.onCategorieChanged,
    this.onReinitialiser,
  });

  /// Type actuellement filtré — null = tous
  final TypeOperation? typeFiltre;

  /// Id de la catégorie filtrée — null = toutes
  final String? categorieFiltree;

  /// Liste de toutes les catégories disponibles
  final List<CategorieModel> categories;

  final bool isDark;

  /// Callback quand le type change
  final ValueChanged<TypeOperation?> onTypeChanged;

  /// Callback quand la catégorie change
  final ValueChanged<String?> onCategorieChanged;

  /// Callback pour réinitialiser tous les filtres
  /// null = pas de bouton réinitialiser
  final VoidCallback? onReinitialiser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal,
        ),
        children: [

          // ── Filtre Tous ──────────────────────────────────────
          _ChipFiltre(
            label: 'Tous',
            icone: Icons.apps_rounded,
            estActif: typeFiltre == null && categorieFiltree == null,
            couleur: AppColors.primary,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onTypeChanged(null);
              onCategorieChanged(null);
            },
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Filtre Revenus ───────────────────────────────────
          _ChipFiltre(
            label: 'Revenus',
            icone: Icons.arrow_downward_rounded,
            estActif: typeFiltre == TypeOperation.entree,
            couleur: AppColors.entree,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              // Toggle — si déjà actif on désactive
              onTypeChanged(
                typeFiltre == TypeOperation.entree
                    ? null
                    : TypeOperation.entree,
              );
            },
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Filtre Dépenses ──────────────────────────────────
          _ChipFiltre(
            label: 'Dépenses',
            icone: Icons.arrow_upward_rounded,
            estActif: typeFiltre == TypeOperation.sortie,
            couleur: AppColors.sortie,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onTypeChanged(
                typeFiltre == TypeOperation.sortie
                    ? null
                    : TypeOperation.sortie,
              );
            },
          ),

          // ── Séparateur ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: VerticalDivider(
              color: AppColors.border(isDark),
              thickness: 1,
            ),
          ),

          // ── Filtres par catégorie ────────────────────────────
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            final estActif = categorieFiltree == cat.id;

            return Padding(
              padding: EdgeInsets.only(
                right: index == categories.length - 1
                    ? 0
                    : AppSpacing.sm,
              ),
              child: _ChipCategorie(
                categorie: cat,
                estActif: estActif,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  // Toggle — si déjà actif on désactive
                  onCategorieChanged(
                    estActif ? null : cat.id,
                  );
                },
              ),
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(
          begin: -0.05,
          end: 0,
          duration: const Duration(milliseconds: 300),
        );
  }
}

// ── Chip de filtre type ────────────────────────────────────────────

/// Chip pour filtrer par type (Tous / Revenus / Dépenses).
class _ChipFiltre extends StatelessWidget {
  const _ChipFiltre({
    required this.label,
    required this.icone,
    required this.estActif,
    required this.couleur,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icone;
  final bool estActif;
  final Color couleur;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: estActif
              ? couleur.withOpacity(0.12)
              : AppColors.card(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: estActif ? couleur : AppColors.border(isDark),
            width: estActif ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 14,
              color: estActif
                  ? couleur
                  : AppColors.textSecondary(isDark),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: estActif
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: estActif
                    ? couleur
                    : AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip de filtre catégorie ───────────────────────────────────────

/// Chip pour filtrer par catégorie.
///
/// Affiche l'icône et le nom de la catégorie.
class _ChipCategorie extends StatelessWidget {
  const _ChipCategorie({
    required this.categorie,
    required this.estActif,
    required this.isDark,
    required this.onTap,
  });

  final CategorieModel categorie;
  final bool estActif;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = categorie.couleur;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: estActif
              ? couleur.withOpacity(0.12)
              : AppColors.card(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: estActif ? couleur : AppColors.border(isDark),
            width: estActif ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône catégorie
            Icon(
              categorie.icone,
              size: 14,
              color: estActif
                  ? couleur
                  : AppColors.textSecondary(isDark),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Nom catégorie
            Text(
              categorie.nom,
              style: TextStyle(
                fontSize: 13,
                fontWeight: estActif
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: estActif
                    ? couleur
                    : AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}