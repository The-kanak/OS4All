/// Strongly typed DTO models corresponding directly to OS4All backend REST contracts.
library;

class AuthResponse {
  final String token;
  final String tokenType;
  final int expiresIn;
  final String email;
  final String fullName;

  AuthResponse({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.email,
    required this.fullName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 900,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
    );
  }
}

class UserProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? dateOfBirth;
  final String? biologicalSex;
  final double? heightCm;
  final double? weightKg;
  final String? bloodType;
  final String? lifestyleNotes;
  final int age;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'ROLE_USER',
    this.dateOfBirth,
    this.biologicalSex,
    this.heightCm,
    this.weightKg,
    this.bloodType,
    this.lifestyleNotes,
    this.age = 34,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Alex Rivera',
      role: json['role'] as String? ?? 'ROLE_USER',
      dateOfBirth: json['dateOfBirth'] as String?,
      biologicalSex: json['biologicalSex'] as String? ?? 'MALE',
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String? ?? 'O+',
      lifestyleNotes: json['lifestyleNotes'] as String?,
      age: (json['age'] as num?)?.toInt() ?? 34,
    );
  }
}

class UserConsentModel {
  final String consentType;
  final bool isGranted;
  final String? grantedAt;
  final String? revokedAt;
  final bool dataStorageConsent;
  final bool aiProcessingConsent;
  final bool evidenceSearchConsent;

  UserConsentModel({
    this.consentType = 'ALL',
    this.isGranted = true,
    this.grantedAt,
    this.revokedAt,
    this.dataStorageConsent = true,
    this.aiProcessingConsent = true,
    this.evidenceSearchConsent = true,
  });

  factory UserConsentModel.fromJson(Map<String, dynamic> json) {
    return UserConsentModel(
      consentType: json['consentType'] as String? ?? '',
      isGranted: (json['granted'] as bool?) ?? (json['isGranted'] as bool?) ?? false,
      grantedAt: json['grantedAt'] as String?,
      revokedAt: json['revokedAt'] as String?,
      dataStorageConsent: json['dataStorageConsent'] as bool? ?? true,
      aiProcessingConsent: json['aiProcessingConsent'] as bool? ?? true,
      evidenceSearchConsent: json['evidenceSearchConsent'] as bool? ?? true,
    );
  }
}

class HealthSignalModel {
  final String metric;
  final String unit;
  final double? baselineMean;
  final double? currentValue;
  final double? deviation;
  final double? deviationPercentage;
  final double? zScore;
  final String direction; // ELEVATED, DEPRESSED, STABLE
  final int persistenceDays;
  final int consecutiveDeviatingReadings;
  final double dataConfidence;
  final String state; // STABLE, DRIFT, ANOMALY, FOLLOW_UP
  final String explanation;

  HealthSignalModel({
    required this.metric,
    required this.unit,
    this.baselineMean,
    this.currentValue,
    this.deviation,
    this.deviationPercentage,
    this.zScore,
    this.direction = 'STABLE',
    this.persistenceDays = 0,
    this.consecutiveDeviatingReadings = 0,
    this.dataConfidence = 1.0,
    this.state = 'STABLE',
    this.explanation = '',
  });

