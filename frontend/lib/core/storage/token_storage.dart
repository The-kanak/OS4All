import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local storage service for tokens, credentials, and app preferences.
class TokenStorage {
  static const String _keyToken = 'os4all_jwt_token';
  static const String _keyUserEmail = 'os4all_user_email';
  static const String _keyUserName = 'os4all_user_name';
  static const String _keyUserId = 'os4all_user_id';
  static const String _keyLiveMode = 'os4all_is_live_mode';
  static const String _keyCustomBaseUrl = 'os4all_custom_api_url';
  static const String _keyLanguage = 'os4all_preferred_language';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserEmail);
  }

  static Future<String?> getUserName() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserId);
  }

  static Future<void> saveUserSession({
    required String token,
    required String email,
    required String fullName,
    String? userId,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, fullName);
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  static Future<bool> isLiveMode() async {
    final prefs = await _getPrefs();
    // Default to true (Live Mode) for normal production operation
    return prefs.getBool(_keyLiveMode) ?? true;
  }

  static Future<void> setLiveMode(bool isLive) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyLiveMode, isLive);
  }

  static Future<String?> getCustomBaseUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyCustomBaseUrl);
  }

  static Future<void> setCustomBaseUrl(String? url) async {
    final prefs = await _getPrefs();
    if (url == null || url.isEmpty) {
      await prefs.remove(_keyCustomBaseUrl);
    } else {
      await prefs.setString(_keyCustomBaseUrl, url);
    }
  }

  static Future<String> getPreferredLanguage() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  static Future<void> setPreferredLanguage(String lang) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyLanguage, lang);
  }

  static Future<void> clearSession() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserId);
  }
}
