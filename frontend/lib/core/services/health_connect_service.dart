import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/token_storage.dart';
import 'api_services.dart';

/// Connection and authorization states for Google Health Connect on Android.
enum HealthConnectStatus {
  unsupportedPlatform,
  sdkUnavailable,
  sdkUpdateRequired,
  notConnected,
  connecting,
  permissionRequired,
  permissionPartiallyGranted,
  connected,
  syncing,
  syncSuccess,
  syncError,
}

/// Structured summary of a foreground Health Connect sync operation.
class HealthSyncResult {
  final DateTime syncTime;
  final int totalRead;
  final int importedCount;
  final int skippedDuplicates;
  final int failedCount;
  final Map<String, int> metricCounts;
  final String? errorMessage;
  final bool isSuccess;

  const HealthSyncResult({
    required this.syncTime,
    required this.totalRead,
    required this.importedCount,
    required this.skippedDuplicates,
    this.failedCount = 0,
    this.metricCounts = const {},
    this.errorMessage,
    required this.isSuccess,
  });

  factory HealthSyncResult.failed(String message) {
    return HealthSyncResult(
      syncTime: DateTime.now(),
      totalRead: 0,
      importedCount: 0,
      skippedDuplicates: 0,
      failedCount: 0,
      errorMessage: message,
      isSuccess: false,
    );
  }
}

/// Normalized health record ready for OS4All backend ingestion.
class NormalizedHealthRecord {
  final String deduplicationKey;
  final String metricType;
  final String vitalName;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String source;
  final double confidence;
  final String metadata;
  final int? durationMinutes;

  const NormalizedHealthRecord({
    required this.deduplicationKey,
    required this.metricType,
    required this.vitalName,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.source,
    required this.confidence,
    required this.metadata,
    this.durationMinutes,
  });
}

/// Service governing Google Health Connect on native Android.
/// On web and unsupported platforms, gracefully reports unsupported without crashing.
class HealthConnectService {
  final Health _health;
  final HealthService _healthApiService;

  final DeviceInfoPlugin _deviceInfo;

  HealthConnectStatus _status = HealthConnectStatus.notConnected;
  DateTime? _lastSyncTime;
  int _lastImportedCount = 0;
  int _lastSkippedCount = 0;
  String? _lastError;
  bool _isConfigured = false;

  HealthConnectStatus get status => _status;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get lastImportedCount => _lastImportedCount;
  int get lastSkippedCount => _lastSkippedCount;
  String? get lastError => _lastError;

