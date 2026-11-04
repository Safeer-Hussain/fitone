import '../entities/exercise.dart';

abstract class WorkoutRepository {
  Future<List<Exercise>> getExercises({
    String? bodyPart,
    String? equipment,
    String? search,
    int page = 1,
    int limit = 60,
  });

  Future<Exercise?> getExerciseById(String id);
  Future<List<WorkoutPlan>> getWorkoutPlans();
  Future<void> saveWorkoutPlan(WorkoutPlan plan);
  Future<List<WorkoutSession>> getPastWorkouts();
  Future<void> saveWorkoutSession(WorkoutSession session);
}
