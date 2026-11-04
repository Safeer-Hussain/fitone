import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../stores/nutrition_store.dart';

class QuickAddFoodDialog extends StatefulWidget {
  final NutritionStore store;
  final String defaultMealSlot;

  const QuickAddFoodDialog({super.key, required this.store, this.defaultMealSlot = 'Breakfast'});

  static void show(BuildContext context, NutritionStore store, {String defaultMealSlot = 'Breakfast'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddFoodDialog(store: store, defaultMealSlot: defaultMealSlot),
    );
  }

  @override
  State<QuickAddFoodDialog> createState() => _QuickAddFoodDialogState();
}

class _QuickAddFoodDialogState extends State<QuickAddFoodDialog> {
  late String _mealSlot;
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  final List<Map<String, dynamic>> _quickTemplates = const [
    {'name': 'Chicken Breast (200g)', 'cal': 330, 'p': 62, 'c': 0, 'f': 7},
    {'name': 'Eggs (3 Large)', 'cal': 215, 'p': 19, 'c': 1, 'f': 15},
    {'name': 'Whey Protein Scoop (30g)', 'cal': 120, 'p': 25, 'c': 2, 'f': 1.5},
    {'name': 'Jasmine Rice Cooked (200g)', 'cal': 260, 'p': 5, 'c': 57, 'f': 0.5},
    {'name': 'Greek Yogurt 0% (250g)', 'cal': 140, 'p': 25, 'c': 9, 'f': 0},
    {'name': 'Avocado (100g)', 'cal': 160, 'p': 2, 'c': 9, 'f': 15},
  ];

  @override
  void initState() {
    super.initState();
    _mealSlot = widget.defaultMealSlot;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _applyTemplate(Map<String, dynamic> t) {
    setState(() {
      _foodNameController.text = t['name'] as String;
      _caloriesController.text = (t['cal'] as num).toString();
      _proteinController.text = (t['p'] as num).toString();
      _carbsController.text = (t['c'] as num).toString();
      _fatController.text = (t['f'] as num).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.darkBorder)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Log Nutritional Macro Intake', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  Icon(Icons.restaurant_menu_rounded, color: AppColors.emeraldPrimary, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              const Text('POPULAR MACRO PRESETS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkTextSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _quickTemplates.map((t) {
                  return ActionChip(
                    label: Text(t['name'] as String, style: const TextStyle(fontSize: 11)),
                    onPressed: () => _applyTemplate(t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _mealSlot,
                decoration: const InputDecoration(labelText: 'Meal Category'),
                dropdownColor: AppColors.darkSurface,
                items: const [
                  DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                  DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                  DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                  DropdownMenuItem(value: 'Snacks', child: Text('Snacks')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _mealSlot = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _foodNameController,
                decoration: const InputDecoration(labelText: 'Food Name / Description'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carbs (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fats (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _foodNameController.text.trim();
                    if (name.isEmpty) return;

                    final cal = double.tryParse(_caloriesController.text) ?? 0.0;
                    final p = double.tryParse(_proteinController.text) ?? 0.0;
                    final c = double.tryParse(_carbsController.text) ?? 0.0;
                    final f = double.tryParse(_fatController.text) ?? 0.0;

                    await widget.store.addFood(
                      mealType: _mealSlot,
                      foodName: name,
                      calories: cal,
                      proteinG: p,
                      carbsG: c,
                      fatG: f,
                    );

                    if (context.mounted) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add to Food Log', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
