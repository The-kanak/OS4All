# OS4All: Your Health, Understood Earlier

> **Preventive Health Intelligence Operating System**  
> Transparent personal baseline modeling, multi-signal anomaly & drift detection, NVIDIA Nemotron AI reasoning via Nebius AI Studio, Tavily biomedical literature grounding, and Google Health Connect integration.

---

> [!IMPORTANT]
> **Medical Disclaimer & Ethical Statement:**  
> OS4All is designed strictly for proactive health awareness, early physiological trend detection, and personal lifestyle tracking. **It is NOT a diagnostic tool, does NOT prescribe medications, and is NOT a replacement for qualified clinical care or emergency medical evaluation.**

---

## 1. Executive Overview & Problem Statement

### The Problem
Traditional clinical healthcare relies heavily on static population reference ranges. A metric is only flagged when an individual crosses arbitrary statistical extremes. However:
- *"Normal for the general population is not necessarily normal for the individual."*
- Subtle multi-day autonomic nervous system (ANS) shifts (such as nocturnal HRV suppression paired with elevated resting heart rate and disrupted slow-wave sleep) often precede overt physiological symptoms by days or weeks, yet pass unnoticed under one-size-fits-all population cutoffs.

### The Solution: OS4All
**OS4All** models an individual's personal physiological homeostatic baseline over time using longitudinal wearable data and uploaded diagnostic reports. When subtle multi-signal departures persist, OS4All detects autonomic strain, reasons over the variance using NVIDIA Nemotron (`nvidia/Llama-3_1-Nemotron-70B-Instruct`), grounds findings in peer-reviewed literature via Tavily Search, and generates clear, non-diagnostic lifestyle guidance and clinical evaluation talking points.

---

## 2. Key Implemented Features

1. **Personal Homeostatic Baseline Engine**
   - Continuously computes individual rolling statistics (mean, median, standard deviation, interquartile range, confidence envelopes) across vital metrics: Resting Heart Rate (RHR), Heart Rate Variability (HRV), Blood Oxygen (SpO2), Sleep Duration, and Body Temperature.
   - Respects a minimum observation threshold (7+ days) before establishing high-confidence personal envelopes.

2. **Transparent Multi-Signal Anomaly & Drift Engine**
   - Deterministic, rule-based cross-signal correlation engine (no opaque black box).
   - Classifies acute stress, cumulative autonomic fatigue, recovery deficits, and sustained multi-day baseline drift.

3. **Multi-Agent AI Intelligence Layer (Nebius AI Studio & NVIDIA Nemotron)**
   - 5-agent orchestrator: Context Extraction, Trend Analysis, Evidence Retrieval, Explanatory Synthesis, and Action Planning.
   - Enforces strict JSON Schema contracts with deterministic offline mock fallback when API keys are not present.

4. **Biomedical Evidence Grounding (Tavily Search API)**
   - Curates medical literature exclusively from reputable peer-reviewed sources (`pubmed.ncbi.nlm.nih.gov`, `nature.com`, `nejm.org`, `frontiersin.org`, `ahajournals.org`).
   - Strict relevance scoring threshold (minimum 0.65 relevance).

5. **Medical Report OCR & Biomarker Ingestion**
   - Multi-format report ingestion (PDF, PNG, JPG/JPEG) with Apache PDFBox text extraction and magic byte signature validation.
   - Human-in-the-loop verification UI before committing extracted lab markers to the personal record.

6. **Native Google Health Connect Integration**
   - Native Health Connect client on Android with runtime permission workflows and deduplication ledger to prevent double-counting wearable syncs.

7. **Tamper-Evident SHA-256 Audit Logging & Consent Management**
   - Cryptographically hash-chained audit ledger for all sensitive health queries, report uploads, and AI inferences.
   - Granular user privacy opt-ins (`DATA_STORAGE`, `AI_INFERENCE`, `EVIDENCE_SEARCH`).

8. **Conversational AI Health Counselor with Emergency Triage**
   - Audited health assistant that explains baseline trends.
   - Hardened emergency triage classifier: expressions of severe chest pressure, acute respiratory distress, or stroke symptoms trigger instant redirection to emergency services (911/112).

9. **One-Click Flagship Demonstration Scenario**
   - Reproducible 9-step end-to-end scenario demonstrating the entire data-to-insight pipeline with synthetic demo patient data.

