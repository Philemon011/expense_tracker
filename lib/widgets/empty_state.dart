import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_colors.dart';
import '../themes/app_spacing.dart';
import '../utils/extensions.dart';
import 'app_button.dart';

/// Widget d'état vide — affiché quand une liste est vide.
///
/// Variantes prédéfinies :
///   EmptyState.operations()  → aucune opération
///   EmptyState.budgets()     → aucun budget
///   EmptyState.comptes()     → aucun compte
///   EmptyState.recherche()   → aucun résultat de recherche
///
/// Ou personnalisé :
///   EmptyState(
///     icone: Icons.inbox_rounded,
///     titre: 'Rien ici',
///     description: 'Commencez par ajouter un élément',
///   )
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icone,
    required this.titre,
    required this.description,
    this.labelBouton,
    this.onTapBouton,
    this.couleurIcone,
  });

  // ── Constructeurs nommés ───────────────────────────────────────

  /// État vide pour la liste des opérations
  factory EmptyState.operations({VoidCallback? onAjouter}) {
    return EmptyState(
      icone: Icons.receipt_long_rounded,
      titre: 'Aucune opération',
      description:
          'Vous n\'avez pas encore enregistré\n'
          'de revenus ou de dépenses.',
      labelBouton: onAjouter != null ? 'Ajouter une opération' : null,
      onTapBouton: onAjouter,
      couleurIcone: AppColors.primary,
    );
  }

  /// État vide pour la liste des budgets
  factory EmptyState.budgets({VoidCallback? onAjouter}) {
    return EmptyState(
      icone: Icons.savings_rounded,
      titre: 'Aucun budget défini',
      description:
          'Définissez des budgets par catégorie\n'
          'pour mieux contrôler vos dépenses.',
      labelBouton: onAjouter != null ? 'Créer un budget' : null,
      onTapBouton: onAjouter,
      couleurIcone: AppColors.entree,
    );
  }

  /// État vide pour la liste des comptes
  factory EmptyState.comptes({VoidCallback? onAjouter}) {
    return EmptyState(
      icone: Icons.account_balance_wallet_rounded,
      titre: 'Aucun compte',
      description:
          'Ajoutez un compte bancaire, des espèces\n'
          'ou un compte mobile money.',
      labelBouton: onAjouter != null ? 'Ajouter un compte' : null,
      onTapBouton: onAjouter,
      couleurIcone: AppColors.sortie,
    );
  }

  /// État vide pour les résultats de recherche
  factory EmptyState.recherche({String? query}) {
    return EmptyState(
      icone: Icons.search_off_rounded,
      titre: 'Aucun résultat',
      description: query != null
          ? 'Aucune opération trouvée\npour "$query".'
          : 'Aucune opération ne correspond\nà votre recherche.',
      couleurIcone: AppColors.textSecondaryLight,
    );
  }

  /// État vide pour les statistiques (pas de données ce mois)
  factory EmptyState.statistiques() {
    return const EmptyState(
      icone: Icons.bar_chart_rounded,
      titre: 'Pas de données',
      description:
          'Aucune opération enregistrée\n'
          'pour cette période.',
      couleurIcone: AppColors.primary,
    );
  }

  // ── Propriétés ─────────────────────────────────────────────────

  /// Icône principale illustrant l'état vide
  final IconData icone;

  /// Titre principal — court et direct
  final String titre;

  /// Description — explique quoi faire
  final String description;

  /// Label du bouton d'action — null = pas de bouton
  final String? labelBouton;

  /// Action du bouton
  final VoidCallback? onTapBouton;

  /// Couleur de l'icône — défaut : vert primary
  final Color? couleurIcone;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final couleur = couleurIcone ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Icône dans un cercle coloré ────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: couleur.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icone,
                  size: 40,
                  color: couleur.withOpacity(0.8),
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: const Duration(milliseconds: 300)),

            const SizedBox(height: AppSpacing.xxl),

            // ── Titre ──────────────────────────────────────────
            Text(
              titre,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 400),
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: AppSpacing.sm),

            // ── Description ────────────────────────────────────
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary(isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 400),
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                ),

            // ── Bouton d'action ────────────────────────────────
            if (labelBouton != null && onTapBouton != null) ...[
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: labelBouton!,
                onTap: onTapBouton,
                icone: Icons.add_rounded,
                largeurComplete: false,
              )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 350),
                    duration: const Duration(milliseconds: 400),
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: const Duration(milliseconds: 350),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}