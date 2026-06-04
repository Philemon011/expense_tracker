import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/compte_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/compte_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../widgets/app_button.dart';

/// Écran d'ajout et de modification d'un compte.
///
/// Si [compteAModifier] est fourni → mode modification.
/// Sinon → mode ajout.
class AjouterCompteScreen extends StatefulWidget {
  const AjouterCompteScreen({
    super.key,
    this.compteAModifier,
  });

  final CompteModel? compteAModifier;

  @override
  State<AjouterCompteScreen> createState() =>
      _AjouterCompteScreenState();
}

class _AjouterCompteScreenState extends State<AjouterCompteScreen> {

  // ── Controllers ────────────────────────────────────────────────
  final ctrl = Get.find<CompteController>();
  final themeCtrl = Get.find<ThemeController>();

  // ── Champs du formulaire ───────────────────────────────────────
  final _nomCtrl = TextEditingController();
  final _soldeCtrl = TextEditingController(text: '0');

  TypeCompte _typeCompte = TypeCompte.bancaire;
  int _couleurValue = 0xFF4CAF7A;
  int _iconeCode = Icons.account_balance_rounded.codePoint;
  bool _estEnSauvegarde = false;

  // ── Palettes disponibles ───────────────────────────────────────

  /// Couleurs disponibles pour les comptes
  static const _couleurs = [
    0xFF4CAF7A, // Vert primary
    0xFF3B82F6, // Bleu
    0xFFF59E0B, // Orange
    0xFF8B5CF6, // Violet
    0xFFEF4444, // Rouge
    0xFFEC4899, // Rose
    0xFF06B6D4, // Cyan
    0xFF6B7280, // Gris
  ];

  /// Icônes disponibles par type de compte
  static const _icones = [
    Icons.account_balance_rounded,
    Icons.wallet_rounded,
    Icons.credit_card_rounded,
    Icons.savings_rounded,
    Icons.phone_android_rounded,
    Icons.home_rounded,
    Icons.business_rounded,
    Icons.monetization_on_rounded,
  ];

  // ── Mode modification ──────────────────────────────────────────
  bool get _estModification => widget.compteAModifier != null;

  @override
  void initState() {
    super.initState();
    _initialiserFormulaire();
  }

