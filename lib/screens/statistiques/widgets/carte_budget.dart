import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/budget_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../models/budget_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../utils/formatters.dart';
import '../../../services/budget_service.dart'; 

/// Carte d'affichage d'un budget avec barre de progression.
///
/// Affiche :
///   - Icône + nom de la catégorie
///   - Montant dépensé / montant max
///   - Barre de progression colorée
///   - Badge statut (Dépassé / Attention)
///   - Swipe pour supprimer
///
/// Utilisation :
///   CarteBudget(
///     budget: budgetAvecProgression,
///     devise: 'FCFA',
///     delaiAnimation: Duration(milliseconds: 100),
///   )
class CarteBudget extends StatelessWidget {
  const CarteBudget({
    super.key,
    required this.budget,
    required this.devise,
    this.delaiAnimation = Duration.zero,
  });

  final BudgetAvecProgression budget;
  final String devise;
  final Duration delaiAnimation;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final isDark = themeCtrl.isDark;

    return Dismissible(
      key: Key(budget.budget.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await context.confirmer(
          titre: 'Supprimer le budget',
          message: 'Ce budget sera supprimé. '
              'Les opérations ne sont pas affectées.',
          texteBoutonConfirmer: 'Supprimer',
        );
      },
      onDismissed: (_) async {
        final ctrl = Get.find<BudgetController>();
        final succes = await ctrl.supprimerBudget(budget.budget.id);
        if (succes) {
          context.snackbarSucces('Budget supprimé');
        }
      },
      // Fond rouge pendant le swipe
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.alerte,
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_rounded, color: Colors.white, size: 22),
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
      child: GestureDetector(
        onTap: () => _ouvrirModification(context),
        child: Container(
          padding: AppSpacing.paddingCard,
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppSpacing.cardShadow(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header : catégorie + badge statut ────────────
              Row(
                children: [
                  // Icône catégorie
                  _IconeCategorie(
                    budget: budget,
                    isDark: isDark,
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Nom catégorie
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nomCategorie,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        Text(
                          budget.budget.estRecurrent
                              ? 'Récurrent chaque mois'
                              : 'Ce mois uniquement',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge statut
                  if (budget.statut != StatutBudget.normal)
                    _BadgeStatut(statut: budget.statut),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Montants ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dépensé
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: Formatters.montant(
                            budget.montantDepense,
                            devise,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _couleurStatut,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${Formatters.montant(
                            budget.budget.montantMax,
                            devise,
                          )}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pourcentage
                  Text(
                    budget.pourcentageTexte,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _couleurStatut,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Barre de progression ──────────────────────────
              _BarreProgression(
                progression: budget.pourcentage,
                couleur: _couleurStatut,
                isDark: isDark,
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Montant restant ───────────────────────────────
              Text(
                budget.estDepasse
                    ? 'Dépassé de ${Formatters.montant(
                        budget.montantDepense - budget.budget.montantMax,
                        devise,
                      )}'
                    : '${Formatters.montant(
                        budget.montantRestant,
                        devise,
                      )} restants',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: budget.estDepasse
                      ? AppColors.alerte
                      : AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }

  /// Nom de la catégorie du budget.
  String get _nomCategorie {
    final ctrl = Get.find<BudgetController>();
    return ctrl.categorieParId(budget.budget.categorieId)?.nom ??
        'Catégorie inconnue';
  }

  /// Couleur selon le statut du budget.
  Color get _couleurStatut {
  switch (budget.statut) {
    case StatutBudget.normal:
      return AppColors.primary;
    case StatutBudget.attention:
      return AppColors.sortie;
    case StatutBudget.depasse:
      return AppColors.alerte;
    default:                        // ← AJOUTER
      return AppColors.primary;     // ← AJOUTER
  }
}

  /// Ouvre la modification du montant max.
  void _ouvrirModification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetModifier(
        budget: budget,
        devise: devise,
      ),
    );
  }
}

// ── Icône catégorie ────────────────────────────────────────────────

class _IconeCategorie extends StatelessWidget {
  const _IconeCategorie({
    required this.budget,
    required this.isDark,
  });

  final BudgetAvecProgression budget;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BudgetController>();
    final categorie =
        ctrl.categorieParId(budget.budget.categorieId);

    final couleur = categorie?.couleur ?? AppColors.primary;
    final icone = categorie?.icone ?? Icons.category_rounded;

    return Container(
      width: AppSpacing.listIconSize,
      height: AppSpacing.listIconSize,
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
      ),
      child: Icon(icone, size: 20, color: couleur),
    );
  }
}

// ── Badge statut ───────────────────────────────────────────────────

/// Badge coloré indiquant le statut du budget.
class _BadgeStatut extends StatelessWidget {
  const _BadgeStatut({required this.statut});

  final StatutBudget statut;

  @override
  Widget build(BuildContext context) {
    final estDepasse = statut == StatutBudget.depasse;
    final couleur = estDepasse ? AppColors.alerte : AppColors.sortie;
    final label = estDepasse ? 'Dépassé' : 'Attention';
    final icone = estDepasse
        ? Icons.warning_rounded
        : Icons.info_outline_rounded;

    return Container(
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
          Icon(icone, size: 12, color: couleur),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre de progression ───────────────────────────────────────────

/// Barre de progression animée du budget.
class _BarreProgression extends StatelessWidget {
  const _BarreProgression({
    required this.progression,
    required this.couleur,
    required this.isDark,
  });

  final double progression;
  final Color couleur;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond de la barre
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.input(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),

        // Remplissage animé
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          height: 8,
          width: double.infinity,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progression.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: couleur,
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusFull,
                ),
                // Effet brillance sur la barre
                boxShadow: [
                  BoxShadow(
                    color: couleur.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom Sheet modifier ──────────────────────────────────────────

/// Bottom sheet pour modifier le montant max d'un budget.
class _BottomSheetModifier extends StatefulWidget {
  const _BottomSheetModifier({
    required this.budget,
    required this.devise,
  });

  final BudgetAvecProgression budget;
  final String devise;

  @override
  State<_BottomSheetModifier> createState() =>
      _BottomSheetModifierState();
}

class _BottomSheetModifierState extends State<_BottomSheetModifier> {
  late final TextEditingController _montantCtrl;
  bool _estEnSauvegarde = false;
  bool _estRecurrent = true;

  @override
  void initState() {
    super.initState();
    _montantCtrl = TextEditingController(
      text: widget.budget.budget.montantMax.toStringAsFixed(0),
    );
    _estRecurrent = widget.budget.budget.estRecurrent;
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    final montant = double.tryParse(_montantCtrl.text);
    if (montant == null || montant <= 0) {
      context.snackbarErreur('Montant invalide');
      return;
    }

    setState(() => _estEnSauvegarde = true);

    final ctrl = Get.find<BudgetController>();
    final budgetModifie = widget.budget.budget.copyWith(
      montantMax: montant,
      estRecurrent: _estRecurrent,
    );

    final succes = await ctrl.modifierBudget(budgetModifie);

    setState(() => _estEnSauvegarde = false);

    if (succes) {
      context.snackbarSucces('Budget modifié');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDark;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.pagePaddingHorizontal,
        right: AppSpacing.pagePaddingHorizontal,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusCard),
          topRight: Radius.circular(AppSpacing.radiusCard),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(isDark),
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusFull,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Titre
          Text(
            'Modifier le budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Champ montant
          TextField(
            controller: _montantCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
            ),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: 'Montant maximum',
              suffixText: widget.devise,
              suffixStyle: TextStyle(
                color: AppColors.textSecondary(isDark),
              ),
              prefixIcon: const Icon(
                Icons.savings_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Switch récurrent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Renouveler chaque mois',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              Switch(
                value: _estRecurrent,
                onChanged: (val) =>
                    setState(() => _estRecurrent = val),
                activeColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Bouton sauvegarder
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: _estEnSauvegarde ? null : _sauvegarder,
              child: _estEnSauvegarde
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}