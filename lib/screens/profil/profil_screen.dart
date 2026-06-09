import 'package:expense_tracker/screens/profil/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
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
import '../../services/hive_service.dart'; // ← AJOUTER
import 'package:hive/hive.dart'; // ← AJOUTER
import '../../models/operation_model.dart'; // ← AJOUTER
import '../../models/budget_model.dart'; // ← AJOUTER
import '../../utils/constantes.dart'; // ← AJOUTER
import '../../services/export_service.dart'; // ← AJOUTER
import 'package:url_launcher/url_launcher.dart'; // ← AJOUTER

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
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Développeur ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _ouvrirWhatsApp(context),
                      child: Text(
                        'Développeur : Etounde Philémon',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
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

    /// Ouvre WhatsApp avec le numéro du développeur.
void _ouvrirWhatsApp(BuildContext context) async {
  // Numéro au format international sans + ni espaces
  const numero = '2290160585950';
  const message = 'Bonjour Philémon, '
      'je vous contacte depuis Expense Tracker.';

  final uri = Uri.parse(
    'https://wa.me/$numero?text=${Uri.encodeComponent(message)}',
  );

  try {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    context.snackbarErreur(
      'Impossible d\'ouvrir WhatsApp',
    );
  }
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
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textPrimary(isDark),
          ),
          decoration: InputDecoration(
            hintText: 'Votre prénom',
            hintStyle: TextStyle(
              fontFamily: 'Outfit',
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
              style: TextStyle(
                fontFamily: 'Outfit',
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
              style: TextStyle(
                fontFamily: 'Outfit',
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
          style: TextStyle(
            fontFamily: 'Outfit',
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
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: estSelectionne
                                  ? AppColors.primary
                                  : AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            devise.nom,
                            style: TextStyle(
                              fontFamily: 'Outfit',
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
              style: TextStyle(
                fontFamily: 'Outfit',
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
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              Text(
                'Votre profil',
                style: TextStyle(
                  fontFamily: 'Outfit',
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
        Obx(() => ParametreTile(
              icone: Icons.payments_rounded,
              couleurIcone: AppColors.primary,
              titre: 'Devise',
              sousTitre: opCtrl.devise, // ← Maintenant réactif via Obx
              isDark: isDark,
              onTap: onModifierDevise,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary(isDark),
                size: 20,
              ),
            )),
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

        // ── Export CSV ─────────────────────────────────────────
        ParametreTile(
          icone: Icons.download_rounded,
          couleurIcone: const Color(0xFF06B6D4),
          titre: 'Exporter les données',
          sousTitre: 'Export CSV — Excel, Google Sheets',
          isDark: isDark,
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _BottomSheetExport(isDark: isDark),
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

  /// Ouvre le bottom sheet d'export.
  void _ouvrirExport(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetExport(isDark: isDark),
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
    // Première confirmation
    final confirme = await context.confirmer(
      titre: 'Réinitialiser les données',
      message: 'Toutes vos opérations seront supprimées définitivement. '
          'Les comptes et catégories seront conservés.',
      texteBoutonConfirmer: 'Réinitialiser',
      texteBoutonAnnuler: 'Annuler',
    );

    if (!confirme) return;

    // Deuxième confirmation
    final doubleConfirme = await context.confirmer(
      titre: 'Êtes-vous sûr ?',
      message: 'Cette action est irréversible. '
          'Toutes vos opérations seront perdues définitivement.',
      texteBoutonConfirmer: 'Oui, supprimer tout',
      texteBoutonAnnuler: 'Annuler',
    );

    if (!doubleConfirme) return;

    try {
      // Vider directement via Hive avec le nom des boîtes
      final boxOps = Hive.box<OperationModel>(
        Constantes.boxOperations,
      );
      final boxBudgets = Hive.box<BudgetModel>(
        Constantes.boxBudgets,
      );

      await boxOps.clear();
      await boxBudgets.clear();

      debugPrint('✅ Réinitialisation : '
          '${boxOps.length} opérations restantes');
      debugPrint('✅ Réinitialisation : '
          '${boxBudgets.length} budgets restants');

      // Rafraîchir tous les controllers
      await opCtrl.rafraichir();

      if (Get.isRegistered<BudgetController>()) {
        await Get.find<BudgetController>().rafraichir();
      }
      if (Get.isRegistered<StatistiqueController>()) {
        await Get.find<StatistiqueController>().rafraichir();
      }
      if (Get.isRegistered<CompteController>()) {
        await Get.find<CompteController>().rafraichir();
      }

      context.snackbarSucces('Données réinitialisées avec succès');
    } catch (e) {
      debugPrint('❌ Erreur réinitialisation : $e');
      context.snackbarErreur('Erreur lors de la réinitialisation');
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
            style: TextStyle(
              fontFamily: 'Outfit',
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

// ── Bottom Sheet Export ────────────────────────────────────────────

/// Bottom sheet avec les 3 options d'export.
///
/// Flow :
///   1. Utilisateur choisit une option
///   2. CSV généré
///   3. Dialog → Partager ou Sauvegarder
class _BottomSheetExport extends StatefulWidget {
  const _BottomSheetExport({required this.isDark});

  final bool isDark;

  @override
  State<_BottomSheetExport> createState() => _BottomSheetExportState();
}

class _BottomSheetExportState extends State<_BottomSheetExport> {
  // ── Services & Controllers ────────────────────────────────────
  final _exportService = ExportService();
  final _opCtrl = Get.find<OperationController>();

  // ── État ──────────────────────────────────────────────────────
  bool _estEnChargement = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final now = DateTime.now();

    // Nombre d'opérations disponibles par option
    final nombreTotal = _exportService.nombreOperations();
    final nombreMois = _exportService.nombreOperations(
      mois: now.month,
      annee: now.year,
    );

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.pagePaddingHorizontal,
        right: AppSpacing.pagePaddingHorizontal,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxxl,
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
          // ── Handle ─────────────────────────────────────────
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

          // ── Titre ───────────────────────────────────────────
          Text(
            'Exporter les données',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Choisissez la période à exporter',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: AppColors.textSecondary(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Option 1 : Tout exporter ────────────────────────
          _OptionExport(
            icone: Icons.download_for_offline_rounded,
            couleur: AppColors.primary,
            titre: 'Tout exporter',
            sousTitre: '$nombreTotal opération(s) au total',
            isDark: isDark,
            estEnChargement: _estEnChargement,
            onTap: () async {
              final operations = _exportService.toutesLesOperations();
              await _lancerExport(
                context: context,
                operations: operations,
                nomFichier: 'expense_tracker_complet',
              );
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Option 2 : Mois courant ─────────────────────────
          _OptionExport(
            icone: Icons.calendar_today_rounded,
            couleur: AppColors.entree,
            titre: 'Mois courant',
            sousTitre: '$nombreMois opération(s) — '
                '${Formatters.nomMois(now.month)} ${now.year}',
            isDark: isDark,
            estEnChargement: _estEnChargement,
            onTap: () async {
              final operations = _exportService.operationsDuMois(
                mois: now.month,
                annee: now.year,
              );
              await _lancerExport(
                context: context,
                operations: operations,
                nomFichier: 'expense_tracker_'
                    '${Formatters.nomMois(now.month).toLowerCase()}'
                    '_${now.year}',
              );
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Option 3 : Période personnalisée ────────────────
          _OptionExport(
            icone: Icons.date_range_rounded,
            couleur: AppColors.sortie,
            titre: 'Période personnalisée',
            sousTitre: 'Choisir une date de début et de fin',
            isDark: isDark,
            estEnChargement: _estEnChargement,
            onTap: () => _choisirPeriode(context),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Info format ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.input(isDark),
              borderRadius: AppSpacing.borderRadiusCard,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Format CSV — compatible Excel, '
                    'Google Sheets et Numbers',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Logique export ─────────────────────────────────────────────

  /// Lance la génération du CSV puis affiche le dialog d'action.
  Future<void> _lancerExport({
    required BuildContext context,
    required List<OperationModel> operations,
    required String nomFichier,
  }) async {
    // Vérifier qu'il y a des données
    if (operations.isEmpty) {
      context.snackbarErreur('Aucune opération sur cette période');
      return;
    }

    setState(() => _estEnChargement = true);

    // Générer le CSV
    final resultat = await _exportService.generer(
      operations: operations,
      devise: _opCtrl.devise,
      nomFichier: nomFichier,
    );

    setState(() => _estEnChargement = false);

    if (!resultat.succes) {
      context.snackbarErreur(resultat.message);
      return;
    }

    // Fermer le bottom sheet
    Get.back();

    // Afficher le dialog Partager / Sauvegarder
    _afficherDialogAction(
      context: context,
      resultat: resultat,
    );
  }

  /// Ouvre le date picker pour choisir une période.
  Future<void> _choisirPeriode(BuildContext context) async {
    final isDark = widget.isDark;

    // Date de début
    final debut = await showDatePicker(
      context: context,
      initialDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Date de début',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.card(isDark),
            onSurface: AppColors.textPrimary(isDark),
          ),
        ),
        child: child!,
      ),
    );

    if (debut == null) return;

    // Date de fin
    final fin = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: debut,
      lastDate: DateTime.now(),
      helpText: 'Date de fin',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.card(isDark),
            onSurface: AppColors.textPrimary(isDark),
          ),
        ),
        child: child!,
      ),
    );

    if (fin == null) return;

    // Récupérer les opérations de la période
    final operations = _exportService.operationsParPeriode(
      debut: debut,
      fin: fin,
    );

    await _lancerExport(
      context: context,
      operations: operations,
      nomFichier: 'expense_tracker_'
          '${debut.day}-${debut.month}-${debut.year}_'
          '${fin.day}-${fin.month}-${fin.year}',
    );
  }

  // ── Dialog Partager / Sauvegarder ─────────────────────────────

  /// Affiche le dialog avec les 2 actions disponibles.
  void _afficherDialogAction({
    required BuildContext context,
    required ResultatExport resultat,
  }) {
    final isDark = widget.isDark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),

        // ── Titre ──────────────────────────────────────────
        title: Row(
          children: const [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'CSV généré !',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nombre d'opérations
            Text(
              '${resultat.nombreOperations} opération(s) '
              'prête(s) à exporter',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.textSecondary(isDark),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Bouton Partager ────────────────────────────
            _BoutonAction(
              icone: Icons.share_rounded,
              couleur: AppColors.primary,
              titre: 'Partager',
              sousTitre: 'WhatsApp, Email, Drive...',
              isDark: isDark,
              onTap: () async {
                Get.back();
                await _exportService.partager(resultat);
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Bouton Sauvegarder ─────────────────────────
            _BoutonAction(
              icone: Icons.save_alt_rounded,
              couleur: const Color(0xFF8B5CF6),
              titre: 'Sauvegarder en local',
              sousTitre: 'Dossier Téléchargements',
              isDark: isDark,
              onTap: () async {
                Get.back();
                final sauvegarde = await _exportService.sauvegarderEnLocal(
                  resultat,
                );
                if (sauvegarde.succes) {
                  // Afficher le chemin du fichier sauvegardé
                  _afficherConfirmationSauvegarde(
                    context: context,
                    sauvegarde: sauvegarde,
                    isDark: isDark,
                  );
                } else {
                  context.snackbarErreur(sauvegarde.message);
                }
              },
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche la confirmation après sauvegarde locale.
  void _afficherConfirmationSauvegarde({
    required BuildContext context,
    required ResultatSauvegarde sauvegarde,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        title: Row(
          children: const [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Fichier sauvegardé',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre fichier CSV a été sauvegardé dans :',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.textSecondary(isDark),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Chemin du fichier
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppSpacing.borderRadiusCard,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Téléchargements',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          sauvegarde.nomFichier ?? '',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Ouvrez le gestionnaire de fichiers\n'
              'pour accéder à votre export.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: AppColors.textSecondary(isDark),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option d'export ────────────────────────────────────────────────

/// Carte d'une option dans le bottom sheet.
class _OptionExport extends StatelessWidget {
  const _OptionExport({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.sousTitre,
    required this.isDark,
    required this.onTap,
    required this.estEnChargement,
  });

  final IconData icone;
  final Color couleur;
  final String titre;
  final String sousTitre;
  final bool isDark;
  final VoidCallback onTap;
  final bool estEnChargement;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: estEnChargement ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: estEnChargement ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background(isDark),
            borderRadius: AppSpacing.borderRadiusCard,
            border: Border.all(
              color: AppColors.border(isDark),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSmall,
                  ),
                ),
                child: Icon(icone, size: 22, color: couleur),
              ),

              const SizedBox(width: AppSpacing.md),

              // Titre + sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      sousTitre,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche ou loading
              estEnChargement
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: couleur,
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textSecondary(isDark),
                    ),
            ],
          ),
        ),
      ),
    );
  }


}

// ── Bouton action dialog ───────────────────────────────────────────

/// Bouton dans le dialog Partager/Sauvegarder.
class _BoutonAction extends StatelessWidget {
  const _BoutonAction({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.sousTitre,
    required this.isDark,
    required this.onTap,
  });

  final IconData icone;
  final Color couleur;
  final String titre;
  final String sousTitre;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: couleur.withOpacity(0.08),
          borderRadius: AppSpacing.borderRadiusCard,
          border: Border.all(
            color: couleur.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: couleur.withOpacity(0.12),
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusSmall,
                ),
              ),
              child: Icon(icone, size: 20, color: couleur),
            ),

            const SizedBox(width: AppSpacing.md),

            // Titre + sous-titre
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: couleur,
                  ),
                ),
                Text(
                  sousTitre,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: couleur.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
