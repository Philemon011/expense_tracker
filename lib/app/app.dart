import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/operation_controller.dart';
import '../controllers/compte_controller.dart';
import '../controllers/statistique_controller.dart';    // ← AJOUTER
import '../themes/app_theme.dart';
import '../screens/main_screen.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      theme: AppTheme.themeLight(),
      darkTheme: AppTheme.themeDark(),
      themeMode: ThemeMode.light,

      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController(), permanent: true);
        Get.put(NavigationController(), permanent: true);
        Get.put(OperationController(), permanent: true);
        Get.put(CompteController(), permanent: true);
        Get.put(StatistiqueController(), permanent: true); // ← AJOUTER
      }),

      home: const MainScreen(),
    );
  }
}