import 'package:flutter/material.dart';
import '../../core/network/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/os4all_brand_logo.dart';
import '../../shared/state/app_state_manager.dart';
import '../alerts/alerts_screen.dart';
import '../counselor/counselor_screen.dart';
import '../dashboard/launch_demo_modal.dart';
import '../health/health_screen.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import '../insights/intelligence_trace_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  static AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppShellState>();
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late int _currentIndex;
  final GlobalKey<HealthScreenState> _healthScreenKey = GlobalKey<HealthScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index, {int? subIndex}) {
    if (index >= 0 && index < 5) {
      setState(() {
        _currentIndex = index;
      });
      if (index == 1 && subIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _healthScreenKey.currentState?.publicSetTab(subIndex);
        });
      }
    }
  }

  void _showModeToggleDialog() {
    final appState = AppStateManager.instance;
    final isDemo = appState.isDemoMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Icon(
              isDemo ? Icons.science_rounded : Icons.sensors_rounded,
              color: isDemo ? AppTheme.warning : AppTheme.success,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isDemo ? 'Demo Mode Active' : 'Live Backend Mode Active',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDemo
                  ? 'Currently operating on deterministic synthetic patient telemetry. Ready for hackathon presentation and judges evaluation.'
                  : 'Currently connected to the live Spring Boot backend at ${AppConfig.apiBaseUrl}. Real observations and lab PDFs are stored in MySQL.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Text(
              'Switch to ${isDemo ? "Live Backend Mode" : "Deterministic Demo Mode"}?',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isDemo) {
                appState.setLiveMode();
              } else {
                appState.setDemoMode();
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDemo ? AppTheme.primary : AppTheme.warning,
            ),
            child: Text(isDemo ? 'Switch to Live Mode' : 'Switch to Demo Mode'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager.instance,
      builder: (context, _) {
        final appState = AppStateManager.instance;
        final isDemo = appState.isDemoMode;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Os4AllBrandLogo(fontSize: 19),
            actions: [
              // Live / Demo Mode Status Pill
              GestureDetector(
                onTap: _showModeToggleDialog,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDemo ? AppTheme.warning.withValues(alpha: 0.14) : AppTheme.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDemo ? AppTheme.warning.withValues(alpha: 0.5) : AppTheme.success.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDemo ? Icons.science_rounded : Icons.wifi_rounded,
                        size: 13,
                        color: isDemo ? AppTheme.warning : AppTheme.success,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isDemo ? 'DEMO' : 'LIVE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDemo ? AppTheme.warning : AppTheme.success,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Quick Tools & Actions Overflow Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textPrimary, size: 22),
                tooltip: 'More Actions',
                onSelected: (value) {
                  switch (value) {
                    case 'demo':
                      LaunchDemoModal.show(context);
                      break;
                    case 'trace':
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const IntelligenceTraceScreen()),
                      );
                      break;
                    case 'alerts':
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AlertsScreen()),
                      );
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'demo',
                    child: Row(
                      children: [
                        Icon(Icons.rocket_launch_rounded, color: AppTheme.primary, size: 18),
                        SizedBox(width: 10),
                        Text('Run 10-Step Demo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'trace',
                    child: Row(
                      children: [
                        Icon(Icons.account_tree_rounded, color: AppTheme.secondary, size: 18),
                        SizedBox(width: 10),
                        Text('Intelligence Trace', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'alerts',
                    child: Row(
                      children: [
                        Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary, size: 18),
                        SizedBox(width: 10),
                        Text('Patient Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onNavigateToTab: switchTab),
              HealthScreen(key: _healthScreenKey),
              const InsightsScreen(),
              const CounselorScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.monitor_heart_outlined),
                  selectedIcon: Icon(Icons.monitor_heart_rounded, color: AppTheme.primary),
                  label: 'Health',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
                  label: 'Insights',
                ),
                NavigationDestination(
                  icon: Icon(Icons.support_agent_outlined),
                  selectedIcon: Icon(Icons.support_agent_rounded, color: AppTheme.primary),
                  label: 'Care',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
