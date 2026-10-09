package org.os4all.modules.ingestion.service;

import org.os4all.core.exception.ApiException;
import org.os4all.core.exception.ResourceNotFoundException;
import org.os4all.modules.audit.service.AuditService;
import org.os4all.modules.ingestion.dto.CreateObservationRequest;
import org.os4all.modules.ingestion.dto.ObservationResponse;
import org.os4all.modules.ingestion.entity.*;
import org.os4all.modules.ingestion.repository.HealthObservationRepository;
import org.os4all.modules.normalization.UnitNormalizationService;
import org.os4all.modules.user.entity.User;
import org.os4all.modules.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

@Service
public class HealthObservationService {

    private static final Logger log = LoggerFactory.getLogger(HealthObservationService.class);

    private final HealthObservationRepository observationRepository;
    private final UserRepository userRepository;
    private final UnitNormalizationService normalizationService;
    private final AuditService auditService;

    public HealthObservationService(
            HealthObservationRepository observationRepository,
            UserRepository userRepository,
            UnitNormalizationService normalizationService,
            AuditService auditService
    ) {
        this.observationRepository = observationRepository;
        this.userRepository = userRepository;
        this.normalizationService = normalizationService;
        this.auditService = auditService;
    }

    @Transactional
    public ObservationResponse recordObservation(UUID userId, CreateObservationRequest request, String clientIp) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        validateObservationRequest(request);

        // Normalize units and values
        UnitNormalizationService.NormalizedObservation norm = normalizationService.normalizeObservation(
                request.getType().name(),
                request.getValueNumeric(),
                request.getUnit()
        );

        HealthObservation observation = null;
        boolean isUpdate = false;

        // Source-scoped daily aggregation update for Google Health Connect steps
        if (request.getType() == ObservationType.STEPS && "Google Health Connect (Daily Aggregate)".equals(request.getSource())) {
            Instant ts = request.getTimestamp() != null ? request.getTimestamp() : Instant.now();
            LocalDate date = ts.atZone(ZoneOffset.UTC).toLocalDate();
            Instant dayStart = date.atStartOfDay(ZoneOffset.UTC).toInstant();
            Instant dayEnd = date.plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant();

            List<HealthObservation> existing = observationRepository.findSourceDailyObservations(
                    userId,
                    request.getType(),
                    request.getSource(),
                    dayStart,
                    dayEnd
            );

            if (!existing.isEmpty()) {
                observation = existing.get(0);
                isUpdate = true;
                // Coalesce any redundant historical rows for the same date/source
                if (existing.size() > 1) {
                    for (int i = 1; i < existing.size(); i++) {
                        observationRepository.delete(existing.get(i));
                    }
                }
            }
        }

        if (!isUpdate) {
            if (isVitalObservation(request.getType(), request.getVitalName())) {
                VitalMeasurement vital = new VitalMeasurement();
                vital.setVitalName(request.getVitalName() != null ? request.getVitalName() : request.getType().name());
                vital.setDeviceModel(request.getDeviceModel());
                observation = vital;
            } else if (isLifestyleObservation(request.getType(), request.getLifestyleCategory())) {
                LifestyleObservation lifestyle = new LifestyleObservation();
                lifestyle.setLifestyleCategory(request.getLifestyleCategory() != null ? request.getLifestyleCategory() : request.getType().name());
                lifestyle.setDurationMinutes(request.getDurationMinutes());
                observation = lifestyle;
            } else if (isSymptomObservation(request.getType(), request.getSymptomName())) {
                SymptomObservation symptom = new SymptomObservation();
                symptom.setSymptomName(request.getSymptomName() != null ? request.getSymptomName() : (request.getValueText() != null ? request.getValueText() : "Reported Symptom"));
                symptom.setSeverity(request.getSeverity());
                symptom.setBodySite(request.getBodySite());
                observation = symptom;
            } else {
                observation = new HealthObservation();
            }

            observation.setUser(user);
            observation.setObservationType(request.getType());
            observation.setSource(request.getSource());
        } else {
            if (observation instanceof LifestyleObservation lifestyle) {
                if (request.getLifestyleCategory() != null) {
                    lifestyle.setLifestyleCategory(request.getLifestyleCategory());
                }
                if (request.getDurationMinutes() != null) {
                    lifestyle.setDurationMinutes(request.getDurationMinutes());
                }
            }
        }

