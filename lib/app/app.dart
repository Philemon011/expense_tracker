import 'package:expense_tracker/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/operation_controller.dart';
import '../controllers/compte_controller.dart';
import '../controllers/statistique_controller.dart';
import '../controllers/budget_controller.dart';
import '../themes/app_theme.dart';
import '../screens/main_screen.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  // Dans build() — remplace le home statique par ceci :

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

    // ── ThemeMode réactif ────────────────────────────────────
    // Suit automatiquement ThemeController
    themeMode: ThemeMode.system,    // ← Remplacer light par system

    defaultTransition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 300),
    scrollBehavior: _AppScrollBehavior(),

    initialBinding: BindingsBuilder(() {
      Get.put(ThemeController(), permanent: true);
      Get.put(NavigationController(), permanent: true);
      Get.put(OperationController(), permanent: true);
      Get.put(CompteController(), permanent: true);
      Get.put(StatistiqueController(), permanent: true);
      Get.put(BudgetController(), permanent: true);
      Get.put(NotificationController(), permanent: true);
    }),

    builder: (context, child) {

      // Générer les notifications au démarrage
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().verifierEtGenerer();
    }
  });
      final isDark =
          Theme.of(context).brightness == Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      );
      return child!;
    },

    home: const MainScreen(),
  );
}
}

/// Scroll behavior sans effet glow Android.
///
/// Par défaut Android affiche un glow bleu en fin de scroll.
/// Ce behavior le supprime pour un rendu plus premium.
class _AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Aucun effet glow — style iOS
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Physics bouncing — comme iOS
    return const BouncingScrollPhysics();
  }
}