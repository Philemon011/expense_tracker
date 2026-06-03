import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/operation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/operation_model.dart';
import '../../models/categorie_model.dart';
import '../../models/compte_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';

/// Écran d'ajout et de modification d'une opération.
///
/// Si [operationAModifier] est fourni → mode modification.
/// Sinon → mode ajout.
///
/// Utilisation :
///   // Ajout
///   Get.to(() => const AjouterOperationScreen())
///
///   // Modification
///   Get.to(() => AjouterOperationScreen(
///     operationAModifier: operation,
///   ))
class AjouterOperationScreen extends StatefulWidget {
  const AjouterOperationScreen({
    super.key,
    this.operationAModifier,
  });

  /// Si non null — mode modification
  final OperationModel? operationAModifier;

  @override
  State<AjouterOperationScreen> createState() =>
      _AjouterOperationScreenState();
}

class _AjouterOperationScreenState
    extends State<AjouterOperationScreen> {

  // ── Controllers ────────────────────────────────────────────────
  final ctrl = Get.find<OperationController>();
  final themeCtrl = Get.find<ThemeController>();

  // ── État du formulaire ─────────────────────────────────────────

  /// Montant saisi — stocké en string pour le clavier custom
  String _montantStr = '0';

  /// Type d'opération sélectionné
  TypeOperation _type = TypeOperation.sortie;

  /// Catégorie sélectionnée
  CategorieModel? _categorieSelectionnee;

  /// Compte sélectionné
  CompteModel? _compteSelectionne;

  /// Date sélectionnée
  DateTime _date = DateTime.now();

  /// Note optionnelle
  final _noteCtrl = TextEditingController();

  /// Vrai pendant la sauvegarde
  bool _estEnSauvegarde = false;

  // ── Mode modification ──────────────────────────────────────────

  bool get _estModification => widget.operationAModifier != null;

  @override
  void initState() {
    super.initState();
    _initialiserFormulaire();
  }

  /// Initialise le formulaire avec les données existantes
  /// si on est en mode modification.
  void _initialiserFormulaire() {
    final op = widget.operationAModifier;
    if (op == null) {
      // Mode ajout — compte principal par défaut
      _compteSelectionne = ctrl.comptes.isNotEmpty
          ? ctrl.comptes.first
          : null;
      return;
    }

    // Mode modification — pré-remplir les champs
    _montantStr = op.montant.toStringAsFixed(0);
    _type = op.type;
    _categorieSelectionnee = ctrl.categorieParId(op.categorieId);
    _compteSelectionne = ctrl.compteParId(op.compteId);
    _date = op.date;
    _noteCtrl.text = op.note ?? '';
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Clavier custom ─────────────────────────────────────────────

  /// Gère l'appui sur une touche du clavier custom.
  void _onToucheClavier(String touche) {
    HapticFeedback.selectionClick();
    setState(() {
      if (touche == 'C') {
        // Effacer tout
        _montantStr = '0';
      } else if (touche == '⌫') {
        // Effacer le dernier caractère
        if (_montantStr.length <= 1) {
          _montantStr = '0';
        } else {
          _montantStr = _montantStr.substring(
            0,
            _montantStr.length - 1,
          );
        }
      } else if (touche == '.') {
        // Ajouter la virgule si pas déjà présente
        if (!_montantStr.contains('.')) {
          _montantStr = '$_montantStr.';
        }
      } else {
        // Chiffre — limiter à 10 caractères
        if (_montantStr == '0') {
          _montantStr = touche;
        } else if (_montantStr.length < 10) {
          _montantStr = '$_montantStr$touche';
        }
      }
    });
  }

  /// Retourne le montant parsé depuis la string
  double get _montant => double.tryParse(_montantStr) ?? 0.0;

  // ── Validation ─────────────────────────────────────────────────

  /// Valide le formulaire et retourne un message d'erreur
  /// si invalide, null si valide.
  String? _valider() {
    if (_montant <= 0) return 'Le montant doit être supérieur à 0';
    if (_categorieSelectionnee == null) return 'Choisissez une catégorie';
    if (_compteSelectionne == null) return 'Choisissez un compte';
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
    final opModifiee = widget.operationAModifier!.copyWith(
      montant: _montant,
      type: _type,
      categorieId: _categorieSelectionnee!.id,
      compteId: _compteSelectionne!.id,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    succes = await ctrl.modifierOperation(opModifiee);
  } else {
    succes = await ctrl.ajouterOperation(
      montant: _montant,
      type: _type,
      categorieId: _categorieSelectionnee!.id,
      compteId: _compteSelectionne!.id,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
  }

  setState(() => _estEnSauvegarde = false);

  if (succes) {
    // Rafraîchir AVANT de fermer l'écran
    await ctrl.rafraichir();

    context.snackbarSucces(
      _estModification
          ? 'Opération modifiée avec succès'
          : 'Opération ajoutée avec succès',
    );
    Get.back();
  } else {
    context.snackbarErreur('Une erreur est survenue');
  }
}

  // ── Date picker ────────────────────────────────────────────────

  Future<void> _choisirDate() async {
  final date = await showDatePicker(
    context: context,
    initialDate: _date,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    // Plus besoin de locale ici — géré dans GetMaterialApp
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.card(themeCtrl.isDark),
          onSurface: AppColors.textPrimary(themeCtrl.isDark),
        ),
      ),
      child: child!,
    ),
  );

  if (date != null) {
    setState(() => _date = date);
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

                    // ── Sélecteur type entrée/sortie ───────────
                    _SelecteurType(
                      typeSelectionne: _type,
                      onChanged: (type) {
                        setState(() {
                          _type = type;
                          // Réinitialiser la catégorie
                          // si incompatible avec le nouveau type
                          if (_categorieSelectionnee != null) {
                            final compatible = type == TypeOperation.entree
                                ? _categorieSelectionnee!.accepteEntree
                                : _categorieSelectionnee!.accepteSortie;
                            if (!compatible) {
                              _categorieSelectionnee = null;
                            }
                          }
                        });
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Affichage montant ──────────────────────
                    _AffichageMontant(
                      montantStr: _montantStr,
                      type: _type,
                      devise: ctrl.devise,
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Clavier custom ─────────────────────────
                    _ClavierCustom(onTouche: _onToucheClavier),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Sélecteur catégorie ────────────────────
                    _LabelChamp(label: 'Catégorie', isDark: isDark),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurCategorie(
                      categories: _type == TypeOperation.entree
                          ? ctrl.categories
                              .where((c) => c.accepteEntree)
                              .toList()
                          : ctrl.categories
                              .where((c) => c.accepteSortie)
                              .toList(),
                      categorieSelectionnee: _categorieSelectionnee,
                      onChanged: (cat) =>
                          setState(() => _categorieSelectionnee = cat),
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Sélecteur compte ───────────────────────
                    _LabelChamp(label: 'Compte', isDark: isDark),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurCompte(
                      comptes: ctrl.comptes,
                      compteSelectionne: _compteSelectionne,
                      devise: ctrl.devise,
                      onChanged: (compte) =>
                          setState(() => _compteSelectionne = compte),
                      isDark: isDark,
                      ctrl: ctrl,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Sélecteur date ─────────────────────────
                    _LabelChamp(label: 'Date', isDark: isDark),
                    const SizedBox(height: AppSpacing.sm),
                    _SelecteurDate(
                      date: _date,
                      onTap: _choisirDate,
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Note optionnelle ───────────────────────
                    _LabelChamp(
                      label: 'Note (optionnel)',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ChampNote(
                      controller: _noteCtrl,
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
                    ? 'Modifier l\'opération'
                    : 'Ajouter l\'opération',
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

  /// AppBar de l'écran
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
        _estModification ? 'Modifier' : 'Nouvelle opération',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(isDark),
        ),
      ),
      centerTitle: true,
      // Bouton supprimer en mode modification
      actions: _estModification
          ? [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.alerte,
                ),
                onPressed: _confirmerSuppression,
              ),
            ]
          : null,
    );
  }

  /// Confirme et exécute la suppression en mode modification.
  Future<void> _confirmerSuppression() async {
    final confirme = await context.confirmer(
      titre: 'Supprimer l\'opération',
      message: 'Cette action est irréversible.',
      texteBoutonConfirmer: 'Supprimer',
    );

    if (confirme) {
      await ctrl.supprimerOperation(widget.operationAModifier!.id);
      context.snackbarSucces('Opération supprimée');
      Get.back();
    }
  }
}

// ── Sélecteur type entrée/sortie ───────────────────────────────────

/// Radio cards pour choisir entre entrée et sortie.
class _SelecteurType extends StatelessWidget {
  const _SelecteurType({
    required this.typeSelectionne,
    required this.onChanged,
    required this.isDark,
  });

  final TypeOperation typeSelectionne;
  final ValueChanged<TypeOperation> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Carte Dépense
        Expanded(
          child: _RadioCard(
            label: 'Dépense',
            icone: Icons.arrow_upward_rounded,
            couleur: AppColors.sortie,
            estSelectionne: typeSelectionne == TypeOperation.sortie,
            onTap: () => onChanged(TypeOperation.sortie),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Carte Revenu
        Expanded(
          child: _RadioCard(
            label: 'Revenu',
            icone: Icons.arrow_downward_rounded,
            couleur: AppColors.entree,
            estSelectionne: typeSelectionne == TypeOperation.entree,
            onTap: () => onChanged(TypeOperation.entree),
            isDark: isDark,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: -0.1, end: 0);
  }
}

/// Carte radio individuelle pour le type d'opération.
class _RadioCard extends StatelessWidget {
  const _RadioCard({
    required this.label,
    required this.icone,
    required this.couleur,
    required this.estSelectionne,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final IconData icone;
  final Color couleur;
  final bool estSelectionne;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: estSelectionne
              ? couleur.withOpacity(0.12)
              : AppColors.card(isDark),
          borderRadius: AppSpacing.borderRadiusCard,
          border: Border.all(
            color: estSelectionne ? couleur : AppColors.border(isDark),
            width: estSelectionne ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 18, color: couleur),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: estSelectionne
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: estSelectionne
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

// ── Affichage montant ──────────────────────────────────────────────

/// Grand affichage du montant saisi.
class _AffichageMontant extends StatelessWidget {
  const _AffichageMontant({
    required this.montantStr,
    required this.type,
    required this.devise,
    required this.isDark,
  });

  final String montantStr;
  final TypeOperation type;
  final String devise;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final couleur = type == TypeOperation.entree
        ? AppColors.entree
        : AppColors.sortie;

    return Center(
      child: Column(
        children: [
          // Montant
          Text(
            '$montantStr $devise',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: couleur,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Montant formaté en dessous
          Text(
            Formatters.montant(
              double.tryParse(montantStr) ?? 0,
              devise,
            ),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clavier custom ─────────────────────────────────────────────────

/// Clavier numérique custom pour saisir le montant.
class _ClavierCustom extends StatelessWidget {
  const _ClavierCustom({required this.onTouche});

  final ValueChanged<String> onTouche;

  // Disposition des touches
  static const _touches = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      children: _touches.map((rangee) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: rangee.map((touche) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: _Touche(
                    label: touche,
                    onTap: () => onTouche(touche),
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// Touche individuelle du clavier custom.
class _Touche extends StatelessWidget {
  const _Touche({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final estEffacer = label == '⌫';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: estEffacer
              ? AppColors.alerte.withOpacity(0.1)
              : AppColors.card(isDark),
          borderRadius: AppSpacing.borderRadiusButton,
          boxShadow: AppSpacing.cardShadow(isDark),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: estEffacer ? 20 : 22,
              fontWeight: FontWeight.w500,
              color: estEffacer
                  ? AppColors.alerte
                  : AppColors.textPrimary(isDark),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sélecteur catégorie ────────────────────────────────────────────

/// Grille de sélection des catégories.
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
      height: 100,
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
                  // Icône
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat.couleur.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      cat.icone,
                      size: 20,
                      color: cat.couleur,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Nom
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

// ── Sélecteur compte ───────────────────────────────────────────────

/// Liste horizontale de sélection des comptes.
class _SelecteurCompte extends StatelessWidget {
  const _SelecteurCompte({
    required this.comptes,
    required this.compteSelectionne,
    required this.devise,
    required this.onChanged,
    required this.isDark,
    required this.ctrl,
  });

  final List<CompteModel> comptes;
  final CompteModel? compteSelectionne;
  final String devise;
  final ValueChanged<CompteModel> onChanged;
  final bool isDark;
  final OperationController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: comptes.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final compte = comptes[index];
          final estSelectionne = compteSelectionne?.id == compte.id;
          final solde = ctrl.soldeCompte(compte.id);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(compte);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: estSelectionne
                    ? compte.couleur.withOpacity(0.12)
                    : AppColors.card(isDark),
                borderRadius: AppSpacing.borderRadiusCard,
                border: Border.all(
                  color: estSelectionne
                      ? compte.couleur
                      : AppColors.border(isDark),
                  width: estSelectionne ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Icône compte
                  Icon(
                    compte.icone,
                    size: 18,
                    color: compte.couleur,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nom du compte
                      Text(
                        compte.nom,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      // Solde du compte
                      Text(
                        Formatters.montant(solde, devise),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
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

// ── Sélecteur date ─────────────────────────────────────────────────

/// Champ de sélection de la date.
class _SelecteurDate extends StatelessWidget {
  const _SelecteurDate({
    required this.date,
    required this.onTap,
    required this.isDark,
  });

  final DateTime date;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingListItem,
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: AppSpacing.borderRadiusInput,
          border: Border.all(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              date.complet,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Champ note ─────────────────────────────────────────────────────

/// Champ de saisie de la note optionnelle.
class _ChampNote extends StatelessWidget {
  const _ChampNote({
    required this.controller,
    required this.isDark,
  });

  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      maxLength: 200,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary(isDark),
      ),
      decoration: InputDecoration(
        hintText: 'Ajouter une note...',
        hintStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.card(isDark),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        counterStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 11,
        ),
      ),
    );
  }
}

// ── Label de champ ─────────────────────────────────────────────────

/// Label au-dessus d'un champ de formulaire.
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