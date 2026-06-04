import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/compte_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../models/compte_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../utils/formatters.dart';
import '../ajouter_compte_screen.dart';

/// Carte d'affichage d'un compte financier.
///
/// Affiche :
///   - Icône + nom du compte
///   - Type de compte
///   - Solde réel calculé
///   - Badge "Principal" si compte principal
///   - Menu d'actions (modifier, principal, archiver)
///
/// Utilisation :
///   CompteCard(
///     compte: compte,
///     solde: 250000.0,
///     devise: 'FCFA',
///     delaiAnimation: Duration(milliseconds: 100),
///   )
class CompteCard extends StatelessWidget {
  const CompteCard({
    super.key,
    required this.compte,
    required this.solde,
    required this.devise,
    this.delaiAnimation = Duration.zero,
  });

  /// Le compte à afficher
  final CompteModel compte;

  /// Solde réel calculé
  final double solde;

  /// Devise de l'app
  final String devise;

  /// Délai animation entrée
  final Duration delaiAnimation;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final isDark = themeCtrl.isDark;

    return GestureDetector(
      onTap: () => _ouvrirModification(context),
      child: Container(
        decoration: BoxDecoration(
          // Dégradé avec la couleur du compte
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              compte.couleur,
              compte.couleur.withOpacity(0.75),
            ],
          ),
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: [
            BoxShadow(
              color: compte.couleur.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [

            // ── Cercle décoratif ───────────────────────────────
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // ── Contenu principal ──────────────────────────────
            Padding(
              padding: AppSpacing.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header : icône + nom + menu ───────────────
                  Row(
                    children: [

                      // Icône du compte
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                        ),
                        child: Icon(
                          compte.icone,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      // Nom + type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              compte.nom,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              compte.typeNom,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu d'actions
                      _MenuActions(compte: compte),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Solde ──────────────────────────────────────
                  Text(
                    'Solde actuel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    Formatters.montant(solde, devise),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Footer : badge principal + nb opérations ───
                  Row(
                    children: [

                      // Badge principal
                      if (compte.estPrincipal)
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Principal',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(),

                      // Nombre d'opérations
                      Text(
                        '${Get.find<CompteController>().nombreOperations(compte.id)} opération(s)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }

  /// Ouvre l'écran de modification du compte.
  void _ouvrirModification(BuildContext context) {
    Get.to(
      () => AjouterCompteScreen(compteAModifier: compte),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 400),
    );
  }
}

// ── Menu d'actions ─────────────────────────────────────────────────

/// Menu popup avec les actions disponibles sur un compte.
class _MenuActions extends StatelessWidget {
  const _MenuActions({required this.compte});

  final CompteModel compte;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CompteController>();

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.white.withOpacity(0.85),
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      color: context.couleurCarte,
      elevation: 8,
      onSelected: (action) async {
        HapticFeedback.selectionClick();

        switch (action) {

          case 'modifier':
            Get.to(
              () => AjouterCompteScreen(compteAModifier: compte),
              transition: Transition.downToUp,
              duration: const Duration(milliseconds: 400),
            );
            break;

          case 'principal':
            await ctrl.definirComptePrincipal(compte.id);
            context.snackbarSucces(
              '${compte.nom} est maintenant le compte principal',
            );
            break;

          case 'archiver':
            final confirme = await context.confirmer(
              titre: 'Archiver le compte',
              message:
                  'Le compte sera masqué mais ses opérations '
                  'seront conservées.',
              texteBoutonConfirmer: 'Archiver',
            );
            if (confirme) {
              final succes = await ctrl.archiverCompte(compte.id);
              if (succes) {
                context.snackbarSucces('Compte archivé');
              } else {
                context.snackbarErreur(
                  'Impossible d\'archiver le compte principal',
                );
              }
            }
            break;
        }
      },
      itemBuilder: (_) => [

        // Modifier
        PopupMenuItem(
          value: 'modifier',
          child: _ItemMenu(
            icone: Icons.edit_rounded,
            label: 'Modifier',
            couleur: context.couleurTexte,
          ),
        ),

        // Définir comme principal (si pas déjà principal)
        if (!compte.estPrincipal)
          PopupMenuItem(
            value: 'principal',
            child: _ItemMenu(
              icone: Icons.star_rounded,
              label: 'Définir comme principal',
              couleur: AppColors.primary,
            ),
          ),

        // Archiver (si pas principal)
        if (!compte.estPrincipal)
          PopupMenuItem(
            value: 'archiver',
            child: _ItemMenu(
              icone: Icons.archive_rounded,
              label: 'Archiver',
              couleur: AppColors.alerte,
            ),
          ),
      ],
    );
  }
}

/// Item individuel du menu popup.
class _ItemMenu extends StatelessWidget {
  const _ItemMenu({
    required this.icone,
    required this.label,
    required this.couleur,
  });

  final IconData icone;
  final String label;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: couleur),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: couleur,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}