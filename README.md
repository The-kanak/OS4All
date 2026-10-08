# OS4All: Your Health, Understood Earlier.

> **Hackathon Prototype** | Transparent Personal Baseline Engine, Rule-Based Multi-Signal Anomaly Detection, NVIDIA Nemotron AI Reasoning via Nebius AI Studio, and Tavily Evidence Retrieval.

---

## 1. Executive Overview

**OS4All** is built on a foundational healthcare insight:
> *"Normal for the general population is not necessarily normal for the individual."*

Traditional clinical thresholds flag anomalies only when individuals cross rigid population extremes. OS4All models an individual's personal physiological homeostatic baseline over time (Resting Heart Rate, nocturnal HRV, Sleep Duration, SpO2, and Body Temperature). When subtle multi-signal departures persist, OS4All detects autonomic strain, reasons over the variance using NVIDIA Nemotron-4-340B-Instruct, retrieves peer-reviewed literature via Tavily, and presents actionable lifestyle guidance and clinical evaluation criteria—**without ever diagnosing diseases or hallucinating medical facts**.

---

## 2. Core Value Proposition & Architecture

```
 DATA (Wearables & Lab OCR)
       │
       ▼
 PERSONAL BASELINE ENGINE (Rolling variance, z-score, confidence envelopes)
       │
       ▼
 DIRECTIONAL DRIFT & ANOMALY ENGINE (Transparent multi-signal correlation)
       │
       ▼
 AI INTELLIGENCE LAYER (Health Context, Trend, Evidence, Explanation, Action)
       │
       ├──► Nebius AI Studio (NVIDIA Nemotron-4-340B-Instruct)
       └──► Tavily Evidence Engine (Constrained medical literature retrieval)
       │
       ▼
 OS4All INSIGHT & AI COUNSELOR (Structured non-diagnostic explanation & actions)
       │
       ▼
 AUDIT LOG & UNIFIED TIMELINE (Cryptographically hashed immutable record)
```

---

## 3. Technology Stack

- **Backend**: Java 17, Spring Boot 3.3.4, Spring Security, Spring Data JPA, Hibernate, MySQL 8+ / H2, Jackson.
- **AI Orchestration**: Provider abstraction (`ModelProvider`), Nebius AI Studio, NVIDIA Nemotron-4-340B-Instruct, MockModelProvider (100% offline fallback).
- **Evidence Retrieval**: Tavily Search API (`EvidenceService`), PubMed / Nature / Frontiers domain constraints, MockEvidenceService fallback.
- **Frontend**: Flutter 3.47.2, Dart 3.13.2, Material 3, Dark Navy & Cyan/Indigo design system.
- **Security & Privacy**: Stateless JWT tokens, role-based access control, SHA-256 tamper-evident audit hashing, strict consent management (`DATA_STORAGE`, `AI_INFERENCE`, `EVIDENCE_SEARCH`), zero secret exposure to client.

---

## 4. Key Repositories & Modules

| Module | Description |
|---|---|
| `org.os4all.modules.baseline` | Computes statistical personal baselines (mean, median, standard deviation, individual range). |
| `org.os4all.modules.anomaly` | Transparent rule-based anomaly & multi-signal correlation engine (no opaque black box). |
| `org.os4all.modules.ocr` | Secure report upload & ingestion with magic byte validation and confidence review flags. |
| `org.os4all.modules.ai` | 5-agent AI orchestrator with Nebius / NVIDIA Nemotron integration and strict JSON schemas. |
| `org.os4all.modules.evidence` | Tavily evidence retrieval module with relevance scoring and domain filtering. |
| `org.os4all.modules.counselor` | Audited conversational health counselor with clinical emergency triage classifier. |
| `org.os4all.modules.demo` | Flagship reproducible end-to-end 9-step demonstration scenario. |

---

## 5. Quick Start & Setup

### Prerequisites
- JDK 17+
- Apache Maven 3.8+
- Flutter SDK 3.47+ (with Dart 3.13+)

### 1. Clone & Configure
```bash
git clone https://github.com/OS4All/os4all.git
cd OS4All
cp .env.example .env
```

### 2. Run Backend Tests & Package
```bash
cd backend
mvn clean package
```
*Expected output: 64/64 tests passing, build success.*

### 3. Start Backend Application
```bash
java -jar target/os4all-backend-1.0.0-SNAPSHOT.jar
```
*The Spring Boot server starts at `http://localhost:8080`.*
- Swagger UI / OpenAPI: `http://localhost:8080/swagger-ui/index.html`
- Health check: `http://localhost:8080/actuator/health`

### 4. Run Flutter Frontend
```bash
cd ../frontend
flutter pub get
flutter run -d chrome # or run on connected mobile device / emulator
```

---

## 6. Flagship Hackathon Demonstration

For live evaluation, OS4All includes a dedicated **One-Click End-to-End Flagship Scenario**:
1. Open the Flutter app or trigger via API: `POST /api/v1/demo/run-flagship-scenario`.
2. In the Flutter App, tap **`DEMO CHAIN`** on the top AppBar.
3. Experience the complete 9-step chain:
   **DATA $\to$ BASELINE $\to$ DRIFT $\to$ MULTI-SIGNAL PATTERN $\to$ NEMOTRON REASONING $\to$ TAVILY EVIDENCE $\to$ OS4All INSIGHT $\to$ ACTION $\to$ TIMELINE UPDATE**.
4. Use the **Autoplay** toggle for hands-free presentations.

---

## 7. Compliance & Safety Statement

- **Ethical AI**: OS4All AI never provides medical diagnoses, invents history, or prescribes treatment.
- **Safety Classifier**: Emergency expressions (e.g. severe chest pain, shortness of breath) trigger immediate triage to emergency services (911/112).
- **Synthetic Data**: All demonstration data is clearly marked as **`DEMO DATA NOTICE`**.
