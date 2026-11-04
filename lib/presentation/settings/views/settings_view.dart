import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_store.dart';
import '../../../core/widgets/developer_debug_drawer.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStore = sl<ThemeStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Wearable System'),
      ),
      endDrawer: const DeveloperDebugDrawer(),
      body: Builder(
        builder: (scaffoldContext) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'SYSTEM & APPEARANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.emeraldPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    Observer(
                      builder: (_) => SwitchListTile.adaptive(
                        title: const Text('Dark Mode Palette', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('High-contrast obsidian and emerald green UI', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                        value: themeStore.isDarkMode,
                        activeColor: AppColors.emeraldPrimary,
                        onChanged: (_) => themeStore.toggleTheme(),
                      ),
                    ),
                    const Divider(color: AppColors.darkBorder),
                    const ListTile(
                      title: Text('Biometric Unit Standard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Metric (kg, km, Celsius)', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                      trailing: Icon(Icons.check_rounded, color: AppColors.emeraldPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'WEARABLE HARDWARE INTEGRATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.emeraldPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.cable_rounded, color: AppColors.cyanAccent),
                      title: Text('Dual Native Hardware Bridges', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Kotlin MethodChannel + Swift EventChannel', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                      trailing: Text('ACTIVE', style: TextStyle(color: AppColors.emeraldPrimary, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    Divider(color: AppColors.darkBorder),
                    ListTile(
                      leading: Icon(Icons.storage_rounded, color: AppColors.orangeAccent),
                      title: Text('Offline-First Architecture', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('SQLite cache + Dio mock latency interceptor', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                      trailing: Text('SYNCED', style: TextStyle(color: AppColors.emeraldPrimary, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'RECRUITER & DEVELOPER TOOLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.emeraldPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.developer_mode_rounded, color: AppColors.emeraldPrimary),
                  title: const Text('Open Recruiter Debug Drawer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Toggle 503 errors, simulated latency, & telemetry rate', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextMuted),
                  onTap: () {
                    Scaffold.of(scaffoldContext).openEndDrawer();
                  },
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onLongPress: () {
                    Scaffold.of(scaffoldContext).openEndDrawer();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Fitone Ecosystem v1.0.0 (Production Build 100)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Long press to open Developer & Recruiter Drawer',
                          style: TextStyle(fontSize: 11, color: AppColors.emeraldPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
