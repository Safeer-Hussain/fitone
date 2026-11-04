import 'package:fitone/domain/entities/nutrition_day.dart';
import 'package:fitone/presentation/dashboard/widgets/readiness_ring.dart';
import 'package:fitone/presentation/nutrition/widgets/macro_progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core Presentation Widget Tests', () {
    testWidgets('ReadinessRing renders score and metric labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReadinessRing(
              score: 92,
              hrvMs: 74,
              restingHr: 52,
            ),
          ),
        ),
      );

      expect(find.text('RECOVERY & READINESS'), findsOneWidget);
      expect(find.text('92'), findsOneWidget);
      expect(find.text('74'), findsOneWidget);
      expect(find.text('52'), findsOneWidget);
      expect(find.text('Optimal Readiness'), findsOneWidget);
    });

    testWidgets('MacroProgressRing displays calories and remaining target', (WidgetTester tester) async {
      final summary = DailyNutritionSummary(
        dateStr: '2026-11-04',
        targetCalories: 2400.0,
        targetProteinG: 175.0,
        targetCarbsG: 240.0,
        targetFatG: 65.0,
        targetWaterMl: 3000,
        mealItems: [
          NutritionLogItem(
            id: 'n_1',
            dateStr: '2026-11-04',
            mealType: 'Breakfast',
            foodName: 'Oatmeal',
            calories: 600.0,
            proteinG: 40.0,
            carbsG: 80.0,
            fatG: 10.0,
            timestamp: DateTime(2026, 11, 4),
          ),
        ],
        waterItems: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroProgressRing(summary: summary),
          ),
        ),
      );

      expect(find.text('DAILY ENERGY & MACROS'), findsOneWidget);
      expect(find.text('600'), findsOneWidget);
      expect(find.text('1800 kcal left'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
    });
  });
}
