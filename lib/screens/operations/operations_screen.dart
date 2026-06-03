import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/operation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/operation_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../accueil/widgets/operation_tile.dart';
import 'ajouter_operation_screen.dart';
import 'widgets/filtre_bar.dart';

/// Écran historique complet des opérations.
///
/// Fonctionnalités :
///   - Liste complète groupée par date
///   - Recherche par note en temps réel
///   - Filtres : type, mois, catégorie
///   - Résumé total filtré
///   - Swipe pour supprimer
class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {

  // ── Controllers ────────────────────────────────────────────────
  final ctrl = Get.find<OperationController>();
  final themeCtrl = Get.find<ThemeController>();

  // ── État des filtres ───────────────────────────────────────────

  /// Texte de recherche
  final _searchCtrl = TextEditingController();
  String _recherche = '';

  /// Filtre par type — null = tous
  TypeOperation? _typeFiltre;

  /// Filtre par catégorie — null = toutes
  String? _categorieFiltree;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtrage ───────────────────────────────────────────────────

  /// Retourne les opérations filtrées selon les critères actifs.
  List<OperationModel> get _operationsFiltrees {
    return ctrl.operations.where((op) {

      // Filtre par type
      if (_typeFiltre != null && op.type != _typeFiltre) return false;

      // Filtre par catégorie
      if (_categorieFiltree != null &&
          op.categorieId != _categorieFiltree) return false;

      // Filtre par recherche
      if (_recherche.isNotEmpty) {
        final note = op.note?.toLowerCase() ?? '';
        if (!note.contains(_recherche.toLowerCase())) return false;
      }

      return true;
    }).toList();
  }

  /// Groupe les opérations par date.
  ///
  /// Retourne une Map : DateTime (date sans heure) → List<OperationModel>
  Map<DateTime, List<OperationModel>> get _operationsGroupees {
    final Map<DateTime, List<OperationModel>> groupes = {};

    for (final op in _operationsFiltrees) {
      final dateOnly = op.date.dateUniquement;
      groupes.putIfAbsent(dateOnly, () => []).add(op);
    }

    // Trier par date décroissante
    return Map.fromEntries(
      groupes.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  /// Total des entrées filtrées
  double get _totalEntreesFiltrees => _operationsFiltrees
      .where((op) => op.estEntree)
      .fold(0.0, (sum, op) => sum + op.montant);

  /// Total des sorties filtrées
  double get _totalSortiesFiltrees => _operationsFiltrees
      .where((op) => op.estSortie)
      .fold(0.0, (sum, op) => sum + op.montant);

  // ── Réinitialisation des filtres ───────────────────────────────

  void _reinitialiserFiltres() {
    setState(() {
      _typeFiltre = null;
      _categorieFiltree = null;
      _recherche = '';
      _searchCtrl.clear();
    });
  }

  /// Vrai si au moins un filtre est actif
  bool get _aDesFiltresActifs =>
      _typeFiltre != null ||
      _categorieFiltree != null ||
      _recherche.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDark;

      return Scaffold(
        backgroundColor: AppColors.background(isDark),

        // ── AppBar ───────────────────────────────────────────────
        appBar: _buildAppBar(isDark),

        // ── Corps ────────────────────────────────────────────────
        body: ctrl.estEnChargement
            ? const SafeArea(child: SkeletonListe(nombreElements: 6))
            : SafeArea(
                child: Column(
                  children: [

                    // ── Barre de recherche ─────────────────────
                    _BarreRecherche(
                      controller: _searchCtrl,
                      isDark: isDark,
                      onChanged: (val) =>
                          setState(() => _recherche = val),
                    ),

                    // ── Filtres ────────────────────────────────
                    FiltreBar(
                      typeFiltre: _typeFiltre,
                      categorieFiltree: _categorieFiltree,
                      categories: ctrl.categories,
                      isDark: isDark,
                      onTypeChanged: (type) =>
                          setState(() => _typeFiltre = type),
                      onCategorieChanged: (cat) =>
                          setState(() => _categorieFiltree = cat),
                      onReinitialiser: _aDesFiltresActifs
                          ? _reinitialiserFiltres
                          : null,
                    ),

                    // ── Résumé filtré ──────────────────────────
                    if (_operationsFiltrees.isNotEmpty)
                      _ResumeFiltre(
                        totalEntrees: _totalEntreesFiltrees,
                        totalSorties: _totalSortiesFiltrees,
                        nombreOperations: _operationsFiltrees.length,
                        devise: ctrl.devise,
                        isDark: isDark,
                      ),

                    // ── Liste groupée ──────────────────────────
                    Expanded(
                      child: _operationsFiltrees.isEmpty
                          ? EmptyState.recherche(
                              query: _recherche.isNotEmpty
                                  ? _recherche
                                  : null,
                            )
                          : _ListeGroupee(
                              groupes: _operationsGroupees,
                              isDark: isDark,
                            ),
                    ),
                  ],
                ),
              ),

        // ── FAB ──────────────────────────────────────────────────
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(
            () => const AjouterOperationScreen(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 400),
          ),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      );
    });
  }

  /// AppBar de l'écran
  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: AppColors.background(isDark),
      elevation: 0,
      title: Text(
        'Opérations',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(isDark),
        ),
      ),
      actions: [
        // Badge filtres actifs
        if (_aDesFiltresActifs)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: _reinitialiserFiltres,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.alerte.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusFull,
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.filter_alt_off_rounded,
                      size: 14,
                      color: AppColors.alerte,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Effacer',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.alerte,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Barre de recherche ─────────────────────────────────────────────

/// Barre de recherche par note.
class _BarreRecherche extends StatelessWidget {
  const _BarreRecherche({
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary(isDark),
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher une opération...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(isDark),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary(isDark),
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.card(isDark),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusInput,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300));
  }
}