        observation.setValueNumeric(request.getValueNumeric());
        observation.setValueText(request.getValueText());
        observation.setUnit(request.getUnit());
        observation.setStandardValueNumeric(norm.normalizedValue());
        observation.setStandardUnit(norm.normalizedUnit());
        observation.setTimestamp(request.getTimestamp());
        observation.setConfidence(request.getConfidence() != null ? request.getConfidence() : BigDecimal.valueOf(1.0));
        observation.setMetadata(request.getMetadata());

        HealthObservation saved = observationRepository.save(observation);

        auditService.record(
                user,
                user.getEmail(),
                isUpdate ? "OBSERVATION_UPDATED" : "OBSERVATION_RECORDED",
                "HEALTH_OBSERVATION",
                saved.getId().toString(),
                clientIp,
                (isUpdate ? "Updated " : "Type: ") + saved.getObservationType() + ", Source: " + saved.getSource() + (isUpdate ? ", Value: " + saved.getValueNumeric() : "")
        );

        log.info("{} observation {} for user {}", isUpdate ? "Updated" : "Recorded", saved.getId(), userId);
        return mapToResponse(saved);
    }

    @Transactional(readOnly = true)
    public Page<ObservationResponse> getObservations(
            UUID userId,
            ObservationType type,
            Instant startDate,
            Instant endDate,
            Pageable pageable
    ) {
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User not found with id: " + userId);
        }
        return observationRepository.findFiltered(userId, type, startDate, endDate, pageable)
                .map(this::mapToResponse);
    }

    private void validateObservationRequest(CreateObservationRequest request) {
        boolean hasNumeric = request.getValueNumeric() != null;
        boolean hasText = request.getValueText() != null && !request.getValueText().trim().isEmpty();
        boolean hasSymptom = request.getSymptomName() != null && !request.getSymptomName().trim().isEmpty();
        boolean hasLifestyle = request.getLifestyleCategory() != null && !request.getLifestyleCategory().trim().isEmpty();

        if (!hasNumeric && !hasText && !hasSymptom && !hasLifestyle) {
            throw new ApiException("Either valueNumeric, valueText, symptomName, or lifestyleCategory must be provided for observation");
        }
    }

    private boolean isVitalObservation(ObservationType type, String vitalName) {
        if (vitalName != null && !vitalName.trim().isEmpty()) return true;
        return switch (type) {
            case HEART_RATE, BLOOD_PRESSURE_SYSTOLIC, BLOOD_PRESSURE_DIASTOLIC,
                 BODY_TEMPERATURE, OXYGEN_SATURATION, RESPIRATORY_RATE,
                 BLOOD_GLUCOSE, HRV -> true;
            default -> false;
        };
    }

    private boolean isLifestyleObservation(ObservationType type, String category) {
        if (category != null && !category.trim().isEmpty()) return true;
        return switch (type) {
            case SLEEP, EXERCISE, DIET, HYDRATION, MEDITATION, STEPS -> true;
            default -> false;
        };
    }

    private boolean isSymptomObservation(ObservationType type, String symptomName) {
        if (symptomName != null && !symptomName.trim().isEmpty()) return true;
        return type == ObservationType.SYMPTOM;
    }

    public ObservationResponse mapToResponse(HealthObservation obs) {
        ObservationResponse resp = new ObservationResponse();
        resp.setId(obs.getId());
        resp.setUserId(obs.getUser().getId());
        resp.setType(obs.getObservationType());
        resp.setValueNumeric(obs.getValueNumeric());
        resp.setValueText(obs.getValueText());
        resp.setUnit(obs.getUnit());
        resp.setStandardValueNumeric(obs.getStandardValueNumeric());
        resp.setStandardUnit(obs.getStandardUnit());
        resp.setTimestamp(obs.getTimestamp());
        resp.setSource(obs.getSource());
        resp.setConfidence(obs.getConfidence());
        resp.setMetadata(obs.getMetadata());
        resp.setCreatedAt(obs.getCreatedAt());

        if (obs instanceof VitalMeasurement vital) {
            resp.setObservationClass("VitalMeasurement");
            resp.setVitalName(vital.getVitalName());
            resp.setDeviceModel(vital.getDeviceModel());
        } else if (obs instanceof LifestyleObservation lifestyle) {
            resp.setObservationClass("LifestyleObservation");
            resp.setLifestyleCategory(lifestyle.getLifestyleCategory());
            resp.setDurationMinutes(lifestyle.getDurationMinutes());
        } else if (obs instanceof SymptomObservation symptom) {
            resp.setObservationClass("SymptomObservation");
            resp.setSymptomName(symptom.getSymptomName());
            resp.setSeverity(symptom.getSeverity());
            resp.setBodySite(symptom.getBodySite());
        } else {
            resp.setObservationClass("HealthObservation");
        }

        return resp;
    }
}
