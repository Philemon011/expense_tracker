import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_colors.dart';
import '../themes/app_spacing.dart';
import '../utils/extensions.dart';

/// Barre de navigation principale de l'app.
///
/// 4 onglets : Accueil / Opérations / Statistiques / Profil
///
/// Utilisation :
///   BottomNavBar(
///     indexActuel: _index,
///     onTap: (index) => setState(() => _index = index),
///   )
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.indexActuel,
    required this.onTap,
  });

  /// Index de l'onglet actuellement sélectionné (0 à 3)
  final int indexActuel;

  /// Callback appelé quand l'utilisateur tape sur un onglet
  final ValueChanged<int> onTap;

  // ── Définition des onglets ─────────────────────────────────────

  static const _onglets = [
    _OngletData(
      label: 'Accueil',
      iconeActive: Icons.home_rounded,
      iconeInactive: Icons.home_outlined,
    ),
    _OngletData(
      label: 'Opérations',
      iconeActive: Icons.receipt_long_rounded,
      iconeInactive: Icons.receipt_long_outlined,
    ),
    _OngletData(
      label: 'Statistiques', // ← Modifier
      iconeActive: Icons.bar_chart_rounded, // ← Modifier
      iconeInactive: Icons.bar_chart_outlined, // ← Modifier
    ),
    _OngletData(
      label: 'Profil',
      iconeActive: Icons.person_rounded,
      iconeInactive: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        // Fond blanc/sombre selon le thème
        color: AppColors.card(isDark),
        // Bordure supérieure très légère
        border: Border(
          top: BorderSide(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
        // Ombre légère vers le haut
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // Ne pas ajouter de padding en haut
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(
              _onglets.length,
              (index) => Expanded(
                child: _OngletItem(
                  data: _onglets[index],
                  estActif: index == indexActuel,
                  onTap: () {
                    // Vibration légère au tap
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                  isDark: isDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget d'un onglet individuel ──────────────────────────────────

/// Un onglet individuel de la bottom nav bar.
class _OngletItem extends StatelessWidget {
  const _OngletItem({
    required this.data,
    required this.estActif,
    required this.onTap,
    required this.isDark,
  });

  final _OngletData data;
  final bool estActif;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icône avec indicateur actif ──────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                // Fond vert très léger si actif
                color: estActif
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Icon(
                estActif ? data.iconeActive : data.iconeInactive,
                size: AppSpacing.navIconSize,
                color: estActif
                    ? AppColors.primary
                    : AppColors.textSecondary(isDark),
              )
                  // Animation scale à l'activation
                  .animate(target: estActif ? 1 : 0)
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.15, 1.15),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  ),
            ),

            const SizedBox(height: 2),

            // ── Label ────────────────────────────────────────────
            // ── Label ────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
  fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: estActif ? FontWeight.w600 : FontWeight.w400,
                color: estActif
                    ? AppColors.primary
                    : AppColors.textSecondary(isDark),
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Données d'un onglet ────────────────────────────────────────────

/// Données statiques d'un onglet de navigation.
class _OngletData {
  const _OngletData({
    required this.label,
    required this.iconeActive,
    required this.iconeInactive,
  });

  /// Label affiché sous l'icône
  final String label;

  /// Icône quand l'onglet est actif (filled)
  final IconData iconeActive;

  /// Icône quand l'onglet est inactif (outlined)
  final IconData iconeInactive;
}
