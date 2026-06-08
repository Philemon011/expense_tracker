import 'package:expense_tracker/controllers/budget_controller.dart';
import 'package:expense_tracker/controllers/statistique_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../services/categorie_service.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../widgets/app_button.dart';
import '../../controllers/operation_controller.dart'; 

/// Écran d'ajout d'une catégorie personnalisée.
class AjouterCategorieScreen extends StatefulWidget {
  const AjouterCategorieScreen({super.key});

  @override
  State<AjouterCategorieScreen> createState() =>
      _AjouterCategorieScreenState();
}

class _AjouterCategorieScreenState
    extends State<AjouterCategorieScreen> {

  // ── Services & Controllers ─────────────────────────────────────
  final _service = CategorieService();
  final themeCtrl = Get.find<ThemeController>();

  // ── État du formulaire ─────────────────────────────────────────
  final _nomCtrl = TextEditingController();
  int _couleurValue = 0xFF4CAF7A;
  int _iconeCode = Icons.category_rounded.codePoint;
  String _typeOperation = 'sortie';
  bool _estEnSauvegarde = false;

  // ── Palettes ───────────────────────────────────────────────────
  static const _couleurs = [
    0xFF4CAF7A,
    0xFF3B82F6,
    0xFFF59E0B,
    0xFF8B5CF6,
    0xFFEF4444,
    0xFFEC4899,
    0xFF06B6D4,
    0xFF10B981,
    0xFFF97316,
    0xFF6366F1,
  ];

  static const _icones = [
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.sports_esports_rounded,
    Icons.shopping_bag_rounded,
    Icons.school_rounded,
    Icons.receipt_long_rounded,
    Icons.flight_rounded,
    Icons.fitness_center_rounded,
    Icons.music_note_rounded,
    Icons.local_cafe_rounded,
    Icons.pets_rounded,
    Icons.movie_rounded,
    Icons.phone_android_rounded,
    Icons.book_rounded,
    Icons.medical_services_rounded,
    Icons.celebration_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.laptop_rounded,
    Icons.card_giftcard_rounded,
    Icons.beach_access_rounded,
    Icons.sports_soccer_rounded,
    Icons.local_grocery_store_rounded,
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────
  String? _valider() {
    if (_nomCtrl.text.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (_nomCtrl.text.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (_service.nomExisteDeja(_nomCtrl.text.trim())) {
      return 'Une catégorie avec ce nom existe déjà';
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

  try {
    await _service.ajouterCategorie(
      nom: _nomCtrl.text.trim(),
      iconeCode: _iconeCode,
      couleurValue: _couleurValue,
      typeOperation: _typeOperation,
    );

    // Notifier tous les controllers
    if (Get.isRegistered<OperationController>()) {
      await Get.find<OperationController>().rafraichir();
    }
    if (Get.isRegistered<StatistiqueController>()) {
      Get.find<StatistiqueController>().rafraichir();
    }
    if (Get.isRegistered<BudgetController>()) {
      Get.find<BudgetController>().rafraichir();
    }

    context.snackbarSucces('Catégorie créée avec succès');
    Get.back();
  } catch (e) {
    context.snackbarErreur('Une erreur est survenue');
  } finally {
    setState(() => _estEnSauvegarde = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = themeCtrl.isDark;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.paddingPage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Aperçu ─────────────────────────────────
                    _ApercuCategorie(
                      nom: _nomCtrl.text.isEmpty
                          ? 'Nouvelle catégorie'
                          : _nomCtrl.text,
                      couleurValue: _couleurValue,
                      iconeCode: _iconeCode,
                      typeOperation: _typeOperation,
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Nom ────────────────────────────────────
                    _LabelChamp(
                      label: 'Nom de la catégorie',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _nomCtrl,
                      onChanged: (_) => setState(() {}),
                      textCapitalization:
                          TextCapitalization.sentences,
                      style: TextStyle(
  fontFamily: 'Outfit',
                        fontSize: 15,
                        color: AppColors.textPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: Voyages, Sport...',
                        hintStyle: TextStyle(
  fontFamily: 'Outfit',
                          color: AppColors.textSecondary(isDark),
                        ),
                        prefixIcon: const Icon(
                          Icons.label_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Type opération ─────────────────────────
                    _LabelChamp(
                      label: 'Type d\'opération',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurType(
                      typeSelectionne: _typeOperation,
                      onChanged: (type) =>
                          setState(() => _typeOperation = type),
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Couleur ────────────────────────────────
                    _LabelChamp(
                      label: 'Couleur',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurCouleur(
                      couleurs: _couleurs,
                      couleurSelectionnee: _couleurValue,
                      onChanged: (val) =>
                          setState(() => _couleurValue = val),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Icône ──────────────────────────────────
                    _LabelChamp(
                      label: 'Icône',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurIcone(
                      icones: _icones,
                      iconeSelectionnee: _iconeCode,
                      couleur: Color(_couleurValue),
                      onChanged: (code) =>
                          setState(() => _iconeCode = code),
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),

            // ── Bouton créer ───────────────────────────────────
            Padding(
              padding: AppSpacing.paddingPage,
              child: AppButton(
                label: 'Créer la catégorie',
                onTap: _sauvegarder,
                estEnChargement: _estEnSauvegarde,
                icone: Icons.add_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
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
        'Nouvelle catégorie',
        style: TextStyle(
  fontFamily: 'Outfit',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(isDark),
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Aperçu catégorie ───────────────────────────────────────────────

class _ApercuCategorie extends StatelessWidget {
  const _ApercuCategorie({
    required this.nom,
    required this.couleurValue,
    required this.iconeCode,
    required this.typeOperation,
    required this.isDark,
  });

  final String nom;
  final int couleurValue;
  final int iconeCode;
  final String typeOperation;
  final bool isDark;

  String get _labelType {
    switch (typeOperation) {
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

  @override
  Widget build(BuildContext context) {
    final couleur = Color(couleurValue);
    final icone = IconData(iconeCode, fontFamily: 'MaterialIcons');

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
      child: Row(
        children: [

          // Icône
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.12),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusIcon,
              ),
            ),
            child: Icon(icone, size: 26, color: couleur),
          ),

          const SizedBox(width: AppSpacing.md),

          // Nom + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: TextStyle(
  fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _labelType,
                  style: TextStyle(
  fontFamily: 'Outfit',
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

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
  fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: couleur,
              ),
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

// ── Sélecteur type ─────────────────────────────────────────────────

class _SelecteurType extends StatelessWidget {
  const _SelecteurType({
    required this.typeSelectionne,
    required this.onChanged,
    required this.isDark,
  });

  final String typeSelectionne;
  final ValueChanged<String> onChanged;
  final bool isDark;

  static const _types = [
    (code: 'sortie', label: 'Dépenses',
     icone: Icons.arrow_upward_rounded,
     couleur: AppColors.sortie),
    (code: 'entree', label: 'Revenus',
     icone: Icons.arrow_downward_rounded,
     couleur: AppColors.entree),
    (code: 'les_deux', label: 'Les deux',
     icone: Icons.swap_vert_rounded,
     couleur: AppColors.primary),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _types.map((t) {
        final estSelectionne = typeSelectionne == t.code;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: t.code == 'les_deux' ? 0 : AppSpacing.sm,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(t.code);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: estSelectionne
                      ? t.couleur.withOpacity(0.12)
                      : AppColors.card(isDark),
                  borderRadius: AppSpacing.borderRadiusCard,
                  border: Border.all(
                    color: estSelectionne
                        ? t.couleur
                        : AppColors.border(isDark),
                    width: estSelectionne ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      t.icone,
                      size: 18,
                      color: estSelectionne
                          ? t.couleur
                          : AppColors.textSecondary(isDark),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      t.label,
                      style: TextStyle(
  fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: estSelectionne
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: estSelectionne
                            ? t.couleur
                            : AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sélecteur couleur ──────────────────────────────────────────────

class _SelecteurCouleur extends StatelessWidget {
  const _SelecteurCouleur({
    required this.couleurs,
    required this.couleurSelectionnee,
    required this.onChanged,
  });

  final List<int> couleurs;
  final int couleurSelectionnee;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: couleurs.map((val) {
        final estSelectionne = couleurSelectionnee == val;
        final couleur = Color(val);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(val);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: couleur,
              shape: BoxShape.circle,
              border: Border.all(
                color: estSelectionne
                    ? Colors.white
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: estSelectionne
                  ? [
                      BoxShadow(
                        color: couleur.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: estSelectionne
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ── Sélecteur icône ────────────────────────────────────────────────

class _SelecteurIcone extends StatelessWidget {
  const _SelecteurIcone({
    required this.icones,
    required this.iconeSelectionnee,
    required this.couleur,
    required this.onChanged,
    required this.isDark,
  });

  final List<IconData> icones;
  final int iconeSelectionnee;
  final Color couleur;
  final ValueChanged<int> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: icones.map((icone) {
        final estSelectionne = iconeSelectionnee == icone.codePoint;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(icone.codePoint);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: estSelectionne
                  ? couleur.withOpacity(0.12)
                  : AppColors.card(isDark),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
              border: Border.all(
                color: estSelectionne
                    ? couleur
                    : AppColors.border(isDark),
                width: estSelectionne ? 1.5 : 0.5,
              ),
            ),
            child: Icon(
              icone,
              size: 24,
              color: estSelectionne
                  ? couleur
                  : AppColors.textSecondary(isDark),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Label champ ────────────────────────────────────────────────────

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
  fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(isDark),
      ),
    );
  }
}