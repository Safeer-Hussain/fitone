import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_store.dart';
import '../../../domain/entities/nutrition_day.dart';
import '../stores/nutrition_store.dart';
import '../widgets/hydration_tracker_card.dart';
import '../widgets/macro_progress_ring.dart';
import '../widgets/quick_add_food_dialog.dart';

class NutritionView extends StatefulWidget {
  const NutritionView({super.key});

  @override
  State<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<NutritionView> {
  late final NutritionStore _store;
  final ThemeStore _themeStore = sl<ThemeStore>();

  @override
  void initState() {
    super.initState();
    _store = sl<NutritionStore>();
    _store.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final _ = _themeStore.themeMode;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final summary = _store.dailySummary;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nutrition & Hydration Tracker'),
            actions: [
              IconButton(
                onPressed: () => QuickAddFoodDialog.show(context, _store),
                icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                tooltip: 'Log Food',
              ),
            ],
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              if (summary == null) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }

              if (isLandscape) {
                return SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              MacroProgressRing(summary: summary),
                              const SizedBox(height: 14),
                              HydrationTrackerCard(store: _store),
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                      Expanded(
                        flex: 6,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: _buildMealSlots(summary.mealItems, colorScheme),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    MacroProgressRing(summary: summary),
                    const SizedBox(height: 14),
                    HydrationTrackerCard(store: _store),
                    const SizedBox(height: 20),
                    Text(
                      'MEAL CATEGORIES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._buildMealSlots(summary.mealItems, colorScheme),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => QuickAddFoodDialog.show(context, _store),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log Meal', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  List<Widget> _buildMealSlots(List<NutritionLogItem> items, ColorScheme colorScheme) {
    const categories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

    return categories.map((cat) {
      final slotItems = items.where((i) => i.mealType == cat).toList();
      final slotCalories = slotItems.fold(0.0, (acc, item) => acc + item.calories);
      final slotProtein = slotItems.fold(0.0, (acc, item) => acc + item.proteinG);

      return Card(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        cat,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slotCalories.toStringAsFixed(0)} kcal • ${slotProtein.toStringAsFixed(0)}g P',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => QuickAddFoodDialog.show(context, _store, defaultMealSlot: cat),
                    icon: Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (slotItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Column(
                  children: slotItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.foodName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                                ),
                                Text(
                                  '${item.calories.toStringAsFixed(0)} kcal • ${item.proteinG.toStringAsFixed(0)}g P • ${item.carbsG.toStringAsFixed(0)}g C • ${item.fatG.toStringAsFixed(0)}g F',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _store.deleteFood(item.id),
                            icon: Icon(Icons.close_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}
