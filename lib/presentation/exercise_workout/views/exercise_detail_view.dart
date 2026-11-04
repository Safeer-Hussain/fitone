import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../widgets/one_rm_calculator_sheet.dart';

class ExerciseDetailView extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailView({super.key, required this.exercise});

  String _getEquipmentImage(String eq) {
    final lower = eq.toLowerCase();
    if (lower.contains('dumbbell')) return AppAssets.equipmentDumbbells;
    if (lower.contains('barbell')) return AppAssets.equipmentBarbell;
    if (lower.contains('machine')) return AppAssets.equipmentGymMachines;
    if (lower.contains('bodyweight')) return AppAssets.equipmentBodyweight;
    return AppAssets.equipmentGymMachines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            onPressed: () => OneRmCalculatorSheet.show(context),
            icon: const Icon(Icons.calculate_outlined, color: AppColors.emeraldPrimary),
            tooltip: '1RM Calculator',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              color: AppColors.darkSurface,
              child: Image.asset(
                _getEquipmentImage(exercise.equipment),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.darkSurface,
                  child: const Center(
                    child: Icon(Icons.fitness_center_rounded, size: 54, color: AppColors.emeraldPrimary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _DetailChip(label: exercise.bodyPart, color: AppColors.cyanAccent),
              const SizedBox(width: 8),
              _DetailChip(label: exercise.equipment, color: AppColors.emeraldPrimary),
              const SizedBox(width: 8),
              _DetailChip(label: exercise.difficulty, color: AppColors.orangeAccent),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'ANATOMICAL TARGET MUSCLES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.emeraldPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text(
              exercise.targetMuscles,
              style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'BIOMECHANICAL INSTRUCTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.emeraldPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text(
              exercise.instructions,
              style: const TextStyle(fontSize: 14, color: AppColors.darkTextSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => OneRmCalculatorSheet.show(context),
            icon: const Icon(Icons.calculate_rounded, size: 18),
            label: const Text('Calculate 1RM & Overload Targets'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldPrimary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final Color color;

  const _DetailChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
