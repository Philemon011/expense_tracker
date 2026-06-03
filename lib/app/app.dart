import 'package:flutter/material.dart';
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
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),
      theme: AppTheme.themeLight(),
      darkTheme: AppTheme.themeDark(),
      themeMode: ThemeMode.light,

      initialBinding: BindingsBuilder(() {
        // Controllers globaux — permanent: true = jamais supprimés
        Get.put(ThemeController(), permanent: true);
        Get.put(NavigationController(), permanent: true);
        Get.put(OperationController(), permanent: true);
      }),

      home: const MainScreen(),
    );
  }
}