import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:os4all_frontend/core/theme/app_theme.dart';
import 'package:os4all_frontend/features/shell/app_shell.dart';
import 'package:os4all_frontend/features/home/home_screen.dart';
import 'package:os4all_frontend/features/health/health_screen.dart';
import 'package:os4all_frontend/features/insights/insights_screen.dart';
import 'package:os4all_frontend/features/counselor/counselor_screen.dart';
import 'package:os4all_frontend/features/profile/profile_screen.dart';
import 'package:os4all_frontend/shared/state/app_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'os4all_is_live_mode': false});
    await AppStateManager.instance.setDemoMode();
  });

  testWidgets('AppShell renders 5-tab navigation bar and IndexedStack components', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );

    // Verify all 5 navigation tabs exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Care'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify initial home screen content
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify mode indicator pill
    expect(find.text('DEMO'), findsOneWidget);

    // Tap on Health tab
    await tester.tap(find.text('Health'));
    await tester.pumpAndSettle();
    expect(find.byType(HealthScreen), findsOneWidget);

    // Tap on Insights tab
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.byType(InsightsScreen), findsOneWidget);

    // Tap on Care tab
    await tester.tap(find.text('Care'));
    await tester.pumpAndSettle();
    expect(find.byType(CounselorScreen), findsOneWidget);

    // Tap on Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
