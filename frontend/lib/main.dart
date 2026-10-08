import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/network/app_config.dart';
import 'features/auth/splash_screen.dart';
import 'shared/state/app_state_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStateManager.instance.initialize();
  runApp(const OS4AllApp());
}

class OS4AllApp extends StatelessWidget {
  const OS4AllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager.instance,
      builder: (context, _) {
        final isAuthenticated = AppStateManager.instance.isAuthenticated || AppStateManager.instance.isDemoMode;
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: SplashScreen(isAuthenticated: isAuthenticated),
        );
      },
    );
  }
}
