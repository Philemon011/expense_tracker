import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import '../themes/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'accueil/accueil_screen.dart';
import 'operations/operations_screen.dart';
import 'comptes/comptes_screen.dart';        // ← Remplacer StatistiquesScreen
import 'statistiques/statistiques_screen.dart';
import 'profil/profil_screen.dart';

/// Écran racine de l'application.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavigationController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDark;
      final indexActuel = navCtrl.indexActuel;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),
        body: IndexedStack(
          index: indexActuel,
          children: const [
            AccueilScreen(),       // 0 — Accueil
            OperationsScreen(),    // 1 — Opérations
            ComptesScreen(),       // 2 — Comptes  ← ICI
            ProfilScreen(),        // 3 — Profil
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          indexActuel: indexActuel,
          onTap: navCtrl.allerA,
        ),
      );
    });
  }
}