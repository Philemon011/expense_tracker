import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/categorie_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';

/// Écran d'ajout d'un nouveau budget mensuel.
///
/// Permet de :
///   - Choisir une catégorie (sans budget existant)
///   - Définir un montant maximum
///   - Activer le renouvellement mensuel automatique
class AjouterBudgetScreen extends StatefulWidget {
  const AjouterBudgetScreen({super.key});

  @override
  State<AjouterBudgetScreen> createState() =>
      _AjouterBudgetScreenState();
}

class _AjouterBudgetScreenState extends State<AjouterBudgetScreen> {

  // ── Controllers ────────────────────────────────────────────────
  final ctrl = Get.find<BudgetController>();
  final themeCtrl = Get.find<ThemeController>();

  // ── État du formulaire ─────────────────────────────────────────
  CategorieModel? _categorieSelectionnee;
  final _montantCtrl = TextEditingController();
  bool _estRecurrent = true;
  bool _estEnSauvegarde = false;

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────
  String? _valider() {
    if (_categorieSelectionnee == null) {
      return 'Choisissez une catégorie';
    }
    final montant = double.tryParse(_montantCtrl.text);
    if (montant == null || montant <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    return null;
  }

  // ── Sauvegarde ─────────────────────────────────────────────────
  Future<void> _sauvegarder() async {
    final erreur = _valider();
    if (erreur != null) {
      context.snackbarErreur(erreur);
      return;
    }

    setState(() => _estEnSauvegarde = true);

    final succes = await ctrl.ajouterBudget(
      categorieId: _categorieSelectionnee!.id,
      montantMax: double.parse(_montantCtrl.text),
      estRecurrent: _estRecurrent,
    );

    setState(() => _estEnSauvegarde = false);

    if (succes) {
      context.snackbarSucces('Budget créé avec succès');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeCtrl.isDark;
    final categories = ctrl.categoriesDisponibles;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.background(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.textPrimary(isDark),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Nouveau budget',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [

            // ── Formulaire scrollable ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.paddingPage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Aperçu budget ──────────────────────────
                    _ApercuBudget(
                      categorie: _categorieSelectionnee,
                      montantMax: double.tryParse(
                            _montantCtrl.text,
                          ) ??
                          0,
                      devise: ctrl.devise,
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Sélection catégorie ────────────────────
                    _LabelChamp(
                      label: 'Catégorie',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Vérifier si des catégories sont disponibles
                    categories.isEmpty
                        ? _MessageAucuneCategorie(isDark: isDark)
                        : _SelecteurCategorie(
                            categories: categories,
                            categorieSelectionnee:
                                _categorieSelectionnee,
                            onChanged: (cat) => setState(
                              () => _categorieSelectionnee = cat,
                            ),
                            isDark: isDark,
                          ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Montant maximum ────────────────────────
                    _LabelChamp(
                      label: 'Montant maximum',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _montantCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: 150000',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary(isDark),
                        ),
                        prefixIcon: const Icon(
                          Icons.savings_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        suffixText: ctrl.devise,
                        suffixStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Option récurrent ───────────────────────
                    _CarteOptionRecurrent(
                      estRecurrent: _estRecurrent,
                      onChanged: (val) =>
                          setState(() => _estRecurrent = val),
                      isDark: isDark,
                    ),

                    // ── Info période ───────────────────────────
                    const SizedBox(height: AppSpacing.md),
                    _InfoPeriode(
                      mois: ctrl.mois,
                      annee: ctrl.annee,
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),

            // ── Bouton créer ─────────────────────────────────────
            Padding(
              padding: AppSpacing.paddingPage,
              child: AppButton(
                label: 'Créer le budget',
                onTap: categories.isEmpty ? null : _sauvegarder,
                estEnChargement: _estEnSauvegarde,
                icone: Icons.add_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aperçu budget ──────────────────────────────────────────────────

/// Aperçu en temps réel du budget pendant la saisie.
class _ApercuBudget extends StatelessWidget {
  const _ApercuBudget({
    required this.categorie,
    required this.montantMax,
    required this.devise,
    required this.isDark,
  });

  final CategorieModel? categorie;
  final double montantMax;
  final String devise;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final couleur = categorie?.couleur ?? AppColors.primary;
    final icone = categorie?.icone ?? Icons.savings_rounded;
    final nom = categorie?.nom ?? 'Choisir une catégorie';

    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(isDark),
        border: Border.all(
          color: couleur.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header catégorie
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusIcon,
                  ),
                ),
                child: Icon(icone, size: 22, color: couleur),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  Text(
                    montantMax > 0
                        ? Formatters.montant(montantMax, devise)
                        : 'Définir un montant',
                    style: TextStyle(
                      fontSize: 13,
                      color: montantMax > 0
                          ? couleur
                          : AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Badge aperçu
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusFull,
                  ),
                ),
                child: Text(
                  'Aperçu',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: couleur,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Barre de progression (vide = 0%)
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.input(isDark),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusFull,
                  ),
                ),
              ),
              Container(
                height: 8,
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: couleur,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Montant restant
          Text(
            montantMax > 0
                ? '${Formatters.montant(montantMax, devise)} disponibles'
                : 'Aucun montant défini',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: -0.1, end: 0);
  }
}

// ── Sélecteur catégorie ────────────────────────────────────────────

/// Liste horizontale des catégories disponibles.
class _SelecteurCategorie extends StatelessWidget {
  const _SelecteurCategorie({
    required this.categories,
    required this.categorieSelectionnee,
    required this.onChanged,
    required this.isDark,
  });

  final List<CategorieModel> categories;
  final CategorieModel? categorieSelectionnee;
  final ValueChanged<CategorieModel> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final estSelectionne = categorieSelectionnee?.id == cat.id;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 75,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: estSelectionne
                    ? cat.couleur.withOpacity(0.12)
                    : AppColors.card(isDark),
                borderRadius: AppSpacing.borderRadiusCard,
                border: Border.all(
                  color: estSelectionne
                      ? cat.couleur
                      : AppColors.border(isDark),
                  width: estSelectionne ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cat.couleur.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      cat.icone,
                      size: 18,
                      color: cat.couleur,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    cat.nom,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: estSelectionne
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: estSelectionne
                          ? cat.couleur
                          : AppColors.textSecondary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Carte option récurrent ─────────────────────────────────────────

/// Carte avec switch pour activer le renouvellement mensuel.
class _CarteOptionRecurrent extends StatelessWidget {
  const _CarteOptionRecurrent({
    required this.estRecurrent,
    required this.onChanged,
    required this.isDark,
  });

  final bool estRecurrent;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(isDark),
      ),
      child: Row(
        children: [

          // Icône
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
            ),
            child: const Icon(
              Icons.autorenew_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renouvellement automatique',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                Text(
                  'Ce budget se recrée chaque mois',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Switch(
            value: estRecurrent,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Info période ───────────────────────────────────────────────────

/// Indique pour quel mois le budget sera créé.
class _InfoPeriode extends StatelessWidget {
  const _InfoPeriode({
    required this.mois,
    required this.annee,
    required this.isDark,
  });

  final int mois;
  final int annee;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: AppColors.textSecondary(isDark),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Ce budget sera créé pour ${Formatters.nomMois(mois)} $annee',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ],
    );
  }
}

// ── Message aucune catégorie ───────────────────────────────────────

/// Message affiché si toutes les catégories ont déjà un budget.
class _MessageAucuneCategorie extends StatelessWidget {
  const _MessageAucuneCategorie({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppSpacing.borderRadiusCard,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Toutes les catégories ont déjà un budget ce mois.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label de champ ─────────────────────────────────────────────────

class _LabelChamp extends StatelessWidget {
  const _LabelChamp({
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(isDark),
      ),
    );
  }
}