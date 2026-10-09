import '../network/api_client.dart';
import '../models/models.dart';
import '../storage/token_storage.dart';

/// Centralized API services translating raw HTTP into strongly typed domain objects.

class AuthService {
  final ApiClient _client = ApiClient();

  Future<AuthResponse> login(String email, String password) async {
    final data = await _client.post(
      '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await TokenStorage.saveUserSession(
      token: response.token,
      email: response.email,
      fullName: response.fullName,
    );
    return response;
  }

  Future<AuthResponse> register(String email, String password, String fullName) async {
    final data = await _client.post(
      '/auth/register',
      body: {
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
      },
    );
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await TokenStorage.saveUserSession(
      token: response.token,
      email: response.email,
      fullName: response.fullName,
    );
    return response;
  }

  Future<void> logout() async {
    await TokenStorage.clearSession();
  }
}

class UserService {
  final ApiClient _client = ApiClient();

  Future<UserProfileModel> getProfile() async {
    final data = await _client.get('/users/me');
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? dateOfBirth,
    String? biologicalSex,
    double? heightCm,
    double? weightKg,
    String? bloodType,
    String? lifestyleNotes,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (biologicalSex != null) body['biologicalSex'] = biologicalSex;
    if (heightCm != null) body['heightCm'] = heightCm;
    if (weightKg != null) body['weightKg'] = weightKg;
    if (bloodType != null) body['bloodType'] = bloodType;
    if (lifestyleNotes != null) body['lifestyleNotes'] = lifestyleNotes;

    final data = await _client.put('/users/me', body: body);
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UserConsentModel>> getConsents() async {
    final data = await _client.get('/users/consent');
    if (data is List) {
      return data.map((e) => UserConsentModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<UserConsentModel> updateConsent(String consentType, bool isGranted) async {
    final mappedType = consentType == 'EVIDENCE_RETRIEVAL' ? 'EVIDENCE_SEARCH' : consentType;
    final data = await _client.post(
      '/users/consent',
      body: {
        'consentType': mappedType,
        'granted': isGranted,
      },
    );
    return UserConsentModel.fromJson(data as Map<String, dynamic>);
  }
}

class HealthService {
  final ApiClient _client = ApiClient();

  Future<HealthStatusSummaryModel> getHealthStatus() async {
    final data = await _client.get('/health/status');
    return HealthStatusSummaryModel.fromJson(data as Map<String, dynamic>);
  }

  Future<BaselineProfileModel> getBaselineProfile() async {
    final data = await _client.get('/health/baseline');
    return BaselineProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<HealthSignalModel>> getSignals() async {
    final data = await _client.get('/health/signals');
    if (data is List) {
      return data.map((e) => HealthSignalModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<TimelineItemModel>> getTimeline({String? category}) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty && category != 'ALL') {
      queryParams['category'] = category;
    }
    final data = await _client.get('/health/timeline', queryParameters: queryParams);
    if (data is List) {
      return data.map((e) => TimelineItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> logObservation({
    required String observationType,
    required double valueNumeric,
    required String unit,
    String? source,
  }) async {
    String mappedType;
    switch (observationType.toUpperCase()) {
      case 'HEART_RATE':
      case 'RESTING_HEART_RATE':
        mappedType = 'HEART_RATE';
        break;
      case 'HRV':
        mappedType = 'HRV';
        break;
      case 'SPO2':
      case 'OXYGEN_SATURATION':
        mappedType = 'OXYGEN_SATURATION';
        break;
      case 'SLEEP':
      case 'SLEEP_DURATION':
        mappedType = 'SLEEP';
        break;
      case 'BODY_TEMP':
      case 'BODY_TEMPERATURE':
      case 'TEMPERATURE':
        mappedType = 'BODY_TEMPERATURE';
        break;
      case 'STEPS':
      case 'ACTIVITY':
        mappedType = 'STEPS';
        break;
      case 'BLOOD_GLUCOSE':
      case 'GLUCOSE':
        mappedType = 'BLOOD_GLUCOSE';
        break;
      case 'BLOOD_PRESSURE_SYSTOLIC':
      case 'SYSTOLIC':
        mappedType = 'BLOOD_PRESSURE_SYSTOLIC';
        break;
      case 'BLOOD_PRESSURE_DIASTOLIC':
      case 'DIASTOLIC':
        mappedType = 'BLOOD_PRESSURE_DIASTOLIC';
        break;
      default:
        mappedType = 'GENERAL';
    }

    await _client.post(
      '/health/observations',
      body: {
        'type': mappedType,
        'vitalName': mappedType,
        'valueNumeric': valueNumeric,
        'unit': unit,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'source': source ?? 'Manual Entry',
      },
    );
  }
}

class ReportsService {
  final ApiClient _client = ApiClient();

  Future<List<LabReportModel>> getReports() async {
    final data = await _client.get('/reports');
    if (data is Map<String, dynamic> && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => LabReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is List) {
      return data.map((e) => LabReportModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<LabReportModel> uploadReport({
    required List<int> fileBytes,
    required String filename,
    String? title,
  }) async {
    final data = await _client.uploadReport(
      fileBytes: fileBytes,
      filename: filename,
      title: title,
    );
    return LabReportModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LabReportModel> confirmReport({
    required String reportId,
    required List<Map<String, dynamic>> items,
  }) async {
    final data = await _client.post(
      '/reports/$reportId/confirm',
      body: {
        'items': items,
      },
    );
    return LabReportModel.fromJson(data as Map<String, dynamic>);
  }
}

class AiService {
  final ApiClient _client = ApiClient();

  Future<AiInsightModel> evaluateInsights() async {
    final data = await _client.post('/ai/insights/evaluate');
    return AiInsightModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<EvidenceCitationModel>> searchEvidence(String query) async {
    final data = await _client.get('/evidence/search', queryParameters: {'query': query});
    if (data is Map<String, dynamic> && data['sources'] is List) {
      return (data['sources'] as List)
          .map((e) => EvidenceCitationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class CounselorService {
  final ApiClient _client = ApiClient();

  Future<CounselorResponseDto> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    final body = <String, dynamic>{
      'message': message.trim(),
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversationId'] = conversationId;
    }

    final data = await _client.post('/counselor/chat', body: body);
    return CounselorResponseDto.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CounselorConversationSummary>> getConversations() async {
    final data = await _client.get('/counselor/conversations');
    if (data is Map<String, dynamic> && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => CounselorConversationSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is List) {
      return data.map((e) => CounselorConversationSummary.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

class DemoService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> resetDemo() async {
    final data = await _client.post('/demo/reset');
    return data as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> runHealthDrift() async {
    final data = await _client.post('/demo/run-health-drift');
    return data as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> runFlagshipScenario() async {
    final data = await _client.post('/demo/run-flagship-scenario');
    return data as Map<String, dynamic>? ?? {};
  }
}

class EvidenceService {
  static final AiService _ai = AiService();
  static Future<List<EvidenceCitationModel>> search(String query) => _ai.searchEvidence(query);
}
