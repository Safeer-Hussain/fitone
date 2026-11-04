import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_store.dart';
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
  final ThemeStore _themeStore = sl<ThemeStore>();
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
    return Observer(
      builder: (_) {
        final _ = _themeStore.themeMode;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Exercise Encyclopedia & Programs'),
              bottom: TabBar(
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                tabs: const [
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
                  icon: Icon(Icons.fitness_center_rounded, color: colorScheme.primary),
                  tooltip: 'Launch Active Logger',
                ),
              ],
            ),
            body: TabBarView(
              children: [
                _buildEncyclopediaTab(context),
                _buildWorkoutPlansTab(context),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WorkoutLoggerView()),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEncyclopediaTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _store.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search 60+ exercises or target muscles...',
              prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
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
                return Center(
                  child: Text(
                    'No exercises found matching criteria.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }

              if (isLandscape) {
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = screenWidth > 900 ? 4 : 3;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
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

  Widget _buildWorkoutPlansTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Observer(
      builder: (_) {
        final plans = _store.workoutPlans;
        if (plans.isEmpty) {
          return Center(
            child: Text('No workout plans loaded.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          );
        }

        Widget buildPlanCard(dynamic plan) {
          return Card(
            margin: isLandscape ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            plan.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${plan.daysPerWeek} Days/Wk',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: colorScheme.outlineVariant),
                    const SizedBox(height: 10),
                    Column(
                      children: (plan.schedule as List).map<Widget>((dayMap) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dayMap['day'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${dayMap['focus']} (${dayMap['exerciseCount']} exercises)',
                                style: TextStyle(fontSize: 12, color: colorScheme.secondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isLandscape) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: plans.length,
            itemBuilder: (context, index) => buildPlanCard(plans[index]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) => buildPlanCard(plans[index]),
        );
      },
    );
  }
}
