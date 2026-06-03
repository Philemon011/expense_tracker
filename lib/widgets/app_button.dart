import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_colors.dart';
import '../themes/app_spacing.dart';
import '../themes/app_text_styles.dart';
import '../utils/extensions.dart';

/// Variantes disponibles du bouton
enum VarianteButton { primaire, secondaire, danger }

/// Bouton principal réutilisable de l'application.
///
/// Variantes :
///   - primaire  → fond vert, texte blanc (action principale)
///   - secondaire → fond gris, texte sombre (action secondaire)
///   - danger    → fond rouge, texte blanc (action destructive)
///
/// Utilisation :
///   AppButton(
///     label: 'Ajouter',
///     onTap: () => _ajouter(),
///   )
///
///   AppButton.secondaire(
///     label: 'Annuler',
///     onTap: () => context.retour(),
///   )
///
///   AppButton(
///     label: 'Enregistrement...',
///     estEnChargement: true,
///     onTap: null,
///   )
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variante = VarianteButton.primaire,
    this.estEnChargement = false,
    this.icone,
    this.largeurComplete = true,
    this.hauteur = AppSpacing.buttonHeight,
  });

  /// Constructeur nommé — variante secondaire
  const AppButton.secondaire({
    super.key,
    required this.label,
    required this.onTap,
    this.estEnChargement = false,
    this.icone,
    this.largeurComplete = true,
    this.hauteur = AppSpacing.buttonHeight,
  }) : variante = VarianteButton.secondaire;

  /// Constructeur nommé — variante danger
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onTap,
    this.estEnChargement = false,
    this.icone,
    this.largeurComplete = true,
    this.hauteur = AppSpacing.buttonHeight,
  }) : variante = VarianteButton.danger;

  /// Texte affiché sur le bouton
  final String label;

  /// Action au tap — null = bouton désactivé
  final VoidCallback? onTap;

  /// Variante visuelle du bouton
  final VarianteButton variante;

  /// Si vrai, affiche un spinner de chargement
  final bool estEnChargement;

  /// Icône optionnelle à gauche du label
  final IconData? icone;

  /// Si vrai, le bouton prend toute la largeur disponible
  final bool largeurComplete;

  /// Hauteur du bouton
  final double hauteur;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {

  // Contrôleur pour l'animation de press
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  // ── Logique de press ───────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null || widget.estEnChargement) return;
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    if (widget.onTap == null || widget.estEnChargement) return;
    widget.onTap!();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  // ── Couleurs selon la variante ─────────────────────────────────

  Color _couleurFond(bool isDark) {
    if (widget.onTap == null || widget.estEnChargement) {
      // État désactivé — toujours gris
      return AppColors.textSecondary(isDark).withOpacity(0.15);
    }

    switch (widget.variante) {
      case VarianteButton.primaire:
        return AppColors.primary;
      case VarianteButton.secondaire:
        return AppColors.input(isDark);
      case VarianteButton.danger:
        return AppColors.alerte;
    }
  }

  Color _couleurTexte(bool isDark) {
    if (widget.onTap == null || widget.estEnChargement) {
      return AppColors.textSecondary(isDark);
    }

    switch (widget.variante) {
      case VarianteButton.primaire:
        return Colors.white;
      case VarianteButton.secondaire:
        return AppColors.textPrimary(isDark);
      case VarianteButton.danger:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.largeurComplete ? double.infinity : null,
          height: widget.hauteur,
          decoration: BoxDecoration(
            color: _couleurFond(isDark),
            borderRadius: AppSpacing.borderRadiusButton,
          ),
          child: _buildContenu(isDark),
        ),
      ),
    );
  }

  // ── Contenu du bouton ──────────────────────────────────────────

  Widget _buildContenu(bool isDark) {
    // État chargement — afficher un spinner
    if (widget.estEnChargement) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              _couleurTexte(isDark),
            ),
          ),
        ),
      );
    }

    // État normal — icône + label
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône optionnelle
          if (widget.icone != null) ...[
            Icon(
              widget.icone,
              size: 20,
              color: _couleurTexte(isDark),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Label du bouton
          Text(
            widget.label,
            style: widget.variante == VarianteButton.primaire
                ? AppTextStyles.boutonPrimaire()
                : AppTextStyles.boutonSecondaire(isDark).copyWith(
                    color: _couleurTexte(isDark),
                  ),
          ),
        ],
      ),
    )
        // Animation d'entrée du contenu
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 150));
  }
}