// ── Résumé filtré ──────────────────────────────────────────────────

/// Résumé des totaux des opérations filtrées.
class _ResumeFiltre extends StatelessWidget {
  const _ResumeFiltre({
    required this.totalEntrees,
    required this.totalSorties,
    required this.nombreOperations,
    required this.devise,
    required this.isDark,
  });

  final double totalEntrees;
  final double totalSorties;
  final int nombreOperations;
  final String devise;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingHorizontal,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppSpacing.cardShadow(isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Nombre d'opérations
          Text(
            '$nombreOperations opération${nombreOperations > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(isDark),
            ),
          ),

          // Entrées
          Row(
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 12,
                color: AppColors.entree,
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.montant(totalEntrees, devise),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.entree,
                ),
              ),
            ],
          ),

          // Sorties
          Row(
            children: [
              const Icon(
                Icons.arrow_upward_rounded,
                size: 12,
                color: AppColors.sortie,
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.montant(totalSorties, devise),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sortie,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Liste groupée par date ─────────────────────────────────────────

/// Liste des opérations groupées par date.
class _ListeGroupee extends StatelessWidget {
  const _ListeGroupee({
    required this.groupes,
    required this.isDark,
  });

  final Map<DateTime, List<OperationModel>> groupes;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dates = groupes.keys.toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
        AppSpacing.pagePaddingHorizontal,
        100,
      ),
      itemCount: dates.length,
      itemBuilder: (context, indexGroupe) {
        final date = dates[indexGroupe];
        final operations = groupes[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header de date ───────────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                date.relatif,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: Duration(
                    milliseconds: 50 * indexGroupe,
                  ),
                  duration: const Duration(milliseconds: 300),
                ),

            // ── Opérations du groupe ─────────────────────────
            ...operations.asMap().entries.map((entry) {
              final indexOp = entry.key;
              final op = entry.value;
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                child: OperationTile(
                  operation: op,
                  delaiAnimation: Duration(
                    milliseconds: (50 * indexGroupe) + (30 * indexOp),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}