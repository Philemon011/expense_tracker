import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ← AJOUTER
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/operation_controller.dart';
import '../themes/app_theme.dart';
import '../screens/main_screen.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,

      // ── Langue française ─────────────────────────────────────
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),

      // ── Delegates de localisation ────────────────────────────
      // OBLIGATOIRES pour le DatePicker, les alertes, etc.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,   // Material en FR
        GlobalWidgetsLocalizations.delegate,    // Widgets de base en FR
        GlobalCupertinoLocalizations.delegate,  // Cupertino en FR
      ],

      // Langues supportées
      supportedLocales: const [
        Locale('fr', 'FR'), // Français — principal
        Locale('en', 'US'), // Anglais — fallback
      ],

      // ── Thèmes ───────────────────────────────────────────────
      theme: AppTheme.themeLight(),
      darkTheme: AppTheme.themeDark(),
      themeMode: ThemeMode.light,

      // ── Controllers globaux ──────────────────────────────────
      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController(), permanent: true);
        Get.put(NavigationController(), permanent: true);
        Get.put(OperationController(), permanent: true);
      }),

      // ── Écran principal ──────────────────────────────────────
      home: const MainScreen(),
    );
  }
}