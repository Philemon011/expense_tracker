import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../utils/extensions.dart';

/// Écran du profil — Réglages et préférences.
/// Contenu complet dans la Phase 7.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context.isDark),
      body: const Center(
        child: Text('Profil — Phase 7'),
      ),
    );
  }
}