  factory HealthSignalModel.fromJson(Map<String, dynamic> json) {
    return HealthSignalModel(
      metric: json['metric'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      baselineMean: (json['baselineMean'] as num?)?.toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble(),
      deviation: (json['deviation'] as num?)?.toDouble(),
      deviationPercentage: (json['deviationPercentage'] as num?)?.toDouble(),
      zScore: (json['zScore'] as num?)?.toDouble(),
      direction: json['direction'] as String? ?? 'STABLE',
      persistenceDays: (json['persistenceDays'] as num?)?.toInt() ?? 0,
      consecutiveDeviatingReadings: (json['consecutiveDeviatingReadings'] as num?)?.toInt() ?? 0,
      dataConfidence: (json['dataConfidence'] as num?)?.toDouble() ?? 1.0,
      state: json['state'] as String? ?? 'STABLE',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class AnomalyEventModel {
  final String primaryMetric;
  final List<String> affectedSignals;
  final String state; // STABLE, DRIFT, ANOMALY, FOLLOW_UP
  final bool multiSignalCorrelationDetected;
  final String patternName;
  final int durationDays;
  final double confidence;
  final String baselineComparison;
  final String reason;
  final String explanation;

  AnomalyEventModel({
    required this.primaryMetric,
    this.affectedSignals = const [],
    this.state = 'ANOMALY',
    this.multiSignalCorrelationDetected = false,
    this.patternName = '',
    this.durationDays = 1,
    this.confidence = 0.95,
    this.baselineComparison = '',
    this.reason = '',
    this.explanation = '',
  });

  factory AnomalyEventModel.fromJson(Map<String, dynamic> json) {
    return AnomalyEventModel(
      primaryMetric: json['primaryMetric'] as String? ?? '',
      affectedSignals: (json['affectedSignals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      state: json['state'] as String? ?? 'ANOMALY',
      multiSignalCorrelationDetected: json['multiSignalCorrelationDetected'] as bool? ?? false,
      patternName: json['patternName'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      baselineComparison: json['baselineComparison'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class HealthStatusSummaryModel {
  final String aggregateState; // STABLE, DRIFT, ANOMALY, FOLLOW_UP
  final String statusHeadline;
  final int activeSignalsCount;
  final int deviatingSignalsCount;
  final bool multiSignalPatternActive;
  final String patternSummary;
  final List<HealthSignalModel> signals;
  final List<AnomalyEventModel> activeAnomalies;

  String get state => aggregateState;
  String get summary => statusHeadline;

  HealthStatusSummaryModel({
    required this.aggregateState,
    required this.statusHeadline,
    this.activeSignalsCount = 0,
    this.deviatingSignalsCount = 0,
    this.multiSignalPatternActive = false,
    this.patternSummary = '',
    this.signals = const [],
    this.activeAnomalies = const [],
  });

  factory HealthStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return HealthStatusSummaryModel(
      aggregateState: json['aggregateState'] as String? ?? 'STABLE',
      statusHeadline: json['statusHeadline'] as String? ?? 'All tracked signals are stable.',
      activeSignalsCount: (json['activeSignalsCount'] as num?)?.toInt() ?? 0,
      deviatingSignalsCount: (json['deviatingSignalsCount'] as num?)?.toInt() ?? 0,
      multiSignalPatternActive: json['multiSignalPatternActive'] as bool? ?? false,
      patternSummary: json['patternSummary'] as String? ?? '',
      signals: (json['signals'] as List<dynamic>?)
              ?.map((e) => HealthSignalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeAnomalies: (json['activeAnomalies'] as List<dynamic>?)
              ?.map((e) => AnomalyEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BaselineMetricModel {
  final String metric;
  final String unit;
  final double? mean;
  final double? median;
  final double? standardDeviation;
  final double? min;
  final double? max;
  final double? baselineRangeLow;
  final double? baselineRangeHigh;
  final double? recentAverage;
  final double? deviationFromBaseline;
  final double? zScore;
  final String trendDirection; // INCREASING, DECREASING, STABLE, INSUFFICIENT_DATA
  final String interpretation;
  final bool baselineEstablished;
  final int observationCount;
  final int requiredObservations;

  BaselineMetricModel({
    required this.metric,
    required this.unit,
    this.mean,
    this.median,
    this.standardDeviation,
    this.min,
    this.max,
    this.baselineRangeLow,
    this.baselineRangeHigh,
    this.recentAverage,
    this.deviationFromBaseline,
    this.zScore,
    this.trendDirection = 'STABLE',
    this.interpretation = '',
    this.baselineEstablished = true,
    this.observationCount = 0,
    this.requiredObservations = 5,
  });

  factory BaselineMetricModel.fromJson(Map<String, dynamic> json) {
    return BaselineMetricModel(
      metric: json['metric'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      mean: (json['mean'] as num?)?.toDouble(),
      median: (json['median'] as num?)?.toDouble(),
      standardDeviation: (json['standardDeviation'] as num?)?.toDouble(),
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      baselineRangeLow: (json['baselineRangeLow'] as num?)?.toDouble(),
      baselineRangeHigh: (json['baselineRangeHigh'] as num?)?.toDouble(),
      recentAverage: (json['recentAverage'] as num?)?.toDouble(),
      deviationFromBaseline: (json['deviationFromBaseline'] as num?)?.toDouble(),
      zScore: (json['zScore'] as num?)?.toDouble(),
      trendDirection: json['trendDirection'] as String? ?? 'STABLE',
      interpretation: json['interpretation'] as String? ?? '',
      baselineEstablished: json['baselineEstablished'] as bool? ?? false,
      observationCount: (json['observationCount'] as num?)?.toInt() ?? 0,
      requiredObservations: (json['requiredObservations'] as num?)?.toInt() ?? 5,
    );
  }
}

class BaselineProfileModel {
  final String userId;
  final List<BaselineMetricModel> metrics;

  BaselineProfileModel({
    required this.userId,
    this.metrics = const [],
  });

  factory BaselineProfileModel.fromJson(Map<String, dynamic> json) {
    return BaselineProfileModel(
      userId: json['userId'] as String? ?? '',
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((e) => BaselineMetricModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TimelineItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final String category; // LAB, VITAL, LIFESTYLE, ANOMALY
  final String source;
  final String status;

  TimelineItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.category,
    required this.source,
    this.status = 'COMPLETED',
  });

  factory TimelineItemModel.fromJson(Map<String, dynamic> json) {
    return TimelineItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? json['date'] as String? ?? '',
      category: json['category'] as String? ?? 'VITAL',
      source: json['source'] as String? ?? 'Sensor',
      status: json['status'] as String? ?? 'COMPLETED',
    );
  }
}

class HealthObservationModel {
  final String metricType;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String source;
  final String? notes;

  HealthObservationModel({
    required this.metricType,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.source = 'MANUAL_ENTRY',
    this.notes,
  });

  factory HealthObservationModel.fromJson(Map<String, dynamic> json) {
    return HealthObservationModel(
      metricType: json['observationType'] as String? ?? json['metricType'] as String? ?? '',
      value: (json['valueNumeric'] as num?)?.toDouble() ?? (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      recordedAt: json['recordedAt'] != null ? DateTime.parse(json['recordedAt'] as String) : DateTime.now(),
      source: json['source'] as String? ?? 'MANUAL_ENTRY',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'observationType': metricType,
    'valueNumeric': value,
    'unit': unit,
    'recordedAt': recordedAt.toIso8601String(),
    'source': source,
    if (notes != null) 'notes': notes,
  };
}

class LabResultItemModel {
  final String id;
  final String biomarker;
  final String standardizedBiomarker;
  final double value;
  final String unit;
  final double? referenceLow;
  final double? referenceHigh;
  final double confidence;
  final bool reviewRequired;
  final bool isConfirmed;

  String get testName => biomarker;
  String get referenceRange => (referenceLow != null && referenceHigh != null) ? '$referenceLow - $referenceHigh' : '< 200';
  String get flag => reviewRequired ? 'HIGH' : 'NORMAL';

  LabResultItemModel({
    required this.id,
    required this.biomarker,
    required this.standardizedBiomarker,
    required this.value,
    required this.unit,
    this.referenceLow,
    this.referenceHigh,
    this.confidence = 1.0,
    this.reviewRequired = false,
    this.isConfirmed = true,
  });

  factory LabResultItemModel.fromJson(Map<String, dynamic> json) {
    return LabResultItemModel(
      id: json['id'] as String? ?? '',
      biomarker: json['biomarker'] as String? ?? json['name'] as String? ?? '',
      standardizedBiomarker: json['standardizedBiomarker'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      referenceLow: (json['referenceLow'] as num?)?.toDouble(),
      referenceHigh: (json['referenceHigh'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      reviewRequired: json['reviewRequired'] as bool? ?? false,
      isConfirmed: json['isConfirmed'] as bool? ?? true,
    );
  }
}

class LabReportModel {
  final String id;
  final String reportTitle;
  final String laboratoryName;
  final String collectionDate;
  final String ocrStatus;
  final double overallConfidence;
  final bool reviewRequired;
  final String fileName;
  final List<LabResultItemModel> results;

  LabReportModel({
    required this.id,
    required this.reportTitle,
    required this.laboratoryName,
    required this.collectionDate,
    this.ocrStatus = 'COMPLETED',
    this.overallConfidence = 1.0,
    this.reviewRequired = false,
    this.fileName = 'lab_report.pdf',
    this.results = const [],
  });

  factory LabReportModel.fromJson(Map<String, dynamic> json) {
    return LabReportModel(
      id: json['id'] as String? ?? '',
      reportTitle: json['reportTitle'] as String? ?? json['title'] as String? ?? 'Lab Panel',
      laboratoryName: json['laboratoryName'] as String? ?? json['lab'] as String? ?? 'Diagnostic Lab',
      collectionDate: json['collectionDate'] as String? ?? json['date'] as String? ?? '',
      ocrStatus: json['ocrStatus'] as String? ?? 'COMPLETED',
      overallConfidence: (json['overallConfidence'] as num?)?.toDouble() ?? 1.0,
      reviewRequired: json['reviewRequired'] as bool? ?? false,
      fileName: json['fileName'] as String? ?? json['title'] as String? ?? 'lab_report.pdf',
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => LabResultItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['biomarkers'] as List<dynamic>?)
              ?.map((e) => LabResultItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EvidenceCitationModel {
  final String title;
  final String source;
  final String urlOrDoi;
  final String relevance;

  String get journal => source;
  String get snippet => relevance;
  String get url => urlOrDoi;
  String get id => title.hashCode.toString();

  const EvidenceCitationModel({
    required this.title,
    required this.source,
    required this.urlOrDoi,
    required this.relevance,
    String? id,
    String? journal,
    String? snippet,
    String? url,
  });

  factory EvidenceCitationModel.fromJson(Map<String, dynamic> json) {
    return EvidenceCitationModel(
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? json['journal'] as String? ?? '',
      urlOrDoi: json['urlOrDoi'] as String? ?? json['url'] as String? ?? '',
      relevance: json['relevance'] as String? ?? json['snippet'] as String? ?? '',
    );
  }
}

class AiInsightModel {
  final String workflowId;
  final String summary;
  final List<String> observations;
  final List<String> possibleInterpretations;
  final List<String> recommendedActions;
  final List<EvidenceCitationModel> evidence;
  final double confidence;
  final String urgency; // ROUTINE, MONITOR, SEEK_VERIFICATION, EMERGENCY
  final String providerMode; // online or offline fallback
  final String modelName;
  final String disclaimer;

  List<String> get hypotheses => possibleInterpretations;
  List<String> get recommendations => recommendedActions;

  AiInsightModel({
    required this.workflowId,
    required this.summary,
    this.observations = const [],
    this.possibleInterpretations = const [],
    this.recommendedActions = const [],
    this.evidence = const [],
    this.confidence = 0.95,
    this.urgency = 'ROUTINE',
    this.providerMode = 'AI DEMO MODE',
    this.modelName = 'mock-deterministic',
    this.disclaimer = 'OS4All insights are strictly non-diagnostic situational awareness.',
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      workflowId: json['workflowId'] as String? ?? '',
      summary: json['summary'] as String? ?? 'All biometric vitals are aligned with your personal baseline.',
      observations: (json['observations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      possibleInterpretations:
          (json['possibleInterpretations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedActions:
          (json['recommendedActions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => EvidenceCitationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      urgency: json['urgency'] as String? ?? 'ROUTINE',
      providerMode: json['provider'] as String? ?? json['aiProviderMode'] as String? ?? json['providerMode'] as String? ?? 'AI Mode',
      modelName: json['model'] as String? ?? json['aiModelName'] as String? ?? json['modelName'] as String? ?? 'Nemotron-70B',
      disclaimer: json['disclaimer'] as String? ??
          'OS4All interpretations are based strictly on personal historical baselines and do not constitute a medical diagnosis.',
    );
  }
}

class CounselorResponseDto {
  final String conversationId;
  final String message;
  final List<String> observations;
  final List<String> interpretations;
  final List<String> actions;
  final String? evalGuidance;
  final String urgency;
  final bool isEmergency;
  final String disclaimer;
  final List<EvidenceCitationModel> externalEvidence;

  CounselorResponseDto({
    required this.conversationId,
    required this.message,
    this.observations = const [],
    this.interpretations = const [],
    this.actions = const [],
    this.externalEvidence = const [],
    this.evalGuidance,
    this.urgency = 'ROUTINE',
    this.isEmergency = false,
    this.disclaimer = 'OS4All Health Counselor does not provide medical diagnoses or replace medical professionals.',
  });

  factory CounselorResponseDto.fromJson(Map<String, dynamic> json) {
    final obsList = (json['os4allObservations'] ?? json['observations']) as List<dynamic>?;
    final interpList = (json['aiInterpretations'] ?? json['interpretations']) as List<dynamic>?;
    final actList = (json['recommendedActions'] ?? json['actions']) as List<dynamic>?;
    final isEmerg = (json['emergencyFlagged'] as bool?) ??
        (json['isEmergency'] as bool?) ??
        (json['urgency']?.toString().toUpperCase() == 'EMERGENCY');

    return CounselorResponseDto(
      conversationId: json['conversationId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      observations: obsList?.map((e) => e.toString()).toList() ?? [],
      interpretations: interpList?.map((e) => e.toString()).toList() ?? [],
      actions: actList?.map((e) => e.toString()).toList() ?? [],
      externalEvidence: (json['externalEvidence'] as List<dynamic>?)
              ?.map((e) => EvidenceCitationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evalGuidance: json['professionalEvaluationGuidance'] as String? ?? json['evalGuidance'] as String?,
      urgency: json['urgency'] as String? ?? 'ROUTINE',
      isEmergency: isEmerg,
      disclaimer: json['disclaimer'] as String? ??
          'OS4All Health Counselor does not provide medical diagnoses or replace medical professionals.',
    );
  }
}

class CounselorConversationSummary {
  final String id;
  final String title;
  final int messageCount;
  final String updatedAt;

  CounselorConversationSummary({
    required this.id,
    required this.title,
    required this.messageCount,
    required this.updatedAt,
  });

  factory CounselorConversationSummary.fromJson(Map<String, dynamic> json) {
    return CounselorConversationSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Health Consultation',
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
