import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/notification_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';

/// Écran des notifications in-app.
///
/// Affiche :
///   - Notifications non lues en premier
///   - Notifications lues ensuite
///   - Actions : marquer lu, supprimer, tout marquer lu
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),

        // ── AppBar ───────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: AppColors.background(isDark),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary(isDark),
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          actions: [
            // Bouton tout marquer comme lu
            if (ctrl.aDesNonLues)
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.md,
                ),
                child: GestureDetector(
                  onTap: () async {
                    await ctrl.toutMarquerCommeLu();
                    context.snackbarSucces(
                      'Toutes les notifications marquées comme lues',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                    child: const Text(
                      'Tout lire',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

            // Bouton tout supprimer
            if (!ctrl.estVide)
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.md,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final confirme = await context.confirmer(
                      titre: 'Tout supprimer',
                      message:
                          'Toutes les notifications seront supprimées.',
                      texteBoutonConfirmer: 'Supprimer',
                    );
                    if (confirme) {
                      await ctrl.toutSupprimer();
                      context.snackbarSucces(
                        'Notifications supprimées',
                      );
                    }
                  },
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.alerte,
                    size: 22,
                  ),
                ),
              ),
          ],
        ),

        // ── Corps ────────────────────────────────────────────────
        body: ctrl.estVide
            ? _EtatVide(isDark: isDark)
            : SafeArea(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.md,
                    AppSpacing.pagePaddingHorizontal,
                    100,
                  ),
                  children: [

                    // ── Non lues ─────────────────────────────────
                    if (ctrl.nonLues.isNotEmpty) ...[
                      _TitreSection(
                        titre: 'Non lues',
                        badge: ctrl.nombreNonLues.toString(),
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...ctrl.nonLues.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: _NotificationTile(
                            notification: entry.value,
                            isDark: isDark,
                            delaiAnimation: Duration(
                              milliseconds: 50 * entry.key,
                            ),
                            onTap: () => ctrl.marquerCommeLue(
                              entry.value.id,
                            ),
                            onSupprimer: () =>
                                ctrl.supprimerNotification(
                              entry.value.id,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // ── Lues ─────────────────────────────────────
                    if (ctrl.lues.isNotEmpty) ...[
                      _TitreSection(
                        titre: 'Lues',
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...ctrl.lues.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: _NotificationTile(
                            notification: entry.value,
                            isDark: isDark,
                            delaiAnimation: Duration(
                              milliseconds: 50 * entry.key,
                            ),
                            onTap: null,
                            onSupprimer: () =>
                                ctrl.supprimerNotification(
                              entry.value.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      );
    });
  }
}

// ── Titre de section ───────────────────────────────────────────────

class _TitreSection extends StatelessWidget {
  const _TitreSection({
    required this.titre,
    required this.isDark,
    this.badge,
  });

  final String titre;
  final String? badge;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          titre,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(isDark),
            letterSpacing: 0.5,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusFull,
              ),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Tuile de notification ──────────────────────────────────────────

/// Tuile individuelle d'une notification.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onSupprimer,
    this.onTap,
    this.delaiAnimation = Duration.zero,
  });

  final NotificationModel notification;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback onSupprimer;
  final Duration delaiAnimation;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onSupprimer(),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.alerte,
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: AppSpacing.paddingCard,
          decoration: BoxDecoration(
            // Fond légèrement coloré si non lue
            color: notification.estLue
                ? AppColors.card(isDark)
                : notification.couleurFond.withOpacity(
                    isDark ? 0.15 : 1.0,
                  ),
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppSpacing.cardShadow(isDark),
            border: notification.estLue
                ? null
                : Border.all(
                    color: notification.couleur.withOpacity(0.2),
                    width: 1,
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Icône ─────────────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.couleur.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSmall,
                  ),
                ),
                child: Icon(
                  notification.icone,
                  size: 20,
                  color: notification.couleur,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── Contenu ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Titre + point non lu
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: notification.estLue
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ),
                        // Point vert si non lue
                        if (!notification.estLue)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification.couleur,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: AppColors.textSecondary(isDark),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Date relative
                    Text(
                      notification.date.relatif,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: AppColors.textSecondary(isDark)
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 350),
        )
        .slideX(
          begin: 0.05,
          end: 0,
          delay: delaiAnimation,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
  }
}

// ── État vide ──────────────────────────────────────────────────────

class _EtatVide extends StatelessWidget {
  const _EtatVide({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Aucune notification',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
              ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Vos alertes budgets et résumés\napparaîtront ici.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 400),
              ),
        ],
      ),
    );
  }
}