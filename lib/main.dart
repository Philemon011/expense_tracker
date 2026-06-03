import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialiser la locale française pour intl
  // Nécessaire pour DateFormat en français
  await initializeDateFormatting('fr_FR', null);

  // Initialiser Hive
  await Hive.initFlutter();

  // Initialiser HiveService — adapters + boîtes + données par défaut
  await HiveService.initialiser();

  // Lancer l'application
  runApp(const ExpenseTrackerApp());
}