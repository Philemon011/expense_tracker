import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_spacing.dart';
import '../utils/extensions.dart';

/// Carte réutilisable — bloc visuel de base de l'app.
///
/// Utilisée pour encapsuler n'importe quel contenu
/// dans un conteneur stylisé cohérent.
///
/// Utilisations :
///   // Carte simple
///   CustomCard(child: Text('Contenu'))
///
///   // Carte cliquable
///   CustomCard(
///     onTap: () => naviguer(),
///     child: Text('Appuie ici'),
///   )
///
///   // Carte colorée (ex: carte solde)
///   CustomCard.coloree(
///     couleur: AppColors.primary,
///     child: Text('Solde'),
///   )
class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.couleurFond,
    this.bordureRayon,
    this.afficherOmbre = true,
    this.afficherBordure = false,
  }) : estColoree = false,
       couleurPrincipale = null;

  /// Constructeur nommé — carte avec fond coloré
  ///
  /// Utilisée pour les cartes mises en avant (solde, résumé...)
  const CustomCard.coloree({
    super.key,
    required this.child,
    required Color couleur,
    this.onTap,
    this.padding,
    this.margin,
    this.bordureRayon,
  })  : estColoree = true,
        couleurPrincipale = couleur,
        couleurFond = null,
        afficherOmbre = true,
        afficherBordure = false;

  /// Constructeur nommé — carte transparente (sans fond)
  const CustomCard.transparente({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.bordureRayon,
  })  : estColoree = false,
        couleurPrincipale = null,
        couleurFond = Colors.transparent,
        afficherOmbre = false,
        afficherBordure = false;

  /// Contenu de la carte
  final Widget child;

  /// Action au tap — null = carte non cliquable
  final VoidCallback? onTap;

  /// Padding interne — défaut : AppSpacing.paddingCard
  final EdgeInsetsGeometry? padding;

  /// Margin externe
  final EdgeInsetsGeometry? margin;

  /// Couleur de fond personnalisée
  final Color? couleurFond;

  /// Rayon des coins — défaut : AppSpacing.radiusCard
  final double? bordureRayon;

  /// Affiche une ombre légère sous la carte
  final bool afficherOmbre;

  /// Affiche une bordure légère autour de la carte
  final bool afficherBordure;

  /// Vrai si la carte a un fond coloré (gradient)
  final bool estColoree;

  /// Couleur principale pour les cartes colorées
  final Color? couleurPrincipale;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {

  // Contrôleur pour l'animation de press
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  // ── Gestion du press ───────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  // ── Décoration de la carte ─────────────────────────────────────

  BoxDecoration _decoration(bool isDark) {
    final rayon = widget.bordureRayon ?? AppSpacing.radiusCard;

    // Carte colorée — fond de couleur unie
    if (widget.estColoree && widget.couleurPrincipale != null) {
      return BoxDecoration(
        color: widget.couleurPrincipale,
        borderRadius: BorderRadius.circular(rayon),
        boxShadow: [
          BoxShadow(
            color: widget.couleurPrincipale!.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    // Carte standard — fond blanc/sombre
    return BoxDecoration(
      color: widget.couleurFond ?? AppColors.card(isDark),
      borderRadius: BorderRadius.circular(rayon),
      // Ombre légère
      boxShadow: widget.afficherOmbre
          ? AppSpacing.cardShadow(isDark)
          : null,
      // Bordure légère optionnelle
      border: widget.afficherBordure
          ? Border.all(
              color: AppColors.border(isDark),
              width: 0.5,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: widget.margin,
          decoration: _decoration(isDark),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.bordureRayon ?? AppSpacing.radiusCard,
            ),
            child: Padding(
              padding: widget.padding ?? AppSpacing.paddingCard,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}