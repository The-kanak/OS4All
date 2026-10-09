import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/app_config.dart';
import '../../core/services/api_services.dart';
import '../../core/services/health_connect_service.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/demo_data.dart';

/// Global application state manager for OS4All.
/// Controls Live Mode vs Demo Mode, authentication, and live domain data fetching.
class AppStateManager extends ChangeNotifier {
  static final AppStateManager instance = AppStateManager();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final HealthService _healthService = HealthService();
  final ReportsService _reportsService = ReportsService();
  final AiService _aiService = AiService();
  final CounselorService _counselorService = CounselorService();
  final DemoService _demoService = DemoService();
  final HealthConnectService _healthConnectService = HealthConnectService();

  // Authentication & Session
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  bool _isLiveMode = true; // True for real backend APIs, false for synthetic demo mode
  String? _userToken;
  String _userEmail = '';
  String _userName = '';

  // Domain State
  UserProfileModel? _profile;
  HealthStatusSummaryModel? _healthStatus;
  BaselineProfileModel? _baselineProfile;
  List<TimelineItemModel> _timeline = [];
  List<LabReportModel> _labReports = [];
  AiInsightModel? _latestInsight;
  final List<CounselorConversationSummary> _conversations = [];
  final Map<String, bool> _consents = {
    'DATA_STORAGE': true,
    'AI_INFERENCE': true,
    'EVIDENCE_SEARCH': true,
  };

  // UI State
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLiveMode => _isLiveMode;
  bool get isDemoMode => !_isLiveMode;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String? get userToken => _userToken;
  UserProfileModel? get profile => _profile;
  UserProfileModel? get userProfile => _profile;
  HealthStatusSummaryModel? get healthStatus => _healthStatus;
  BaselineProfileModel? get baselineProfile => _baselineProfile;
  List<BaselineMetricModel> get baselines => _baselineProfile?.metrics ?? [];
  List<HealthSignalModel> get signals => _healthStatus?.signals ?? [];
  List<TimelineItemModel> get timeline => _timeline;
  List<LabReportModel> get labReports => _labReports;
  AiInsightModel? get latestInsight => _latestInsight;
  List<CounselorConversationSummary> get conversations => _conversations;
  Map<String, bool> get consents => _consents;
  UserConsentModel? get consent => UserConsentModel(
        dataStorageConsent: _consents['DATA_STORAGE'] ?? true,
        aiProcessingConsent: _consents['AI_INFERENCE'] ?? true,
        evidenceSearchConsent: _consents['EVIDENCE_SEARCH'] ?? _consents['EVIDENCE_RETRIEVAL'] ?? true,
      );
  HealthConnectService get healthConnect => _healthConnectService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initializes session and preferences from persistent local storage.
  Future<void> initialize() async {
    final token = await TokenStorage.getToken();
    final email = await TokenStorage.getUserEmail();
    final name = await TokenStorage.getUserName();
    final live = await TokenStorage.isLiveMode();
    final customUrl = await TokenStorage.getCustomBaseUrl();

    if (customUrl != null && customUrl.isNotEmpty) {
      AppConfig.setCustomBaseUrl(customUrl);
    }

    _userToken = token;
    _userEmail = email ?? '';
    _userName = name ?? '';
    _isAuthenticated = token != null && token.isNotEmpty;
    _isLiveMode = live;
    _isInitialized = true;

    // Check Google Health Connect state asynchronously on supported platforms
    await _healthConnectService.checkStatus();

    if (_isAuthenticated || !_isLiveMode) {
      await refreshAllData();
    }
    notifyListeners();
  }

  /// Sets Live Mode vs Demo Mode.
  Future<void> setLiveMode([bool live = true]) async {
    _isLiveMode = live;
    await TokenStorage.setLiveMode(live);
    await refreshAllData();
    notifyListeners();
  }

  Future<void> setDemoMode() async {
    await setLiveMode(false);
  }

  Future<void> setCustomBaseUrl(String url) async {
    AppConfig.setCustomBaseUrl(url);
    await TokenStorage.setCustomBaseUrl(url);
    notifyListeners();
  }

