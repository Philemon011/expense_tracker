import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import '../themes/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

// Import des écrans principaux
// (écrans vides pour l'instant — remplis dans les phases suivantes)
import 'accueil/accueil_screen.dart';
import 'operations/operations_screen.dart';
import 'statistiques/statistiques_screen.dart';
import 'profil/profil_screen.dart';

/// Écran racine de l'application.
///
/// Contient :
///   - La bottom navigation bar persistante
///   - Un IndexedStack avec les 4 écrans principaux
///
/// IndexedStack garde tous les écrans en mémoire —
/// pas de rebuild quand on change d'onglet.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer les controllers
    final navCtrl = Get.find<NavigationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final indexActuel = navCtrl.indexActuel;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),

        // ── Corps — les 4 écrans ─────────────────────────────
        body: IndexedStack(
          index: indexActuel,
          children: const [
            AccueilScreen(),
            OperationsScreen(),
            StatistiquesScreen(),
            ProfilScreen(),
          ],
        ),

        // ── Bottom Navigation Bar ────────────────────────────
        bottomNavigationBar: BottomNavBar(
          indexActuel: indexActuel,
          onTap: navCtrl.allerA,
        ),
      );
    });
  }
}