---

## 3. Architecture & Tech Stack

```
 ┌────────────────────────────────────────────────────────┐
 │            Flutter Frontend (Cross-Platform)           │
 │  Android (Health Connect) • Web • iOS • Clean Material3│
 └──────────────────────────┬─────────────────────────────┘
                            │ REST API (JSON / Bearer JWT)
                            ▼
 ┌────────────────────────────────────────────────────────┐
 │           Spring Boot 3.3 Backend (Java 17)            │
 │                                                        │
 │ ┌───────────────────┐ ┌──────────────────────────────┐ │
 │ │  Security / Auth  │ │   Health Data & Ingestion    │ │
 │ │  (JJWT / BCrypt)  │ │   (Vitals, Symptoms, Labs)   │ │
 │ └───────────────────┘ └──────────────────────────────┘ │
 │ ┌───────────────────┐ ┌──────────────────────────────┐ │
 │ │ Baseline Engine   │ │ Directional Drift & Anomaly  │ │
 │ │ (Rolling Variance)│ │ (Rule-Based Multi-Signal)    │ │
 │ └───────────────────┘ └──────────────────────────────┘ │
 │ ┌───────────────────┐ ┌──────────────────────────────┐ │
 │ │ Report OCR Engine │ │ Tamper-Evident SHA-256 Audit │ │
 │ │ (PDFBox / Parser) │ │ & Consent Controller         │ │
 │ └───────────────────┘ └──────────────────────────────┘ │
 │ ┌──────────────────────────────────────────────────┐ │ │
 │ │         AI Intelligence Layer Orchestrator       │ │ │
 │ │  Provider Abstraction (Mock / Nebius Nemotron)   │ │ │
 │ │  Evidence Retrieval (Mock / Tavily Search API)   │ │ │
 │ └──────────────────────────────────────────────────┘ │ │
 └──────────────────────────┬─────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
    MySQL 8 / H2 Database        External AI & Search APIs
    (Flyway Migrations)          (Nebius AI Studio, Tavily)
```

- **Backend**: Java 17, Spring Boot 3.3.4, Spring Security, Spring Data JPA, Hibernate, MySQL 8 / H2, Flyway, JJWT, Apache PDFBox, SpringDoc OpenAPI.
- **Frontend**: Flutter 3.47+, Dart 3.13+, Google Fonts, Health package (Google Health Connect).
- **AI & Evidence**: Nebius AI Studio (`nvidia/Llama-3_1-Nemotron-70B-Instruct`), Tavily Search API.

---

## 4. Prerequisites

Before setting up OS4All on Windows:
- **Java Development Kit (JDK)**: JDK 17 or higher (e.g. Eclipse Adoptium Temurin 17+). Ensure `JAVA_HOME` is set.
- **Apache Maven**: Version 3.8+ (or use the provided Maven wrapper `mvnw.cmd`).
- **Flutter SDK**: Version 3.47+ (Dart 3.13+). Ensure `flutter` is available in your `PATH`.
- **MySQL Database**: MySQL 8.0+ (Optional for development; the backend can run with in-memory H2 for tests and evaluation).
- **Git**: Any modern version.

---

## 5. Step-by-Step Setup Instructions (Windows)

### Step 1: Clone Repository
```powershell
git clone https://github.com/The-kanak/OS4All.git
cd OS4All
```

### Step 2: Configure Environment Variables
Copy the template `.env.example` file to create your local `.env`:
```powershell
Copy-Item .env.example .env
```

Configure your local credentials in `.env` or set them in your PowerShell session:
```powershell
# Required only if using live MySQL (otherwise defaults to localhost:3306)
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_NAME="os4all"
$env:DB_USERNAME="root"
$env:DB_PASSWORD="your_mysql_password"

# Optional: Remote AI inference & live web evidence (defaults to 'mock' provider)
$env:OS4ALL_AI_PROVIDER="mock"        # Set to 'nebius' for live Nebius AI Studio
$env:NEBIUS_API_KEY="your_nebius_key"
$env:OS4ALL_EVIDENCE_PROVIDER="mock"  # Set to 'tavily' for live Tavily evidence
$env:TAVILY_API_KEY="your_tavily_key"
```