  /// Supported health data types that correspond to OS4All backend models.
  static const List<HealthDataType> supportedTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.STEPS,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.BODY_TEMPERATURE,
  ];

  /// Corresponding read permissions.
  static List<HealthDataAccess> get readPermissions =>
      List<HealthDataAccess>.filled(supportedTypes.length, HealthDataAccess.READ);

  HealthConnectService({
    Health? health,
    HealthService? healthApiService,
    DeviceInfoPlugin? deviceInfo,
  })  : _health = health ?? Health(),
        _healthApiService = healthApiService ?? HealthService(),
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  /// Checks whether the current operating environment supports native Google Health Connect.
  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  /// Verifies if the Android device runs API 28 (Android 9.0 Pie) or higher.
  /// Health Connect is officially available to users on Android 9 and later.
  Future<bool> isAndroidApiSupported() async {
    if (!isPlatformSupported) return false;
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 28;
    } catch (_) {
      // In test/mock environments or if SDK introspection fails, assume true if android
      return true;
    }
  }

  /// Initializes the Health Connect plugin and restores persistent sync state.
  Future<HealthConnectStatus> checkStatus() async {
    if (!isPlatformSupported) {
      _status = HealthConnectStatus.unsupportedPlatform;
      return _status;
    }

    final apiSupported = await isAndroidApiSupported();
    if (!apiSupported) {
      _status = HealthConnectStatus.unsupportedPlatform;
      _lastError = 'Health Connect requires Android 9 (API 28) or later.';
      return _status;
    }

    try {
      if (!_isConfigured) {
        await _health.configure();
        _isConfigured = true;
      }

      await _restorePersistedSyncInfo();

      final sdkStatus = await _health.getHealthConnectSdkStatus();
      if (sdkStatus == null || sdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
        _status = HealthConnectStatus.sdkUnavailable;
        return _status;
      }

      if (sdkStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
        _status = HealthConnectStatus.sdkUpdateRequired;
        return _status;
      }

      final hasPerms = await _health.hasPermissions(supportedTypes, permissions: readPermissions);
      if (hasPerms == true) {
        _status = HealthConnectStatus.connected;
      } else {
        // Check if at least some permissions are granted
        final partialPerms = await _hasAnyPermission();
        if (partialPerms) {
          _status = HealthConnectStatus.permissionPartiallyGranted;
        } else {
          _status = HealthConnectStatus.permissionRequired;
        }
      }

      return _status;
    } catch (e) {
      _lastError = 'Health Connect status check failed: $e';
      _status = HealthConnectStatus.notConnected;
      return _status;
    }
  }

  /// Helper to check if user granted at least one metric permission.
  Future<bool> _hasAnyPermission() async {
    for (final type in supportedTypes) {
      try {
        final perm = await _health.hasPermissions([type], permissions: [HealthDataAccess.READ]);
        if (perm == true) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Requests user authorization through the official Google Health Connect permission sheet.
  Future<bool> requestPermissions() async {
    if (!isPlatformSupported) {
      _status = HealthConnectStatus.unsupportedPlatform;
      return false;
    }

    final apiSupported = await isAndroidApiSupported();
    if (!apiSupported) {
      _status = HealthConnectStatus.unsupportedPlatform;
      return false;
    }

    _status = HealthConnectStatus.connecting;
    _lastError = null;

    try {
      if (!_isConfigured) {
        await _health.configure();
        _isConfigured = true;
      }

      final sdkStatus = await _health.getHealthConnectSdkStatus();
      if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
        if (sdkStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          _status = HealthConnectStatus.sdkUpdateRequired;
        } else {
          _status = HealthConnectStatus.sdkUnavailable;
        }
        return false;
      }

      // Check current permissions first to avoid redundant native sheets
      final currentPerms = await _health.hasPermissions(supportedTypes, permissions: readPermissions);
      if (currentPerms == true) {
        _status = HealthConnectStatus.connected;
        return true;
      }

      final authorized = await _health.requestAuthorization(supportedTypes, permissions: readPermissions);
      if (authorized) {
        _status = HealthConnectStatus.connected;
        return true;
      } else {
        // Verify if partial or full permissions were granted
        final recheck = await _health.hasPermissions(supportedTypes, permissions: readPermissions);
        if (recheck == true) {
          _status = HealthConnectStatus.connected;
          return true;
        } else {
          final partial = await _hasAnyPermission();
          _status = partial ? HealthConnectStatus.permissionPartiallyGranted : HealthConnectStatus.permissionRequired;
          return partial;
        }
      }
    } catch (e) {
      _lastError = 'Permission request failed: $e';
      _status = HealthConnectStatus.permissionRequired;
      return false;
    }
  }

  /// Prompts user to install Google Health Connect via the Android Play Store.
  Future<void> installHealthConnect() async {
    if (!isPlatformSupported) return;
    try {
      await _health.installHealthConnect();
    } catch (e) {
      _lastError = 'Unable to launch Health Connect installation: $e';
    }
  }

  /// Synchronizes real health data from Health Connect and uploads to the OS4All backend.
  /// First sync reads up to the last 30 days. Subsequent syncs read the last 7 days overlapping.
  Future<HealthSyncResult> syncHealthData({int daysToRead = 30}) async {
    if (!isPlatformSupported) {
      return HealthSyncResult.failed('Google Health Connect is only supported on Android devices.');
    }

    final currentStatus = await checkStatus();
    if (currentStatus != HealthConnectStatus.connected &&
        currentStatus != HealthConnectStatus.permissionPartiallyGranted) {
      return HealthSyncResult.failed(
        'Health Connect permissions have not been granted. Please authorize access first.',
      );
    }

    _status = HealthConnectStatus.syncing;
    _lastError = null;

    final now = DateTime.now();
    // Default to 30 days for fresh sync, or 7 days for catch-up sync if already synced recently
    final windowDays = _lastSyncTime == null ? daysToRead.clamp(1, 30) : 7;
    final startTime = now.subtract(Duration(days: windowDays));
    final endTime = now;

    try {
      final userId = await TokenStorage.getUserId() ?? await TokenStorage.getUserEmail() ?? 'unknown_user';
      final ledger = await _loadDeduplicationLedger(userId);

      final List<NormalizedHealthRecord> normalizedRecords = [];
      final Map<String, int> metricBreakdown = {};

      // 1. Fetch raw points for high-fidelity continuous streams
      final rawPoints = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: supportedTypes,
      );

      // Separate step points from other vitals for proper daily aggregation
      final Map<String, int> dailyStepAggregates = {};
      final List<HealthDataPoint> vitalPoints = [];

      for (final pt in rawPoints) {
        if (pt.type == HealthDataType.STEPS) {
          final dateKey = _formatDateKey(pt.dateFrom);
          final numVal = _extractNumericValue(pt.value);
          if (numVal != null && numVal > 0) {
            dailyStepAggregates[dateKey] = (dailyStepAggregates[dateKey] ?? 0) + numVal.toInt();
          }
        } else {
          vitalPoints.add(pt);
        }
      }

      // Process vital records
      for (final pt in vitalPoints) {
        final normalized = _normalizeDataPoint(pt, userId);
        if (normalized != null) {
          normalizedRecords.add(normalized);
        }
      }

      // Process daily step totals (aggregated by date to avoid sensor duplication)
      for (final entry in dailyStepAggregates.entries) {
        final dateKey = entry.key;
        final stepCount = entry.value;
        if (stepCount > 0 && stepCount <= 150000) {
          final dayDate = DateTime.tryParse('${dateKey}T12:00:00Z') ?? now;
          final dedupKey = '${userId}_STEPS_${dateKey}_$stepCount';
          normalizedRecords.add(
            NormalizedHealthRecord(
              deduplicationKey: dedupKey,
              metricType: 'STEPS',
              vitalName: 'STEPS',
              value: stepCount.toDouble(),
              unit: 'steps',
              timestamp: dayDate,
              source: 'Google Health Connect (Daily Aggregate)',
              confidence: 0.99,
              metadata: jsonEncode({
                'healthConnectType': 'STEPS',
                'aggregation': 'DAILY_TOTAL',
                'date': dateKey,
                'steps': stepCount,
              }),
            ),
          );
        }
      }

      // Deduplicate against persistent local ledger
      int importedCount = 0;
      int skippedDuplicates = 0;
      int failedCount = 0;
      final Set<String> newLedgerKeys = Set.from(ledger);

      for (final record in normalizedRecords) {
        if (ledger.contains(record.deduplicationKey)) {
          skippedDuplicates++;
          continue;
        }

        try {
          // Upload to real OS4All backend API
          await _healthApiService.logObservation(
            observationType: record.metricType,
            vitalName: record.vitalName,
            valueNumeric: record.value,
            unit: record.unit,
            source: record.source,
            timestamp: record.timestamp,
            confidence: record.confidence,
            metadata: record.metadata,
            durationMinutes: record.durationMinutes,
          );

          // ONLY add to ledger after successful backend persistence
          if (record.metricType == 'STEPS') {
            final datePrefix = '${userId}_STEPS_${_formatDateKey(record.timestamp)}';
            newLedgerKeys.remove(datePrefix); // Remove legacy key without count
            newLedgerKeys.removeWhere((k) => k.startsWith('${datePrefix}_'));
          }
          newLedgerKeys.add(record.deduplicationKey);
          importedCount++;
          metricBreakdown[record.metricType] = (metricBreakdown[record.metricType] ?? 0) + 1;
        } catch (uploadError) {
          failedCount++;
          debugPrint('Error uploading observation ${record.deduplicationKey}: $uploadError');
          // Item was NOT added to newLedgerKeys, so it remains retryable on next sync!
        }
      }

      // Persist updated ledger and sync state
      await _saveDeduplicationLedger(userId, newLedgerKeys);
      await _persistSyncInfo(now, importedCount, skippedDuplicates);

      _status = HealthConnectStatus.syncSuccess;
      _lastSyncTime = now;
      _lastImportedCount = importedCount;
      _lastSkippedCount = skippedDuplicates;

      return HealthSyncResult(
        syncTime: now,
        totalRead: normalizedRecords.length,
        importedCount: importedCount,
        skippedDuplicates: skippedDuplicates,
        failedCount: failedCount,
        metricCounts: metricBreakdown,
        isSuccess: true,
      );
    } catch (e) {
      _lastError = 'Health sync failed: $e';
      _status = HealthConnectStatus.syncError;
      return HealthSyncResult.failed(_lastError!);
    }
  }

  /// Normalizes a native HealthDataPoint into a medically valid OS4All record.
  NormalizedHealthRecord? _normalizeDataPoint(HealthDataPoint pt, String userId) {
    final numVal = _extractNumericValue(pt.value);
    if (numVal == null || numVal.isNaN || numVal.isInfinite) return null;

    final date = pt.dateFrom;
    final uuid = pt.uuid.isNotEmpty ? pt.uuid : '${pt.type.name}_${date.millisecondsSinceEpoch}';

    switch (pt.type) {
      case HealthDataType.HEART_RATE:
        final bpm = numVal.toDouble();
        if (bpm < 30 || bpm > 220) return null;
        return NormalizedHealthRecord(
          deduplicationKey: '${userId}_HEART_RATE_$uuid',
          metricType: 'HEART_RATE',
          vitalName: 'HEART_RATE',
          value: bpm,
          unit: 'bpm',
          timestamp: date,
          source: 'Google Health Connect',
          confidence: 0.98,
          metadata: jsonEncode({'healthConnectId': uuid, 'type': 'HEART_RATE'}),
        );

      case HealthDataType.RESTING_HEART_RATE:
        final bpm = numVal.toDouble();
        if (bpm < 35 || bpm > 140) return null;
        return NormalizedHealthRecord(
          deduplicationKey: '${userId}_RESTING_HEART_RATE_$uuid',
          metricType: 'HEART_RATE',
          vitalName: 'RESTING_HEART_RATE',
          value: bpm,
          unit: 'bpm',
          timestamp: date,
          source: 'Google Health Connect',
          confidence: 0.99,
          metadata: jsonEncode({'healthConnectId': uuid, 'type': 'RESTING_HEART_RATE'}),
        );

      case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
        final rmssd = numVal.toDouble();
        if (rmssd < 5 || rmssd > 300) return null;
        return NormalizedHealthRecord(
          deduplicationKey: '${userId}_HRV_$uuid',
          metricType: 'HRV',
          vitalName: 'HRV',
          value: rmssd,
          unit: 'ms',
          timestamp: date,
          source: 'Google Health Connect (RMSSD)',
          confidence: 0.97,
          metadata: jsonEncode({'healthConnectId': uuid, 'type': 'HRV_RMSSD'}),
        );

      case HealthDataType.BLOOD_OXYGEN:
        var spo2 = numVal.toDouble();
        // Normalize fraction (0.98 -> 98.0%)
        if (spo2 <= 1.0 && spo2 > 0.0) {
          spo2 = spo2 * 100.0;
        }
        if (spo2 < 70 || spo2 > 100) return null;
        return NormalizedHealthRecord(
          deduplicationKey: '${userId}_SPO2_$uuid',
          metricType: 'OXYGEN_SATURATION',
          vitalName: 'OXYGEN_SATURATION',
          value: double.parse(spo2.toStringAsFixed(1)),
          unit: '%',
          timestamp: date,
          source: 'Google Health Connect',
          confidence: 0.99,
          metadata: jsonEncode({'healthConnectId': uuid, 'type': 'BLOOD_OXYGEN'}),
        );

      case HealthDataType.SLEEP_SESSION:
        // Duration in minutes and hours
        final durationMinutes = pt.dateTo.difference(pt.dateFrom).inMinutes;
        if (durationMinutes < 15 || durationMinutes > 1440) return null;
        final hours = durationMinutes / 60.0;
        return NormalizedHealthRecord(
          deduplicationKey: '${userId}_SLEEP_$uuid',
          metricType: 'SLEEP',
          vitalName: 'SLEEP',
          value: double.parse(hours.toStringAsFixed(2)),
          unit: 'hours',
          timestamp: pt.dateFrom,
          durationMinutes: durationMinutes,
          source: 'Google Health Connect (Sleep Session)',
          confidence: 0.98,
          metadata: jsonEncode({
            'healthConnectId': uuid,
            'sleepStart': pt.dateFrom.toIso8601String(),
            'sleepEnd': pt.dateTo.toIso8601String(),
            'durationMinutes': durationMinutes,
          }),
        );

      case HealthDataType.BODY_TEMPERATURE:
        var tempC = numVal.toDouble();
        // Convert Fahrenheit if detected
        if (tempC > 80.0 && tempC < 115.0) {
          tempC = (tempC - 32.0) * (5.0 / 9.0);
        }
        if (tempC < 32.0 || tempC > 44.0) return null;
        return NormalizedHealthRecord(
          deduplicationKey: '${userId}_BODY_TEMPERATURE_$uuid',
          metricType: 'BODY_TEMPERATURE',
          vitalName: 'BODY_TEMPERATURE',
          value: double.parse(tempC.toStringAsFixed(2)),
          unit: '°C',
          timestamp: date,
          source: 'Google Health Connect',
          confidence: 0.98,
          metadata: jsonEncode({'healthConnectId': uuid, 'type': 'BODY_TEMPERATURE'}),
        );

      default:
        return null;
    }
  }

  num? _extractNumericValue(HealthValue val) {
    if (val is NumericHealthValue) return val.numericValue;
    try {
      final json = val.toJson();
      if (json.containsKey('numericValue') && json['numericValue'] is num) {
        return json['numericValue'] as num;
      }
    } catch (_) {}
    return null;
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // --- Persistent Deduplication Ledger ---

  Future<Set<String>> _loadDeduplicationLedger(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'os4all_hc_ledger_$userId';
      final list = prefs.getStringList(key);
      return list != null ? list.toSet() : <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _saveDeduplicationLedger(String userId, Set<String> keys) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'os4all_hc_ledger_$userId';
      // Keep most recent 5,000 keys to avoid unlimited storage growth
      final list = keys.toList();
      final trimmed = list.length > 5000 ? list.sublist(list.length - 5000) : list;
      await prefs.setStringList(key, trimmed);
    } catch (_) {}
  }

  Future<void> _persistSyncInfo(DateTime syncTime, int imported, int skipped) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('os4all_hc_last_sync_time', syncTime.toIso8601String());
      await prefs.setInt('os4all_hc_last_imported', imported);
      await prefs.setInt('os4all_hc_last_skipped', skipped);
    } catch (_) {}
  }

  Future<void> _restorePersistedSyncInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString('os4all_hc_last_sync_time');
      if (timeStr != null) {
        _lastSyncTime = DateTime.tryParse(timeStr);
      }
      _lastImportedCount = prefs.getInt('os4all_hc_last_imported') ?? 0;
      _lastSkippedCount = prefs.getInt('os4all_hc_last_skipped') ?? 0;
    } catch (_) {}
  }

  /// Clears in-memory sync stats on user logout so next authenticated user has clean state.
  void clearSyncStateOnLogout() {
    _status = HealthConnectStatus.notConnected;
    _lastSyncTime = null;
    _lastImportedCount = 0;
    _lastSkippedCount = 0;
    _lastError = null;
  }

  // =========================================================================
  // TEST HELPERS (Visible for unit verification)
  // =========================================================================
  NormalizedHealthRecord? normalizeDataPointForTesting(HealthDataPoint pt, String userId) {
    return _normalizeDataPoint(pt, userId);
  }

  Future<bool> isPointInLedgerForTesting(String userId, String type, String pointUuid) async {
    final ledger = await _loadDeduplicationLedger(userId);
    final key = '${userId}_${type}_$pointUuid';
    return ledger.contains(key);
  }

  Future<void> recordPointInLedgerForTesting(String userId, String type, String pointUuid) async {
    final ledger = await _loadDeduplicationLedger(userId);
    final key = '${userId}_${type}_$pointUuid';
    ledger.add(key);
    await _saveDeduplicationLedger(userId, ledger);
  }

  Future<bool> isStepTotalInLedgerForTesting(String userId, String dateKey, int stepCount) async {
    final ledger = await _loadDeduplicationLedger(userId);
    final key = '${userId}_STEPS_${dateKey}_$stepCount';
    return ledger.contains(key);
  }

  Future<void> recordStepTotalInLedgerForTesting(String userId, String dateKey, int stepCount) async {
    final ledger = await _loadDeduplicationLedger(userId);
    final datePrefix = '${userId}_STEPS_$dateKey';
    ledger.remove(datePrefix);
    ledger.removeWhere((k) => k.startsWith('${datePrefix}_'));
    ledger.add('${userId}_STEPS_${dateKey}_$stepCount');
    await _saveDeduplicationLedger(userId, ledger);
  }
}
