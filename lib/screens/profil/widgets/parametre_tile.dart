import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';

/// Tuile de paramètre réutilisable.
///
/// Utilisée dans l'écran profil pour chaque ligne de paramètre.
///
/// Utilisation :
///   ParametreTile(
///     icone: Icons.payments_rounded,
///     couleurIcone: AppColors.primary,
///     titre: 'Devise',
///     sousTitre: 'FCFA',
///     isDark: isDark,
///     onTap: () => _modifierDevise(),
///     trailing: Icon(Icons.chevron_right_rounded),
///   )
class ParametreTile extends StatefulWidget {
  const ParametreTile({
    super.key,
    required this.icone,
    required this.couleurIcone,
    required this.titre,
    required this.isDark,
    this.sousTitre,
    this.onTap,
    this.trailing,
    this.estDangereux = false,
  });

  /// Icône à gauche
  final IconData icone;

  /// Couleur de l'icône et de son fond
  final Color couleurIcone;

  /// Titre principal
  final String titre;

  /// Sous-titre optionnel
  final String? sousTitre;

  /// Action au tap
  final VoidCallback? onTap;

  /// Widget à droite — switch, icône, badge...
  final Widget? trailing;

  final bool isDark;

  /// Si vrai — titre en rouge (zone danger)
  final bool estDangereux;

  @override
  State<ParametreTile> createState() => _ParametreTileState();
}

class _ParametreTileState extends State<ParametreTile>
    with SingleTickerProviderStateMixin {

  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    _pressCtrl.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [

              // ── Icône colorée ──────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.estDangereux
                      ? AppColors.alerte.withOpacity(0.1)
                      : widget.couleurIcone.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSmall,
                  ),
                ),
                child: Icon(
                  widget.icone,
                  size: 18,
                  color: widget.estDangereux
                      ? AppColors.alerte
                      : widget.couleurIcone,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── Titre + sous-titre ─────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titre,
                      style: TextStyle(
  fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.estDangereux
                            ? AppColors.alerte
                            : AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                    if (widget.sousTitre != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.sousTitre!,
                        style: TextStyle(
  fontFamily: 'Outfit',
                          fontSize: 12,
                          color: AppColors.textSecondary(
                            widget.isDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Trailing ───────────────────────────────────
              if (widget.trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}