> [!TIP]
> The backend defaults to `mock` mode for both AI reasoning and Evidence search out of the box, allowing full offline execution without needing external API keys.

---

## 6. Database Setup & Migrations

If using MySQL:
1. Ensure MySQL service is running.
2. Create the database:
   ```sql
   CREATE DATABASE IF NOT EXISTS os4all;
   ```
3. Database migrations are managed via **Flyway** (`backend/src/main/resources/db/migration`):
   - `V1__init_auth_and_user_schema.sql`
   - `V2__health_data_engine_schema.sql`
   - `V3__report_ingestion_and_ocr_schema.sql`
   - `V4__ai_intelligence_schema.sql`
4. Set `$env:SPRING_FLYWAY_ENABLED="true"` if running Flyway migrations automatically on startup.

---

## 7. Build and Run Backend

```powershell
cd d:\OS4All\backend

# Run automated tests (86 passing tests)
mvn test

# Package and build JAR
mvn clean package -DskipTests=false

# Start Spring Boot application (configured to port 8085 by default)
java -jar target/os4all-backend-1.0.0-SNAPSHOT.jar
```

The Spring Boot backend will start:
- **Base API URL**: `http://localhost:8085/api/v1`
- **Interactive Swagger UI**: `http://localhost:8085/swagger-ui.html`
- **OpenAPI Schema**: `http://localhost:8085/v3/api-docs`
- **Actuator Health**: `http://localhost:8085/actuator/health`

---

## 8. Build and Run Frontend

```powershell
cd d:\OS4All\frontend

# Install Flutter dependencies
flutter pub get

# Run tests (15 unit & widget tests)
flutter test

# Run Flutter Web or Android
flutter run -d chrome
```

---

## 9. Key API Endpoints

| Area | Method | Endpoint | Description |
|---|---|---|---|
| **Auth** | `POST` | `/api/v1/auth/register` | Register new user account |
| **Auth** | `POST` | `/api/v1/auth/login` | Login and obtain JWT tokens |
| **User Profile** | `GET` / `PUT` | `/api/v1/users/profile` | Get or update biological profile |
| **Consent** | `GET` / `POST` | `/api/v1/consents` | Privacy opt-in and consent controls |
| **Vitals Ingestion** | `POST` | `/api/v1/health/observations` | Ingest vital sign observations |
| **Baseline** | `GET` | `/api/v1/baseline/summary` | Retrieve computed personal homeostatic baseline |
| **Anomalies** | `GET` | `/api/v1/anomalies/active` | Active detected multi-signal anomalies & drift |
| **Reports OCR** | `POST` | `/api/v1/reports/upload` | Upload PDF/image report for OCR parsing |
| **Reports Review** | `POST` | `/api/v1/reports/{id}/confirm` | Confirm extracted biomarker review items |
| **AI Intelligence** | `POST` | `/api/v1/ai/analyze` | Run 5-agent AI intelligence workflow |
| **AI Counselor** | `POST` | `/api/v1/counselor/chat` | Chat with audited health assistant |
| **Flagship Demo** | `POST` | `/api/v1/demo/run-flagship-scenario` | Execute 9-step end-to-end demonstration |
| **Actuator** | `GET` | `/actuator/health` | Service health status |

---

## 10. Privacy & Security Assurance

- **Zero-Trust Client Design**: API keys (`NEBIUS_API_KEY`, `TAVILY_API_KEY`), database credentials, and signing secrets are managed exclusively on the backend and are **never** exposed to client applications.
- **Strict Data Protection**: Real medical records, personal patient identifiers, and private test documents must **never** be committed to version control.
- **Repository Hygiene**: Real `.env` files, keystores, and build outputs are excluded by `.gitignore`.

---

## 11. Known Limitations

- **Medical OCR**: Tesseract/OCR engine uses Apache PDFBox and heuristic pattern extraction for laboratory report formats; unusual lab layouts may require manual confirmation.
- **Health Connect**: Native Google Health Connect requires Android API Level 28+ and device support for Google Health Connect.
- **AI Availability**: When `OS4ALL_AI_PROVIDER=nebius` is enabled, an active internet connection and valid Nebius API token are required. If disconnected or unconfigured, the system automatically falls back to offline mock mode.

---

## 12. License

Distributed under the Apache 2.0 License or MIT License. See `LICENSE` for details.
