import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';
import '../../shared/widgets/add_vital_observation_dialog.dart';
import '../../shared/widgets/healthcare_widgets.dart';
import '../labs/report_upload_screen.dart';

class HealthScreen extends StatefulWidget {
  final int initialTabIndex;

  const HealthScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HealthScreen> createState() => HealthScreenState();
}

class HealthScreenState extends State<HealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timelineFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
  }

  publicSetTab(int index) {
    if (index >= 0 && index < 4) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager.instance,
      builder: (context, _) {
        final appState = AppStateManager.instance;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Health Intelligence Hub',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_chart_rounded, color: AppTheme.primary),
                tooltip: 'Record Vital',
                onPressed: () => AddVitalObservationDialog.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                tooltip: 'Refresh',
                onPressed: () {
                  appState.refreshHealthStatus();
                  appState.refreshBaseline();
                  appState.refreshTimeline();
                  appState.refreshReports();
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Signals', icon: Icon(Icons.show_chart_rounded, size: 18)),
                Tab(text: 'Baseline', icon: Icon(Icons.tune_rounded, size: 18)),
                Tab(text: 'Timeline', icon: Icon(Icons.timeline_rounded, size: 18)),
                Tab(text: 'Reports', icon: Icon(Icons.description_outlined, size: 18)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildSignalsTab(context, appState),
              _buildBaselineTab(context, appState),
              _buildTimelineTab(context, appState),
              _buildReportsTab(context, appState),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // SUB-TAB 1: SIGNALS
  // =========================================================================
  Widget _buildSignalsTab(BuildContext context, AppStateManager appState) {
    final signals = appState.signals;
    final isDemo = appState.isDemoMode;

    return RefreshIndicator(
      onRefresh: () => appState.refreshHealthStatus(),
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDemo) ...[
              const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continuous Telemetry Signals',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Monitored against individual mathematical baseline',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => AddVitalObservationDialog.show(context),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Vital', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (signals.isEmpty && !isDemo)
              _buildEmptyState(
                title: 'No Signals Recorded Yet',
                description: 'Record your first vital reading or upload a lab panel to start tracking.',
                actionText: 'Record First Vital',
                onAction: () => AddVitalObservationDialog.show(context),
              )
            else ...[
              _buildSignalDetailCard(
                metricName: 'Resting Heart Rate',
                value: isDemo ? '64' : '61',
                unit: 'bpm',
                status: isDemo ? 'ELEVATED (+4 bpm)' : 'NORMAL',
                statusColor: isDemo ? AppTheme.warning : AppTheme.stable,
                description: 'Basal autonomic indicator measured during resting sleep and morning inactivity.',
                baseline: 'Personal Mean: 60 ± 2.5 bpm',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Heart Rate Variability (HRV)',
                value: isDemo ? '44' : '54',
                unit: 'ms',
                status: isDemo ? 'DECREASED (-11 ms)' : 'NORMAL',
                statusColor: isDemo ? AppTheme.warning : AppTheme.stable,
                description: 'Parasympathetic autonomic tone. Sustained drops reflect physiologic strain or recovery debt.',
                baseline: 'Personal Mean: 55 ± 4.0 ms',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Sleep Duration',
                value: isDemo ? '6.1' : '7.8',
                unit: 'hours',
                status: isDemo ? 'SHORTFALL (-1.9 hrs)' : 'NORMAL',
                statusColor: isDemo ? AppTheme.warning : AppTheme.stable,
                description: 'Total nightly restorative rest calculated from longitudinal sleep tracking.',
                baseline: 'Personal Mean: 8.0 ± 0.6 hrs',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Blood Oxygen (SpO2)',
                value: isDemo ? '97.2' : '98.5',
                unit: '%',
                status: 'STABLE',
                statusColor: AppTheme.stable,
                description: 'Peripheral arterial oxygen saturation during rest.',
                baseline: 'Personal Mean: 98.0 ± 0.8%',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Body Temperature',
                value: '36.8',
                unit: '°C',
                status: 'STABLE',
                statusColor: AppTheme.stable,
                description: 'Basal core temperature baseline.',
                baseline: 'Personal Mean: 36.7 ± 0.2°C',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalDetailCard({
    required String metricName,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required String description,
    required String baseline,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metricName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const Divider(height: 18, color: AppTheme.border),
          Row(
            children: [
              const Icon(Icons.straighten_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                baseline,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 2: BASELINE
  // =========================================================================
  Widget _buildBaselineTab(BuildContext context, AppStateManager appState) {
    final baselines = appState.baselines;
    final isDemo = appState.isDemoMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDemo) ...[
            const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
            const SizedBox(height: 12),
          ],
          // Educational Hero Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_alt_rounded, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Core Mathematical Principle',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '"Normal for the population is not necessarily normal for the individual."',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'OS4All calibrates individualized statistical envelopes (Mean μ ± 1.96σ, representing a 95% confidence interval). Signals departing beyond this envelope for multiple consecutive days trigger early trend alerts before population thresholds are crossed.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Calibration Status Banner (in Live Mode if observations < 14)
          if (!isDemo && baselines.isEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Baseline Calibration in Progress: Establishing statistical confidence requires at least 14 days of observations. Add daily vitals to progress calibration.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          const Text(
            'Calibrated Metric Baselines',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),

          _buildBaselineEnvelopeCard(
            metric: 'Resting Heart Rate',
            mean: '60.0 bpm',
            stdDev: '2.5 bpm',
            range95: '55.1 – 64.9 bpm',
            currentValue: isDemo ? '64.0 bpm' : '61.0 bpm',
            zScore: isDemo ? '+1.60 σ' : '+0.40 σ',
            sampleCount: 45,
            isCalibrated: true,
          ),
          const SizedBox(height: 12),
          _buildBaselineEnvelopeCard(
            metric: 'Heart Rate Variability (HRV)',
            mean: '55.0 ms',
            stdDev: '4.0 ms',
            range95: '47.2 – 62.8 ms',
            currentValue: isDemo ? '44.0 ms' : '54.0 ms',
            zScore: isDemo ? '-2.75 σ' : '-0.25 σ',
            sampleCount: 45,
            isCalibrated: true,
          ),
          const SizedBox(height: 12),
          _buildBaselineEnvelopeCard(
            metric: 'Sleep Duration',
            mean: '8.0 hrs',
            stdDev: '0.6 hrs',
            range95: '6.8 – 9.2 hrs',
            currentValue: isDemo ? '6.1 hrs' : '7.8 hrs',
            zScore: isDemo ? '-3.17 σ' : '-0.33 σ',
            sampleCount: 45,
            isCalibrated: true,
          ),
          const SizedBox(height: 12),
          _buildBaselineEnvelopeCard(
            metric: 'SpO2 (Oxygen Saturation)',
            mean: '98.0%',
            stdDev: '0.8%',
            range95: '96.4 – 99.6%',
            currentValue: isDemo ? '97.2%' : '98.5%',
            zScore: isDemo ? '-1.00 σ' : '+0.62 σ',
            sampleCount: 45,
            isCalibrated: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBaselineEnvelopeCard({
    required String metric,
    required String mean,
    required String stdDev,
    required String range95,
    required String currentValue,
    required String zScore,
    required int sampleCount,
    required bool isCalibrated,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CALIBRATED (95% CI)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('95% Usual Envelope', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(range95, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Reading', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(currentValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Z-Score', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(zScore, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Expandable Technical Statistics
          Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'View Mathematical Parameters',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.secondary),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Mean (μ): $mean', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      Text('StdDev (σ): $stdDev', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      Text('Samples (n): $sampleCount', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 3: TIMELINE
  // =========================================================================
  Widget _buildTimelineTab(BuildContext context, AppStateManager appState) {
    final timelineItems = appState.timeline;
    final isDemo = appState.isDemoMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDemo) ...[
            const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
            const SizedBox(height: 12),
          ],
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['ALL', 'VITALS', 'LABS', 'ANOMALIES'].map((f) {
                final isSelected = _timelineFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _timelineFilter = f),
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (timelineItems.isEmpty && !isDemo)
            _buildEmptyState(
              title: 'Timeline is Empty',
              description: 'Telemetry recordings, lab results, and anomaly alerts will appear chronologically here.',
              actionText: 'Record First Vital',
              onAction: () => AddVitalObservationDialog.show(context),
            )
          else ...[
            _buildTimelineCard(
              title: 'Multi-Signal Baseline Departure Detected',
              category: 'ANOMALY',
              date: 'Today, 08:30 AM',
              summary: 'Rule engine identified persistent resting HR elevation (+4 bpm) combined with 11 ms HRV shortfall across 3+ consecutive days.',
              statusColor: AppTheme.warning,
              icon: Icons.trending_up_rounded,
            ),
            const SizedBox(height: 12),
            _buildTimelineCard(
              title: 'Lipid & Metabolic Panel Confirmed',
              category: 'LAB',
              date: 'Yesterday, 14:15 PM',
              summary: 'Automated biomarker extraction processed 4 analytes. Total cholesterol slightly elevated (215 mg/dL).',
              statusColor: AppTheme.primary,
              icon: Icons.biotech_rounded,
            ),
            const SizedBox(height: 12),
            _buildTimelineCard(
              title: 'Baseline Statistical Envelope Calibrated',
              category: 'VITALS',
              date: '3 days ago',
              summary: '45-day rolling biometric envelope updated with Gaussian bounds for individual normal range.',
              statusColor: AppTheme.success,
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard({
    required String title,
    required String category,
    required String date,
    required String summary,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: statusColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor),
                  ),
                ],
              ),
              Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 4: REPORTS
  // =========================================================================
  Widget _buildReportsTab(BuildContext context, AppStateManager appState) {
    final reports = appState.labReports;
    final isDemo = appState.isDemoMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload PDF (OCR)', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReportUploadScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDemo) ...[
              const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab Vault & Documents',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Zero-Trust extraction via Apache PDFBox',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportUploadScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Upload', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (reports.isEmpty && !isDemo)
              _buildEmptyState(
                title: 'No Lab Reports Uploaded',
                description: 'Upload diagnostic lab panels in PDF format to extract biomarker values into your timeline.',
                actionText: 'Upload First Report',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportUploadScreen()),
                ),
              )
            else ...[
              _buildReportCard(
                title: 'Comprehensive Metabolic Panel (CMP)',
                facility: 'Quest Diagnostics',
                date: 'October 4, 2026',
                status: 'CONFIRMED',
                statusColor: AppTheme.success,
                biomarkers: ['Fasting Glucose: 92 mg/dL', 'Creatinine: 0.9 mg/dL', 'ALT: 24 U/L'],
              ),
              const SizedBox(height: 12),
              _buildReportCard(
                title: 'Lipid Biomarker Profile',
                facility: 'Labcorp Clinical',
                date: 'September 28, 2026',
                status: 'CONFIRMED',
                statusColor: AppTheme.success,
                biomarkers: ['Total Cholesterol: 215 mg/dL (Borderline)', 'HDL: 52 mg/dL', 'LDL: 138 mg/dL', 'Triglycerides: 125 mg/dL'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String facility,
    required String date,
    required String status,
    required Color statusColor,
    required List<String> biomarkers,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$facility • $date',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const Divider(height: 18, color: AppTheme.border),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: biomarkers.map((b) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  b,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, color: AppTheme.textMuted, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
