import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/operation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../models/operation_model.dart';
import '../../../models/categorie_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/custom_card.dart';
import '../../operations/ajouter_operation_screen.dart';

/// Élément individuel d'une opération dans une liste.
///
/// Affiche :
///   - Icône colorée de la catégorie
///   - Nom/note de l'opération
///   - Catégorie et date
///   - Montant coloré aligné à droite
///
/// Fonctionnalités :
///   - Tap → ouvre la modification
///   - Swipe gauche → supprime l'opération
///
/// Utilisation :
///   OperationTile(
///     operation: operation,
///     delaiAnimation: Duration(milliseconds: 100),
///   )
class OperationTile extends StatelessWidget {
  const OperationTile({
    super.key,
    required this.operation,
    this.delaiAnimation = Duration.zero,
    this.afficherSwipe = true,
  });

  /// L'opération à afficher
  final OperationModel operation;

  /// Délai avant l'animation d'entrée (cascade)
  final Duration delaiAnimation;

  /// Active le swipe pour supprimer
  final bool afficherSwipe;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();
    final themeCtrl = Get.find<ThemeController>();
    final isDark = themeCtrl.isDark;

    // Récupérer la catégorie de l'opération
    final categorie = ctrl.categorieParId(operation.categorieId);
    final devise = ctrl.devise;

    // Widget de base — la tuile
    Widget tile = _TileContenu(
      operation: operation,
      categorie: categorie,
      devise: devise,
      isDark: isDark,
      onTap: () => _ouvrirModification(context),
    );

    // Envelopper avec swipe si activé
    if (afficherSwipe) {
      tile = _SwipeSuppression(
        operation: operation,
        isDark: isDark,
        child: tile,
      );
    }

    // Animation d'entrée avec délai (effet cascade)
    return tile
        .animate()
        .fadeIn(
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 350),
        )
        .slideX(
          begin: 0.1,
          end: 0,
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
  }

  /// Ouvre l'écran de modification de l'opération.
  void _ouvrirModification(BuildContext context) {
    Get.to(
      () => AjouterOperationScreen(operationAModifier: operation),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 400),
    );
  }
}

// ── Contenu de la tuile ────────────────────────────────────────────

/// Contenu visuel de l'OperationTile.
class _TileContenu extends StatelessWidget {
  const _TileContenu({
    required this.operation,
    required this.categorie,
    required this.devise,
    required this.isDark,
    required this.onTap,
  });

  final OperationModel operation;
  final CategorieModel? categorie;
  final String devise;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: AppSpacing.paddingListItem,
      child: Row(
        children: [

          // ── Icône catégorie ───────────────────────────────────
          _IconeCategorie(categorie: categorie),

          const SizedBox(width: AppSpacing.md),

          // ── Infos opération ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Nom / note de l'opération
                Text(
                  _titreOperation,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // Catégorie + date
                Row(
                  children: [
                    // Nom de la catégorie
                    Text(
                      categorie?.nom ?? 'Sans catégorie',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),

                    // Séparateur point
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Date relative
                    Text(
                      operation.date.relatif,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Montant ───────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              // Montant coloré
              Text(
                '${operation.estEntree ? '+' : '-'} '
                '${Formatters.montant(operation.montant, devise)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: operation.estEntree
                      ? AppColors.entree
                      : AppColors.sortie,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 3),

              // Heure de l'opération
              Text(
                Formatters.heure(operation.date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Titre affiché — note si disponible, sinon nom de catégorie
  String get _titreOperation {
    if (operation.note != null && operation.note!.isNotEmpty) {
      return operation.note!;
    }
    return operation.estEntree ? 'Revenu' : 'Dépense';
  }
}

// ── Icône de catégorie ─────────────────────────────────────────────

/// Icône colorée de la catégorie de l'opération.
class _IconeCategorie extends StatelessWidget {
  const _IconeCategorie({required this.categorie});

  final CategorieModel? categorie;

  @override
  Widget build(BuildContext context) {
    // Couleur de la catégorie ou couleur par défaut
    final couleur = categorie != null
        ? categorie!.couleur
        : AppColors.primary;

    // Icône de la catégorie ou icône par défaut
    final icone = categorie != null
        ? categorie!.icone
        : Icons.category_rounded;

    return Container(
      width: AppSpacing.listIconSize,
      height: AppSpacing.listIconSize,
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
      ),
      child: Icon(
        icone,
        size: AppSpacing.categoryIconSize,
        color: couleur,
      ),
    );
  }
}

// ── Swipe pour supprimer ───────────────────────────────────────────

/// Enveloppe la tuile avec un swipe de suppression.
///
/// Swipe vers la gauche → révèle le bouton supprimer
/// Swipe complet → supprime directement
class _SwipeSuppression extends StatelessWidget {
  const _SwipeSuppression({
    required this.operation,
    required this.isDark,
    required this.child,
  });

  final OperationModel operation;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OperationController>();

    return Dismissible(
      // Clé unique pour chaque opération
      key: Key(operation.id),

      // Swipe de droite à gauche uniquement
      direction: DismissDirection.endToStart,

      // Confirmation avant suppression
      confirmDismiss: (_) async {
        return await context.confirmer(
          titre: 'Supprimer l\'opération',
          message: 'Cette action est irréversible. '
              'Voulez-vous supprimer cette opération ?',
          texteBoutonConfirmer: 'Supprimer',
          texteBoutonAnnuler: 'Annuler',
        );
      },

      // Action après confirmation
      onDismissed: (_) async {
        final succes = await ctrl.supprimerOperation(operation.id);
        if (succes) {
          context.snackbarSucces('Opération supprimée');
        } else {
          context.snackbarErreur('Erreur lors de la suppression');
        }
      },

      // Fond rouge visible pendant le swipe
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.alerte,
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(height: 2),
            Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      child: child,
    );
  }
}