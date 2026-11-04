import 'package:fitone/domain/entities/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('1RM Biomechanical Formula Tests', () {
    test('Epley formula calculates correct 1RM for standard loading', () {
      final set = WorkoutSet(
        id: 'test_set_1',
        workoutId: 'w_1',
        exerciseId: 'ex_01',
        setNumber: 1,
        weightKg: 100.0,
        reps: 10,
        rpe: 8.5,
        isCompleted: true,
        timestamp: DateTime.now(),
      );

      // Epley: 100 * (1 + 10 / 30) = 133.33 kg
      expect(set.oneRepMaxEpley, closeTo(133.33, 0.05));
    });

    test('Brzycki formula calculates correct 1RM for 5 reps', () {
      final set = WorkoutSet(
        id: 'test_set_2',
        workoutId: 'w_1',
        exerciseId: 'ex_01',
        setNumber: 2,
        weightKg: 100.0,
        reps: 5,
        rpe: 9.0,
        isCompleted: true,
        timestamp: DateTime.now(),
      );

      // Brzycki: 100 / (1.0278 - (0.0278 * 5)) = 100 / 0.8888 = 112.51 kg
      expect(set.oneRepMaxBrzycki, closeTo(112.51, 0.1));
    });

    test('Single rep set returns exact weight for 1RM', () {
      final set = WorkoutSet(
        id: 'test_set_3',
        workoutId: 'w_1',
        exerciseId: 'ex_01',
        setNumber: 3,
        weightKg: 140.0,
        reps: 1,
        rpe: 10.0,
        isCompleted: true,
        timestamp: DateTime.now(),
      );

      expect(set.oneRepMaxEpley, equals(140.0));
      expect(set.oneRepMaxBrzycki, closeTo(140.0, 0.1));
    });
  });
}
