import 'package:flutter/foundation.dart';

/// Centralized Environment configuration for OS4All Flutter App.
/// The backend default port is 8080.
class AppConfig {
  static const String appName = 'OS4All';
  static const String tagline = 'Your health, understood earlier.';

  // Default endpoints aligned with Spring Boot (server.port=8085 due to port 8080 being occupied by PEMHTTPD)
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8085/api/v1';
  static const String webLocalBaseUrl = 'http://localhost:8085/api/v1';

  // Configurable at runtime if user overrides in Settings
  static String? _customBaseUrl;

  static void setCustomBaseUrl(String? url) {
    _customBaseUrl = url?.trim();
  }

  static String get apiBaseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return webLocalBaseUrl;
    }
    // On Android native, default to 10.0.2.2 for emulator access
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }
    return webLocalBaseUrl;
  }

  /// Whether demo/development mode is enabled (visible for hackathon judging & dev environments)
  static const bool isDemoModeEnabled = bool.fromEnvironment('DEMO_MODE', defaultValue: true);
}
