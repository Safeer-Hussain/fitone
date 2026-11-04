import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../stores/exercise_store.dart';
import '../widgets/exercise_card.dart';
import 'exercise_detail_view.dart';
import 'workout_logger_view.dart';

class ExerciseEncyclopediaView extends StatefulWidget {
  const ExerciseEncyclopediaView({super.key});

  @override
  State<ExerciseEncyclopediaView> createState() => _ExerciseEncyclopediaViewState();
}

class _ExerciseEncyclopediaViewState extends State<ExerciseEncyclopediaView> {
  late final ExerciseStore _store;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store = sl<ExerciseStore>();
    _store.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exercise Encyclopedia & Programs'),
          bottom: const TabBar(
            indicatorColor: AppColors.emeraldPrimary,
            labelColor: AppColors.emeraldPrimary,
            unselectedLabelColor: AppColors.darkTextMuted,
            tabs: [
              Tab(text: 'Encyclopedia (60+)'),
              Tab(text: 'Routines & Plans'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WorkoutLoggerView()),
                );
              },
              icon: const Icon(Icons.fitness_center_rounded, color: AppColors.emeraldPrimary),
              tooltip: 'Launch Active Logger',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildEncyclopediaTab(),
            _buildWorkoutPlansTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WorkoutLoggerView()),
            );
          },
          backgroundColor: AppColors.emeraldPrimary,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildEncyclopediaTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _store.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search 60+ exercises or target muscles...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkTextMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _store.onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Body part horizontal selector
        SizedBox(
          height: 38,
          child: Observer(
            builder: (_) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _store.bodyParts.length,
              itemBuilder: (context, index) {
                final part = _store.bodyParts[index];
                final isSelected = _store.selectedBodyPart == part;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(part),
                    selected: isSelected,
                    onSelected: (_) => _store.setBodyPart(part),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Equipment horizontal selector
        SizedBox(
          height: 38,
          child: Observer(
            builder: (_) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _store.equipmentList.length,
              itemBuilder: (context, index) {
                final eq = _store.equipmentList[index];
                final isSelected = _store.selectedEquipment == eq;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(eq),
                    selected: isSelected,
                    onSelected: (_) => _store.setEquipment(eq),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Observer(
            builder: (_) {
              if (_store.isLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerLoader(width: double.infinity, height: 90),
                  ),
                );
              }

              if (_store.hasError) {
                return ErrorRetryView(
                  message: _store.errorMessage.isNotEmpty
                      ? _store.errorMessage
                      : 'Unable to connect to exercise database.',
                  onRetry: () => _store.loadExercises(),
                );
              }

              final exercises = _store.exercises;
              if (exercises.isEmpty) {
                return const Center(
                  child: Text('No exercises found matching criteria.', style: TextStyle(color: AppColors.darkTextMuted)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return ExerciseCard(
                    exercise: ex,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ExerciseDetailView(exercise: ex)),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutPlansTab() {
    return Observer(
      builder: (_) {
        final plans = _store.workoutPlans;
        if (plans.isEmpty) {
          return const Center(child: Text('No workout plans loaded.', style: TextStyle(color: AppColors.darkTextMuted)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            plan.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${plan.daysPerWeek} Days/Wk',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emeraldPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.darkBorder),
                    const SizedBox(height: 10),
                    Column(
                      children: plan.schedule.map((dayMap) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dayMap['day'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                              Text(
                                '${dayMap['focus']} (${dayMap['exerciseCount']} exercises)',
                                style: const TextStyle(fontSize: 12, color: AppColors.cyanAccent),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
