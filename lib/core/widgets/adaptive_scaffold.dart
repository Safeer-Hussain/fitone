import 'package:flutter/material.dart';
import 'offline_banner.dart';

class AdaptiveScaffoldDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const AdaptiveScaffoldDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationIndexChanged;
  final List<AdaptiveScaffoldDestination> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? endDrawer;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.destinations,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = orientation == Orientation.landscape || constraints.maxWidth > 720;

            if (isLandscape) {
              return Scaffold(
                appBar: appBar,
                endDrawer: endDrawer,
                floatingActionButton: floatingActionButton,
                body: Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(
                      child: Row(
                        children: [
                          NavigationRail(
                            selectedIndex: currentIndex,
                            onDestinationSelected: onNavigationIndexChanged,
                            labelType: NavigationRailLabelType.all,
                            backgroundColor: colorScheme.surface,
                            indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
                            leading: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.primary, width: 1.5),
                                ),
                                child: Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 20),
                              ),
                            ),
                            destinations: destinations.map((d) {
                              return NavigationRailDestination(
                                icon: Icon(d.icon),
                                selectedIcon: Icon(d.selectedIcon, color: colorScheme.primary),
                                label: Text(d.label),
                              );
                            }).toList(),
                          ),
                          VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
                          Expanded(child: body),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              appBar: appBar,
              endDrawer: endDrawer,
              floatingActionButton: floatingActionButton,
              body: Column(
                children: [
                  const OfflineBanner(),
                  Expanded(child: body),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: onNavigationIndexChanged,
                destinations: destinations.map((d) {
                  return NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
