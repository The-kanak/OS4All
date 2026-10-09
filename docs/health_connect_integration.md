# Google Health Connect Integration Guide — OS4All

## 1. Architecture Overview

OS4All incorporates native **Google Health Connect** for Android, ingesting wearable and sensor telemetry directly into the patient's local and backend timeline.

```text
┌─────────────────────────┐       ┌────────────────────────┐       ┌───────────────────────────┐
│ Google Health Connect   │ ----> │ HealthConnectService   │ ----> │ OS4All Spring Boot API    │
│ (Android Native Sensor) │       │ (Bounds, Dedup Ledger) │       │ POST /health/observations │
└─────────────────────────┘       └────────────────────────┘       └───────────────────────────┘
                                              │                                  │
                                              ▼                                  ▼
                                  ┌────────────────────────┐       ┌───────────────────────────┐
                                  │ SharedPreferences      │       │ Personal Baseline Engine  │
                                  │ Deduplication Ledger   │       │ & Anomaly Detection       │
                                  └────────────────────────┘       └───────────────────────────┘
```

---

## 2. Supported Metrics & Backend Mapping

| Health Connect Data Type | Backend Metric Type | Unit | Physiological Filtering / Validation Bounds |
| :--- | :--- | :--- | :--- |
| `RESTING_HEART_RATE` | `HEART_RATE` | `bpm` | [35, 140] bpm. Tagged as `RESTING_HEART_RATE`. |
| `HEART_RATE` | `HEART_RATE` | `bpm` | [30, 220] bpm. High-frequency continuous samples. |
| `HEART_RATE_VARIABILITY_RMSSD` | `HRV` | `ms` | [5, 300] ms. Key autonomic recovery marker. |
| `BLOOD_OXYGEN` | `OXYGEN_SATURATION` | `%` | [70, 100]%. Normalized from decimals if needed. |
| `STEPS` | `STEPS` | `steps` | Daily aggregate per calendar day ([1, 150000] steps). |
| `SLEEP_SESSION` | `SLEEP` | `hours` | [15, 1440] minutes. Converted to hours, stage dedup. |
| `BODY_TEMPERATURE` | `TEMPERATURE` | `°C` | [32.0, 44.0] °C. Auto-converts °F if detected. |

*Note: Weight is supported by Health Connect but omitted from automated observation uploads because the backend `ObservationType` enum strictly defines: `HEART_RATE`, `BLOOD_PRESSURE`, `HRV`, `OXYGEN_SATURATION`, `TEMPERATURE`, `RESPIRATORY_RATE`, `GLUCOSE`, `SLEEP`, `STEPS`.*

---

## 3. Android Configuration & Permissions

### Manifest Declarations (`android/app/src/main/AndroidManifest.xml`)
- `minSdk = 26` configured in `android/app/build.gradle.kts`.
- Native activity inherits from `FlutterFragmentActivity` in `MainActivity.kt`.
- Package visibility queries for `com.google.android.apps.healthdata`.
- Health permissions declared:
  - `android.permission.health.READ_HEART_RATE`
  - `android.permission.health.READ_RESTING_HEART_RATE`
  - `android.permission.health.READ_HEART_RATE_VARIABILITY`
  - `android.permission.health.READ_OXYGEN_SATURATION`
  - `android.permission.health.READ_STEPS`
  - `android.permission.health.READ_SLEEP`
  - `android.permission.health.READ_BODY_TEMPERATURE`
- Rationale Intent-Filter registered on `MainActivity` for `androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE`.
- Permission usage alias registered: `ViewPermissionUsageActivity`.

---

## 4. Deduplication & Sync Mechanism

1. **Foreground User-Initiated Sync**: No hidden battery drains. Users tap "Sync Now" in either Profile or Health screens.
2. **Sync Window**: First sync queries up to the past **30 days**. Subsequent syncs query the past **7 days** with overlap.
3. **Persistent Deduplication Ledger**:
   - Stored in `SharedPreferences` scoped to authenticated user ID: `os4all_hc_ledger_<userId>`.
   - Key format: `<userId>_<metricType>_<recordUuid>`.
   - Records already present in the ledger are skipped, incrementing `skippedDuplicates` without sending duplicate network requests.
4. **Transparent UI Feedback**:
   - Badges indicate live state: `CONNECTED`, `SYNCING`, `PERMISSIONS NEEDED`, `NOT INSTALLED`, `ANDROID ONLY`.
   - On Web/Desktop, the UI clearly displays that native Health Connect runs on Android, keeping manual vital entry active.

---

## 5. Verification & Testing

Run unit tests verifying normalization bounds, platform detection, and ledger deduplication:
```bash
flutter test test/health_connect_test.dart
```

Verify static analysis:
```bash
flutter analyze
```
