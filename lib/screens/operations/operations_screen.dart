import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../utils/extensions.dart';

/// Écran des opérations — Historique complet.
/// Contenu complet dans la Phase 5.
class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context.isDark),
      body: const Center(
        child: Text('Opérations — Phase 5'),
      ),
    );
  }
}