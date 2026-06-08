import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Orientation portrait uniquement ──────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Style de la status bar ───────────────────────────────────
  // Icônes sombres sur fond clair par défaut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Bords transparents ───────────────────────────────────────
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // ── Locale française pour intl ───────────────────────────────
  await initializeDateFormatting('fr_FR', null);

  // ── Initialiser Hive ─────────────────────────────────────────
  await Hive.initFlutter();
  await HiveService.initialiser();

  runApp(const ExpenseTrackerApp());
}