  void _initialiserFormulaire() {
    final compte = widget.compteAModifier;
    if (compte == null) return;

    _nomCtrl.text = compte.nom;
    _soldeCtrl.text = compte.soldeInitial.toStringAsFixed(0);
    _typeCompte = compte.type;
    _couleurValue = compte.couleurValue;
    _iconeCode = compte.iconeCode;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _soldeCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────
  String? _valider() {
    if (_nomCtrl.text.trim().isEmpty) {
      return 'Le nom du compte est obligatoire';
    }
    if (_nomCtrl.text.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    final solde = double.tryParse(_soldeCtrl.text);
    if (solde == null) {
      return 'Le solde initial doit être un nombre valide';
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

    bool succes;

    if (_estModification) {
      // Modifier le compte existant
      final compteModifie = widget.compteAModifier!.copyWith(
        nom: _nomCtrl.text.trim(),
        type: _typeCompte,
        soldeInitial: double.parse(_soldeCtrl.text),
        couleurValue: _couleurValue,
        iconeCode: _iconeCode,
      );
      succes = await ctrl.modifierCompte(compteModifie);
    } else {
      // Ajouter un nouveau compte
      succes = await ctrl.ajouterCompte(
        nom: _nomCtrl.text.trim(),
        type: _typeCompte,
        soldeInitial: double.parse(_soldeCtrl.text),
        couleurValue: _couleurValue,
        iconeCode: _iconeCode,
      );
    }

    setState(() => _estEnSauvegarde = false);

    if (succes) {
      context.snackbarSucces(
        _estModification
            ? 'Compte modifié avec succès'
            : 'Compte ajouté avec succès',
      );
      Get.back();
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

            // ── Formulaire scrollable ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.paddingPage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Aperçu du compte ───────────────────────
                    _ApercuCompte(
                      nom: _nomCtrl.text.isEmpty
                          ? 'Nouveau compte'
                          : _nomCtrl.text,
                      couleurValue: _couleurValue,
                      iconeCode: _iconeCode,
                      solde: double.tryParse(_soldeCtrl.text) ?? 0,
                      devise: ctrl.devise,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Nom du compte ──────────────────────────
                    _LabelChamp(label: 'Nom du compte', isDark: isDark),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _nomCtrl,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: Compte CIB, Espèces...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary(isDark),
                        ),
                        prefixIcon: Icon(
                          Icons.badge_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Type de compte ─────────────────────────
                    _LabelChamp(label: 'Type de compte', isDark: isDark),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurTypeCompte(
                      typeSelectionne: _typeCompte,
                      onChanged: (type) =>
                          setState(() => _typeCompte = type),
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Solde initial ──────────────────────────
                    _LabelChamp(
                      label: _estModification
                          ? 'Solde initial'
                          : 'Solde de départ',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _soldeCtrl,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary(isDark),
                        ),
                        prefixIcon: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        suffixText: ctrl.devise,
                        suffixStyle: TextStyle(
                          color: AppColors.textSecondary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Couleur ────────────────────────────────
                    _LabelChamp(label: 'Couleur', isDark: isDark),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurCouleur(
                      couleurs: _couleurs,
                      couleurSelectionnee: _couleurValue,
                      onChanged: (val) =>
                          setState(() => _couleurValue = val),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Icône ──────────────────────────────────
                    _LabelChamp(label: 'Icône', isDark: isDark),
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

            // ── Bouton sauvegarde ────────────────────────────────
            Padding(
              padding: AppSpacing.paddingPage,
              child: AppButton(
                label: _estModification
                    ? 'Modifier le compte'
                    : 'Créer le compte',
                onTap: _sauvegarder,
                estEnChargement: _estEnSauvegarde,
                icone: _estModification
                    ? Icons.check_rounded
                    : Icons.add_rounded,
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
        _estModification ? 'Modifier le compte' : 'Nouveau compte',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(isDark),
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Aperçu du compte ───────────────────────────────────────────────

/// Aperçu en temps réel du compte pendant la saisie.
class _ApercuCompte extends StatelessWidget {
  const _ApercuCompte({
    required this.nom,
    required this.couleurValue,
    required this.iconeCode,
    required this.solde,
    required this.devise,
  });

  final String nom;
  final int couleurValue;
  final int iconeCode;
  final double solde;
  final String devise;

  @override
  Widget build(BuildContext context) {
    final couleur = Color(couleurValue);
    final icone = IconData(iconeCode, fontFamily: 'MaterialIcons');

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, couleur.withOpacity(0.75)],
        ),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: [
          BoxShadow(
            color: couleur.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSmall,
              ),
            ),
            child: Icon(icone, color: Colors.white, size: 24),
          ),

          const SizedBox(width: AppSpacing.md),

          // Nom + solde
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$solde $devise',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Label aperçu
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusFull,
              ),
            ),
            child: const Text(
              'Aperçu',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
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

// ── Sélecteur type de compte ───────────────────────────────────────

/// Grille de sélection du type de compte.
class _SelecteurTypeCompte extends StatelessWidget {
  const _SelecteurTypeCompte({
    required this.typeSelectionne,
    required this.onChanged,
    required this.isDark,
  });

  final TypeCompte typeSelectionne;
  final ValueChanged<TypeCompte> onChanged;
  final bool isDark;

  static const _types = [
    (type: TypeCompte.bancaire, label: 'Bancaire',
     icone: Icons.account_balance_rounded),
    (type: TypeCompte.especes, label: 'Espèces',
     icone: Icons.wallet_rounded),
    (type: TypeCompte.mobileMoney, label: 'Mobile Money',
     icone: Icons.phone_android_rounded),
    (type: TypeCompte.epargne, label: 'Épargne',
     icone: Icons.savings_rounded),
    (type: TypeCompte.autre, label: 'Autre',
     icone: Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _types.map((t) {
        final estSelectionne = typeSelectionne == t.type;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(t.type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: estSelectionne
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.card(isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: estSelectionne
                    ? AppColors.primary
                    : AppColors.border(isDark),
                width: estSelectionne ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  t.icone,
                  size: 15,
                  color: estSelectionne
                      ? AppColors.primary
                      : AppColors.textSecondary(isDark),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  t.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: estSelectionne
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: estSelectionne
                        ? AppColors.primary
                        : AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sélecteur couleur ──────────────────────────────────────────────

/// Grille de sélection de couleur.
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
      children: couleurs.map((couleurVal) {
        final estSelectionne = couleurSelectionnee == couleurVal;
        final couleur = Color(couleurVal);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(couleurVal);
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

/// Grille de sélection d'icône.
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
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
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