import 'package:fitone/core/widgets/adaptive_scaffold.dart';
import 'package:fitone/presentation/dashboard/widgets/readiness_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Adaptive Navigation & Responsive Landscape Tests', () {
    const destinations = [
      AdaptiveScaffoldDestination(
        label: 'Hub',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
      ),
      AdaptiveScaffoldDestination(
        label: 'Workouts',
        icon: Icons.fitness_center_outlined,
        selectedIcon: Icons.fitness_center_rounded,
      ),
      AdaptiveScaffoldDestination(
        label: 'Macros',
        icon: Icons.restaurant_menu_outlined,
        selectedIcon: Icons.restaurant_menu_rounded,
      ),
    ];

    testWidgets('Portrait mode displays BottomNavigationBar and hides NavigationRail', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            currentIndex: 0,
            destinations: destinations,
            onNavigationIndexChanged: (_) {},
            body: const Center(child: Text('Portrait Viewport')),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Portrait Viewport'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Landscape mode displays NavigationRail and suppresses NavigationBar without overflow', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            currentIndex: 0,
            destinations: destinations,
            onNavigationIndexChanged: (_) {},
            body: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: ReadinessRing(score: 88, hrvMs: 65, restingHr: 54),
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  flex: 6,
                  child: Center(child: Text('Landscape Master Detail Pane')),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Landscape Master Detail Pane'), findsOneWidget);
      expect(find.text('RECOVERY & READINESS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