  /// Refreshes all domain data from backend in Live Mode or seeds Demo state.
  Future<void> refreshAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isLiveMode && _isAuthenticated) {
        await Future.wait([
          _fetchProfile(),
          _fetchHealthStatus(),
          _fetchBaseline(),
          _fetchTimeline(),
          _fetchLabReports(),
          _fetchConsents(),
        ]);
      } else {
        _populateFromDemoData();
      }
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Error loading health data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() => refreshAllData();
  Future<void> refreshHealthStatus() => _fetchHealthStatus();
  Future<void> refreshBaseline() => _fetchBaseline();
  Future<void> refreshTimeline() => _fetchTimeline();
  Future<void> refreshReports() => _fetchLabReports();

  Future<void> _fetchProfile() async {
    try {
      _profile = await _userService.getProfile();
      if (_profile != null && _profile!.fullName.isNotEmpty) {
        _userName = _profile!.fullName;
      }
    } catch (_) {}
  }

  Future<void> _fetchHealthStatus() async {
    try {
      _healthStatus = await _healthService.getHealthStatus();
    } catch (_) {}
  }

  Future<void> _fetchBaseline() async {
    try {
      _baselineProfile = await _healthService.getBaselineProfile();
    } catch (_) {}
  }

  Future<void> _fetchTimeline() async {
    try {
      _timeline = await _healthService.getTimeline();
    } catch (_) {}
  }

  Future<void> _fetchLabReports() async {
    try {
      _labReports = await _reportsService.getReports();
    } catch (_) {}
  }

  Future<void> _fetchConsents() async {
    try {
      final list = await _userService.getConsents();
      for (final c in list) {
        _consents[c.consentType] = c.isGranted;
      }
    } catch (_) {}
  }

  void _populateFromDemoData() {
    _userName = DemoData.userFullName;
    _userEmail = DemoData.userEmail;

    _healthStatus = HealthStatusSummaryModel(
      aggregateState: DemoData.currentHealthState,
      statusHeadline: DemoData.currentHealthSummary,
      activeSignalsCount: DemoData.keyMetrics.length,
      deviatingSignalsCount: 0,
      signals: DemoData.keyMetrics.map((m) {
        return HealthSignalModel(
          metric: m['metric'].toString().toLowerCase().replaceAll(' ', '_'),
          unit: m['unit'].toString(),
          currentValue: double.tryParse(m['value'].toString().replaceAll(',', '')) ?? 0.0,
          state: 'STABLE',
          explanation: '${m['metric']} is stable within personal baseline.',
        );
      }).toList(),
    );

    _baselineProfile = BaselineProfileModel(
      userId: 'demo-user-id',
      metrics: DemoData.personalBaselines.map((b) {
        return BaselineMetricModel(
          metric: b['metric'].toString(),
          unit: b['range'].toString(),
          mean: double.tryParse(b['mean'].toString().split(' ')[0]) ?? 60.0,
          observationCount: int.tryParse(b['count'].toString()) ?? 14,
          baselineEstablished: true,
          interpretation: 'Historical observations establish steady baseline stability.',
        );
      }).toList(),
    );

    _timeline = DemoData.timelineItems.map((item) {
      return TimelineItemModel(
        id: item['id'].toString(),
        title: item['title'].toString(),
        subtitle: item['subtitle'].toString(),
        timestamp: item['timestamp'].toString(),
        category: item['category'].toString(),
        source: item['source'].toString(),
      );
    }).toList();

    _labReports = DemoData.labReports.map((r) {
      return LabReportModel(
        id: r['id'].toString(),
        reportTitle: r['title'].toString(),
        laboratoryName: r['lab'].toString(),
        collectionDate: r['date'].toString(),
        results: (r['biomarkers'] as List<dynamic>).map((bm) {
          return LabResultItemModel(
            id: bm['name'].toString(),
            biomarker: bm['name'].toString(),
            standardizedBiomarker: bm['name'].toString(),
            value: double.tryParse(bm['value'].toString()) ?? 0.0,
            unit: bm['unit'].toString(),
          );
        }).toList(),
      );
    }).toList();

    _latestInsight = AiInsightModel.fromJson(DemoData.latestAiInsight);
  }

  // Auth Operations
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(email, password);
      _userToken = res.token;
      _userEmail = res.email;
      _userName = res.fullName;
      _isAuthenticated = true;
      await refreshAllData();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Sign in failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.register(email, password, fullName);
      _userToken = res.token;
      _userEmail = res.email;
      _userName = res.fullName;
      _isAuthenticated = true;
      await refreshAllData();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Registration failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _userToken = null;
    _profile = null;
    _healthStatus = null;
    _baselineProfile = null;
    _timeline = [];
    _labReports = [];
    _latestInsight = null;
    notifyListeners();
  }

  // Profile Update
  Future<bool> updateProfile(UserProfileModel updated) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_isLiveMode && _isAuthenticated) {
        _profile = await _userService.updateProfile(
          fullName: updated.fullName,
          biologicalSex: updated.biologicalSex,
          heightCm: updated.heightCm,
          weightKg: updated.weightKg,
        );
      } else {
        _profile = updated;
        _userName = updated.fullName;
      }
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Observation Ingestion
  Future<bool> addObservation(HealthObservationModel obs) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_isLiveMode && _isAuthenticated) {
        await _healthService.logObservation(
          observationType: obs.metricType,
          valueNumeric: obs.value,
          unit: obs.unit,
          source: obs.source,
        );
        await refreshAllData();
      } else {
        await Future.delayed(const Duration(milliseconds: 250));
      }
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Consent Operations
  Future<bool> submitConsent(UserConsentModel model) async {
    _isLoading = true;
    notifyListeners();
    try {
      _consents['DATA_STORAGE'] = model.dataStorageConsent;
      _consents['AI_INFERENCE'] = model.aiProcessingConsent;
      _consents['EVIDENCE_SEARCH'] = model.evidenceSearchConsent;
      if (_isLiveMode && _isAuthenticated) {
        await _userService.updateConsent('DATA_STORAGE', model.dataStorageConsent);
        await _userService.updateConsent('AI_INFERENCE', model.aiProcessingConsent);
        await _userService.updateConsent('EVIDENCE_SEARCH', model.evidenceSearchConsent);
      }
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Report Upload & Confirmation
  Future<LabReportModel?> uploadReport(Uint8List fileBytes, String filename, {String? title}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _reportsService.uploadReport(
        fileBytes: fileBytes,
        filename: filename,
        title: title,
      );
      _labReports.insert(0, report);
      await _fetchTimeline();
      return report;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Report upload failed: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmReport(String reportId, [List<Map<String, dynamic>> items = const []]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final confirmed = await _reportsService.confirmReport(reportId: reportId, items: items);
      final idx = _labReports.indexWhere((r) => r.id == reportId);
      if (idx != -1) {
        _labReports[idx] = confirmed;
      }
      await _fetchTimeline();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // AI & Counselor Operations
  Future<AiInsightModel?> evaluateInsight() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isLiveMode && _isAuthenticated) {
        _latestInsight = await _aiService.evaluateInsights();
      } else {
        _latestInsight = AiInsightModel.fromJson(DemoData.latestAiInsight);
      }
      return _latestInsight;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CounselorResponseDto?> sendCounselorMessage(String message, {String? conversationId}) async {
    if (_isLiveMode && _isAuthenticated) {
      try {
        return await _counselorService.sendMessage(
          message: message,
          conversationId: conversationId,
        );
      } catch (e) {
        _errorMessage = e is ApiException ? e.message : e.toString();
        return null;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      return CounselorResponseDto(
        conversationId: conversationId ?? 'demo-convo-id',
        message: 'Based on your personal physiological baseline, your monitored vitals remain aligned with historical intervals.',
        observations: ['Baseline Resting HR: 60 bpm', 'Baseline HRV: 55 ms'],
        interpretations: ['Vitals reflect homeostatic autonomic recovery.'],
        actions: ['Continue tracking regular sleep and hydration.'],
      );
    }
  }

  // Demo Scenarios
  Future<void> runFlagshipDemo() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _demoService.runFlagshipScenario();
      await refreshAllData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> runDemoHealthDrift() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _demoService.runHealthDrift();
      await refreshAllData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetDemoScenario() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _demoService.resetDemo();
      await refreshAllData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Health Connect Operations
  Future<HealthConnectStatus> checkHealthConnectStatus() async {
    final status = await _healthConnectService.checkStatus();
    notifyListeners();
    return status;
  }

  Future<bool> connectHealthConnect() async {
    final success = await _healthConnectService.requestPermissions();
    notifyListeners();
    return success;
  }

  Future<HealthSyncResult> syncHealthConnect({int daysToRead = 30}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _healthConnectService.syncHealthData(daysToRead: daysToRead);
      if (result.isSuccess && result.importedCount > 0) {
        await refreshAllData();
      } else {
        notifyListeners();
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
