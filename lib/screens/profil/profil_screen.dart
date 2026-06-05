import 'package:expense_tracker/screens/profil/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/operation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/compte_controller.dart';
import '../../controllers/statistique_controller.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/constantes.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../statistiques/budgets_screen.dart';
import '../comptes/comptes_screen.dart';
import 'widgets/parametre_tile.dart';

/// Écran de profil et paramètres.
///
/// Sections :
///   - Header utilisateur
///   - Apparence (dark/light)
///   - Préférences (devise, nom)
///   - Données (catégories, budgets, comptes)
///   - Danger zone (réinitialisation)
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final opCtrl = Get.find<OperationController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.xxl,
                    AppSpacing.pagePaddingHorizontal,
                    0,
                  ),
                  child: _HeaderProfil(
                    nomUtilisateur: opCtrl.nomUtilisateur,
                    isDark: isDark,
                    onModifierNom: () => _modifierNom(
                      context,
                      opCtrl,
                      isDark,
                    ),
                  ),
                ),
              ),

              // ── Section Apparence ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.xxl,
                    AppSpacing.pagePaddingHorizontal,
                    0,
                  ),
                  child: _SectionApparence(
                    isDark: isDark,
                    themeCtrl: themeCtrl,
                  ),
                ),
              ),

              // ── Section Préférences ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.lg,
                    AppSpacing.pagePaddingHorizontal,
                    0,
                  ),
                  child: _SectionPreferences(
                    isDark: isDark,
                    opCtrl: opCtrl,
                    onModifierDevise: () => _modifierDevise(
                      context,
                      opCtrl,
                      isDark,
                    ),
                  ),
                ),
              ),

              // ── Section Données ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.lg,
                    AppSpacing.pagePaddingHorizontal,
                    0,
                  ),
                  child: _SectionDonnees(isDark: isDark),
                ),
              ),

              // ── Section Danger ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.lg,
                    AppSpacing.pagePaddingHorizontal,
                    0,
                  ),
                  child: _SectionDanger(
                    isDark: isDark,
                    opCtrl: opCtrl,
                  ),
                ),
              ),

              // ── Version app ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.xxl,
                  ),
                  child: Center(
                    child: Text(
                      'Expense Tracker v1.0.0',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              ),


              // ── Dévéloppeur ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.xs,
                  ),
                  child: Center(
                    child: Text(
                      'Dévéloppeur: Etounde Philémon (+229 0160585950)',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Dialogs ────────────────────────────────────────────────────

  /// Dialog pour modifier le nom d'utilisateur.
  void _modifierNom(
    BuildContext context,
    OperationController opCtrl,
    bool isDark,
  ) {
    final ctrl = TextEditingController(
      text: opCtrl.nomUtilisateur,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        title: Text(
          'Modifier le nom',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary(isDark),
          ),
          decoration: InputDecoration(
            hintText: 'Votre prénom',
            hintStyle: GoogleFonts.outfit(
              color: AppColors.textSecondary(isDark),
            ),
            prefixIcon: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await opCtrl.mettreAJourNom(ctrl.text.trim());
                Get.back();
                context.snackbarSucces('Nom mis à jour');
              }
            },
            child: Text(
              'Enregistrer',
              style: GoogleFonts.outfit(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog pour modifier la devise.
  void _modifierDevise(
    BuildContext context,
    OperationController opCtrl,
    bool isDark,
  ) {
    // Devises disponibles
    const devises = [
      (code: 'FCFA', nom: 'Franc CFA'),
      (code: 'EUR', nom: 'Euro'),
      (code: 'USD', nom: 'Dollar américain'),
      (code: 'GBP', nom: 'Livre sterling'),
      (code: 'MAD', nom: 'Dirham marocain'),
      (code: 'XOF', nom: 'Franc CFA BCEAO'),
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        title: Text(
          'Choisir la devise',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: devises.map((devise) {
            final estSelectionne = opCtrl.devise == devise.code;
            return GestureDetector(
              onTap: () async {
                await opCtrl.mettreAJourDevise(devise.code);
                // Rafraîchir tous les controllers
                Get.find<CompteController>().rafraichir();
                Get.find<BudgetController>().rafraichir();
                Get.find<StatistiqueController>().rafraichir();
                Get.back();
                context.snackbarSucces(
                  'Devise changée en ${devise.code}',
                );
              },
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: estSelectionne
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: AppSpacing.borderRadiusCard,
                  border: Border.all(
                    color: estSelectionne
                        ? AppColors.primary
                        : AppColors.border(isDark),
                    width: estSelectionne ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            devise.code,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: estSelectionne
                                  ? AppColors.primary
                                  : AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            devise.nom,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (estSelectionne)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Header profil ──────────────────────────────────────────────────

/// Header avec avatar et nom d'utilisateur.
class _HeaderProfil extends StatelessWidget {
  const _HeaderProfil({
    required this.nomUtilisateur,
    required this.isDark,
    required this.onModifierNom,
  });

  final String nomUtilisateur;
  final bool isDark;
  final VoidCallback onModifierNom;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              nomUtilisateur.isNotEmpty ? nomUtilisateur[0].toUpperCase() : 'U',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Nom + label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nomUtilisateur,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              Text(
                'Votre profil',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),

        // Bouton modifier
        GestureDetector(
          onTap: onModifierNom,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
              boxShadow: AppSpacing.cardShadow(isDark),
            ),
            child: Icon(
              Icons.edit_rounded,
              size: 16,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideX(begin: -0.1, end: 0);
  }
}

// ── Section Apparence ──────────────────────────────────────────────

class _SectionApparence extends StatelessWidget {
  const _SectionApparence({
    required this.isDark,
    required this.themeCtrl,
  });

  final bool isDark;
  final ThemeController themeCtrl;

  @override
  Widget build(BuildContext context) {
    return _Section(
      titre: 'Apparence',
      isDark: isDark,
      enfants: [
        // Switch dark/light
        ParametreTile(
          icone: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          couleurIcone:
              isDark ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B),
          titre: isDark ? 'Mode sombre' : 'Mode clair',
          sousTitre: 'Changer l\'apparence de l\'app',
          isDark: isDark,
          trailing: Switch(
            value: isDark,
            onChanged: (_) => themeCtrl.toggleTheme(),
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ── Section Préférences ────────────────────────────────────────────

class _SectionPreferences extends StatelessWidget {
  const _SectionPreferences({
    required this.isDark,
    required this.opCtrl,
    required this.onModifierDevise,
  });

  final bool isDark;
  final OperationController opCtrl;
  final VoidCallback onModifierDevise;

  @override
  Widget build(BuildContext context) {
    return _Section(
      titre: 'Préférences',
      isDark: isDark,
      enfants: [
        // Devise
        ParametreTile(
          icone: Icons.payments_rounded,
          couleurIcone: AppColors.primary,
          titre: 'Devise',
          sousTitre: opCtrl.devise,
          isDark: isDark,
          onTap: onModifierDevise,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
        ),
      ],
    );
  }
}

// ── Section Données ────────────────────────────────────────────────

class _SectionDonnees extends StatelessWidget {
  const _SectionDonnees({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _Section(
      titre: 'Données',
      isDark: isDark,
      enfants: [
        // Catégories
        ParametreTile(
          icone: Icons.category_rounded,
          couleurIcone: const Color(0xFF8B5CF6),
          titre: 'Catégories',
          sousTitre: 'Gérer vos catégories',
          isDark: isDark,
          onTap: () => Get.to(
            () => const CategoriesScreen(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
        ),

        // Comptes
        ParametreTile(
          icone: Icons.account_balance_wallet_rounded,
          couleurIcone: AppColors.entree,
          titre: 'Mes comptes',
          sousTitre: 'Gérer vos comptes financiers',
          isDark: isDark,
          onTap: () => Get.to(
            () => const ComptesScreen(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
        ),

        // Budgets
        ParametreTile(
          icone: Icons.savings_rounded,
          couleurIcone: AppColors.sortie,
          titre: 'Mes budgets',
          sousTitre: 'Gérer vos budgets mensuels',
          isDark: isDark,
          onTap: () => Get.to(
            () => const BudgetsScreen(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
        ),
      ],
    );
  }
}

// ── Section Danger ─────────────────────────────────────────────────

class _SectionDanger extends StatelessWidget {
  const _SectionDanger({
    required this.isDark,
    required this.opCtrl,
  });

  final bool isDark;
  final OperationController opCtrl;

  @override
  Widget build(BuildContext context) {
    return _Section(
      titre: 'Zone de danger',
      isDark: isDark,
      enfants: [
        // Réinitialiser les données
        ParametreTile(
          icone: Icons.delete_forever_rounded,
          couleurIcone: AppColors.alerte,
          titre: 'Réinitialiser les données',
          sousTitre: 'Supprimer toutes les opérations',
          isDark: isDark,
          onTap: () => _confirmerReinitialisation(context),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmerReinitialisation(
    BuildContext context,
  ) async {
    final confirme = await context.confirmer(
      titre: 'Réinitialiser les données',
      message: 'Toutes vos opérations seront supprimées définitivement. '
          'Les comptes et catégories seront conservés.',
      texteBoutonConfirmer: 'Réinitialiser',
      texteBoutonAnnuler: 'Annuler',
    );

    if (confirme) {
      await opCtrl.rafraichir();
      context.snackbarSucces('Données réinitialisées');
    }
  }
}

// ── Section générique ──────────────────────────────────────────────

/// Section avec titre et liste de tuiles.
class _Section extends StatelessWidget {
  const _Section({
    required this.titre,
    required this.isDark,
    required this.enfants,
  });

  final String titre;
  final bool isDark;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            titre,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(isDark),
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Conteneur des tuiles
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppSpacing.cardShadow(isDark),
          ),
          child: Column(
            children: enfants.asMap().entries.map((entry) {
              final index = entry.key;
              final enfant = entry.value;
              final estDernier = index == enfants.length - 1;

              return Column(
                children: [
                  enfant,
                  // Séparateur sauf pour le dernier
                  if (!estDernier)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.border(isDark),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.1, end: 0);
  }
}
