import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/theme_controller.dart';
import '../../models/categorie_model.dart';
import '../../services/categorie_service.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../widgets/empty_state.dart';
import 'ajouter_categorie_screen.dart';

/// Écran de gestion des catégories.
///
/// Affiche :
///   - Catégories par défaut (non supprimables)
///   - Catégories personnalisées (supprimables)
///   - Bouton d'ajout de catégorie custom
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {

  final _categorieService = CategorieService();
  final themeCtrl = Get.find<ThemeController>();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  /// Recharge les catégories après une modification.
  void _recharger() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = themeCtrl.isDark;

    // Charger les catégories
    final toutes = _categorieService.toutesLesCategories();
    final parDefaut = toutes.where((c) => c.estParDefaut).toList();
    final custom = toutes.where((c) => !c.estParDefaut).toList();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),

      // ── AppBar ─────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary(isDark),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Catégories',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        actions: [
          // Bouton ajout
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: () async {
                await Get.to(
                  () => const AjouterCategorieScreen(),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 400),
                );
                _recharger();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        // TabBar
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary(isDark),
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              text: 'Par défaut (${parDefaut.length})',
            ),
            Tab(
              text: 'Mes catégories (${custom.length})',
            ),
          ],
        ),
      ),

      // ── Corps ──────────────────────────────────────────────────
      body: TabBarView(
        controller: _tabCtrl,
        children: [

          // Onglet catégories par défaut
          _ListeCategories(
            categories: parDefaut,
            estParDefaut: true,
            isDark: isDark,
            onRecharger: _recharger,
          ),

          // Onglet catégories custom
          custom.isEmpty
              ? EmptyState(
                  icone: Icons.category_rounded,
                  titre: 'Aucune catégorie personnalisée',
                  description:
                      'Créez vos propres catégories\n'
                      'pour mieux organiser vos opérations.',
                  labelBouton: 'Créer une catégorie',
                  onTapBouton: () async {
                    await Get.to(
                      () => const AjouterCategorieScreen(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 400),
                    );
                    _recharger();
                  },
                  couleurIcone: AppColors.primary,
                )
              : _ListeCategories(
                  categories: custom,
                  estParDefaut: false,
                  isDark: isDark,
                  onRecharger: _recharger,
                ),
        ],
      ),
    );
  }
}

// ── Liste catégories ───────────────────────────────────────────────

/// Liste des catégories avec swipe pour supprimer.
class _ListeCategories extends StatelessWidget {
  const _ListeCategories({
    required this.categories,
    required this.estParDefaut,
    required this.isDark,
    required this.onRecharger,
  });

  final List<CategorieModel> categories;
  final bool estParDefaut;
  final bool isDark;
  final VoidCallback onRecharger;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.lg,
        AppSpacing.pagePaddingHorizontal,
        100,
      ),
      itemCount: categories.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final cat = categories[index];

        // Tuile sans swipe pour les catégories par défaut
        if (estParDefaut) {
          return _CategorieTile(
            categorie: cat,
            isDark: isDark,
            delaiAnimation: Duration(milliseconds: 50 * index),
          );
        }

        // Tuile avec swipe pour les catégories custom
        return Dismissible(
          key: Key(cat.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await context.confirmer(
              titre: 'Supprimer la catégorie',
              message:
                  'La catégorie "${cat.nom}" sera supprimée. '
                  'Les opérations associées ne seront pas affectées.',
              texteBoutonConfirmer: 'Supprimer',
            );
          },
          onDismissed: (_) async {
            final service = CategorieService();
            final resultat = await service.supprimerCategorie(cat.id);
            if (resultat.succes) {
              context.snackbarSucces('Catégorie supprimée');
              onRecharger();
            } else {
              context.snackbarErreur(
                resultat.erreur ?? 'Erreur lors de la suppression',
              );
            }
          },
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
          child: _CategorieTile(
            categorie: cat,
            isDark: isDark,
            delaiAnimation: Duration(milliseconds: 50 * index),
            afficherBadgeCustom: true,
          ),
        );
      },
    );
  }
}

// ── Tuile catégorie ────────────────────────────────────────────────

/// Tuile d'affichage d'une catégorie.
class _CategorieTile extends StatelessWidget {
  const _CategorieTile({
    required this.categorie,
    required this.isDark,
    this.delaiAnimation = Duration.zero,
    this.afficherBadgeCustom = false,
  });

  final CategorieModel categorie;
  final bool isDark;
  final Duration delaiAnimation;
  final bool afficherBadgeCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingListItem,
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(isDark),
      ),
      child: Row(
        children: [

          // Icône catégorie
          Container(
            width: AppSpacing.listIconSize,
            height: AppSpacing.listIconSize,
            decoration: BoxDecoration(
              color: categorie.couleur.withOpacity(0.12),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusIcon,
              ),
            ),
            child: Icon(
              categorie.icone,
              size: AppSpacing.categoryIconSize,
              color: categorie.couleur,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Nom + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categorie.nom,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _labelType,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Badge custom
          if (afficherBadgeCustom)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusFull,
                ),
              ),
              child: const Text(
                'Custom',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

          // Badge par défaut
          if (!afficherBadgeCustom)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.input(isDark),
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusFull,
                ),
              ),
              child: Text(
                'Défaut',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 350),
        )
        .slideX(
          begin: 0.05,
          end: 0,
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
  }

  /// Label du type de la catégorie.
  String get _labelType {
    switch (categorie.typeOperation) {
      case 'entree':
        return 'Revenus uniquement';
      case 'sortie':
        return 'Dépenses uniquement';
      case 'les_deux':
        return 'Revenus & Dépenses';
      default:
        return '';
    }
  }
}