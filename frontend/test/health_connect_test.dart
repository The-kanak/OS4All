import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:os4all_frontend/core/services/health_connect_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthConnectService - Unit & Reliability Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      debugDefaultTargetPlatformOverride = null;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('isPlatformSupported returns false on non-Android platform (e.g. Windows/iOS)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final service = HealthConnectService();
      expect(service.isPlatformSupported, isFalse);
    });

    test('isPlatformSupported returns true on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final service = HealthConnectService();
      expect(service.isPlatformSupported, isTrue);
    });

    test('checkStatus on non-Android platform returns unsupportedPlatform honestly', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final service = HealthConnectService();
      final status = await service.checkStatus();
      expect(status, HealthConnectStatus.unsupportedPlatform);
      expect(service.status, HealthConnectStatus.unsupportedPlatform);
    });

    test('syncHealthData fails gracefully on unsupported platforms without faking', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final service = HealthConnectService();
      final result = await service.syncHealthData();
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Android devices'));
      expect(result.importedCount, equals(0));
    });

    test('Normalization bounds check verifies medically sound vitals', () {
      final service = HealthConnectService();

      // Test valid Resting HR
      final validHrPoint = HealthDataPoint(
        uuid: 'test-hr-uuid-1',
        value: NumericHealthValue(numericValue: 62),
        type: HealthDataType.RESTING_HEART_RATE,
        unit: HealthDataUnit.BEATS_PER_MINUTE,
        dateFrom: DateTime.now().subtract(const Duration(hours: 1)),
        dateTo: DateTime.now().subtract(const Duration(hours: 1)),
        sourcePlatform: HealthPlatformType.googleHealthConnect,
        sourceDeviceId: 'pixel-8-test',
        sourceId: 'com.google.android.apps.fitness',
        sourceName: 'Google Fit',
      );

      final normalizedHr = service.normalizeDataPointForTesting(validHrPoint, 'test-user-1');
      expect(normalizedHr, isNotNull);
      expect(normalizedHr!.metricType, equals('HEART_RATE'));
      expect(normalizedHr.vitalName, equals('RESTING_HEART_RATE'));
      expect(normalizedHr.value, equals(62.0));
      expect(normalizedHr.unit, equals('bpm'));

      // Test out-of-bounds Heart Rate (e.g. 500 bpm sensor error)
      final invalidHrPoint = HealthDataPoint(
        uuid: 'test-hr-uuid-2',
        value: NumericHealthValue(numericValue: 500),
        type: HealthDataType.RESTING_HEART_RATE,
        unit: HealthDataUnit.BEATS_PER_MINUTE,
        dateFrom: DateTime.now(),
        dateTo: DateTime.now(),
        sourcePlatform: HealthPlatformType.googleHealthConnect,
        sourceDeviceId: 'pixel-8-test',
        sourceId: 'com.google.android.apps.fitness',
        sourceName: 'Google Fit',
      );

      final discardedHr = service.normalizeDataPointForTesting(invalidHrPoint, 'test-user-1');
      expect(discardedHr, isNull);
    });

    test('Sleep session normalization calculates duration in minutes without stage duplication', () {
      final service = HealthConnectService();
      final sleepStart = DateTime.now().subtract(const Duration(hours: 8));
      final sleepEnd = DateTime.now().subtract(const Duration(hours: 1)); // 7 hours = 420 mins

      final sleepPoint = HealthDataPoint(
        uuid: 'test-sleep-uuid-1',
        value: NumericHealthValue(numericValue: 420),
        type: HealthDataType.SLEEP_SESSION,
        unit: HealthDataUnit.MINUTE,
        dateFrom: sleepStart,
        dateTo: sleepEnd,
        sourcePlatform: HealthPlatformType.googleHealthConnect,
        sourceDeviceId: 'pixel-8-test',
        sourceId: 'com.oura.ring',
        sourceName: 'Oura',
      );

      final normalizedSleep = service.normalizeDataPointForTesting(sleepPoint, 'test-user-1');
      expect(normalizedSleep, isNotNull);
      expect(normalizedSleep!.metricType, equals('SLEEP'));
      expect(normalizedSleep.durationMinutes, equals(420));
      expect(normalizedSleep.value, equals(7.0)); // 420 mins / 60
      expect(normalizedSleep.unit, equals('hours'));
    });

    test('Persistent deduplication ledger ignores already processed Health Connect points', () async {
      SharedPreferences.setMockInitialValues({});
      final service = HealthConnectService();

      const userId = 'patient-42';
      const pointKey = 'test-spo2-uuid-99';

      // First check: should be unrecorded
      final isSeen1 = await service.isPointInLedgerForTesting(userId, 'BLOOD_OXYGEN', pointKey);
      expect(isSeen1, isFalse);

      // Record in ledger
      await service.recordPointInLedgerForTesting(userId, 'BLOOD_OXYGEN', pointKey);

      // Second check: should now be detected as duplicate
      final isSeen2 = await service.isPointInLedgerForTesting(userId, 'BLOOD_OXYGEN', pointKey);
      expect(isSeen2, isTrue);

      // Ledger for different user should NOT collide
      final isSeenOtherUser = await service.isPointInLedgerForTesting('patient-999', 'BLOOD_OXYGEN', pointKey);
      expect(isSeenOtherUser, isFalse);
    });

    test('clearSyncStateOnLogout resets local sync metadata cleanly', () {
      final service = HealthConnectService();
      service.clearSyncStateOnLogout();
      expect(service.status, equals(HealthConnectStatus.notConnected));
      expect(service.lastSyncTime, isNull);
      expect(service.lastImportedCount, equals(0));
      expect(service.lastSkippedCount, equals(0));
      expect(service.lastError, isNull);
    });
  });
}
