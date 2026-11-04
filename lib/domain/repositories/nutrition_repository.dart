import '../entities/nutrition_day.dart';

abstract class NutritionRepository {
  Future<DailyNutritionSummary> getDailySummary(String dateStr);
  Future<void> addFoodEntry(NutritionLogItem item);
  Future<void> deleteFoodEntry(String id);
  Future<void> logHydration(HydrationLogItem item);
  Future<void> resetDayHydration(String dateStr);
}
