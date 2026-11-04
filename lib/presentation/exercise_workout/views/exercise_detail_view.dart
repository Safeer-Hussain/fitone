import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget imageSection = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isLandscape ? 220 : 180,
        color: colorScheme.surfaceContainerHighest,
        child: Image.asset(
          _getEquipmentImage(exercise.equipment),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(Icons.fitness_center_rounded, size: 54, color: colorScheme.primary),
            ),
          ),
        ),
      ),
    );

    Widget chipsSection = Row(
      children: [
        _DetailChip(label: exercise.bodyPart, color: colorScheme.secondary),
        const SizedBox(width: 8),
        _DetailChip(label: exercise.equipment, color: colorScheme.primary),
        const SizedBox(width: 8),
        _DetailChip(label: exercise.difficulty, color: colorScheme.tertiary),
      ],
    );

    Widget contentSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANATOMICAL TARGET MUSCLES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            exercise.targetMuscles,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface, height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'BIOMECHANICAL INSTRUCTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            exercise.instructions,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => OneRmCalculatorSheet.show(context),
            icon: const Icon(Icons.calculate_rounded, size: 18),
            label: const Text('Calculate 1RM & Overload Targets'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            onPressed: () => OneRmCalculatorSheet.show(context),
            icon: Icon(Icons.calculate_outlined, color: colorScheme.primary),
            tooltip: '1RM Calculator',
          ),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            imageSection,
                            const SizedBox(height: 16),
                            chipsSection,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: contentSection,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  imageSection,
                  const SizedBox(height: 20),
                  chipsSection,
                  const SizedBox(height: 24),
                  contentSection,
                ],
              ),
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
