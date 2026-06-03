import 'package:expense_tracker/screens/accueil/widgets/card_solde.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../utils/extensions.dart';

/// Écran d'accueil — Dashboard principal.
/// Contenu complet dans la Phase 4.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context.isDark),
      body: const Center(
        child: CardSolde(),
      ),
    );
  }
}