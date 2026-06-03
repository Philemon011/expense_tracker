import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../utils/extensions.dart';

/// Écran des statistiques — Graphiques et analyses.
/// Contenu complet dans la Phase 6.
class StatistiquesScreen extends StatelessWidget {
  const StatistiquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context.isDark),
      body: const Center(
        child: Text('Statistiques — Phase 6'),
      ),
    );
  }
}