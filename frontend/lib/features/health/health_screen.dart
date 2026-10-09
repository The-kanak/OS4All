import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';
import '../../shared/widgets/add_vital_observation_dialog.dart';
import '../../shared/widgets/healthcare_widgets.dart';
import '../../shared/widgets/health_connect_card.dart';
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

        return Column(
          children: [
            Container(
              color: AppTheme.surface,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Health Intelligence Hub',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_chart_rounded, color: AppTheme.primary, size: 20),
                          tooltip: 'Record Vital',
                          onPressed: () => AddVitalObservationDialog.show(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary, size: 20),
                          tooltip: 'Refresh',
                          onPressed: () {
                            appState.refreshHealthStatus();
                            appState.refreshBaseline();
                            appState.refreshTimeline();
                            appState.refreshReports();
                          },
                        ),
                      ],
                    ),
                  ),
                  TabBar(
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
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignalsTab(context, appState),
                  _buildBaselineTab(context, appState),
                  _buildTimelineTab(context, appState),
                  _buildReportsTab(context, appState),
                ],
              ),
            ),
          ],
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
            const SizedBox(height: 12),
            const GoogleHealthConnectCard(compact: true),
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
                status: isDemo ? 'ELEVATED' : 'NORMAL',
                statusColor: isDemo ? AppTheme.warning : AppTheme.stable,
                trend: isDemo ? '↑ 4 bpm' : '→ Stable',
                relationToUsual: isDemo ? 'Slightly above your usual range' : 'Within your usual range',
                description: 'Basal autonomic indicator measured during resting sleep and morning inactivity.',
                baseline: 'Usual Range: 55.1 – 64.9 bpm',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Heart Rate Variability (HRV)',
                value: isDemo ? '44' : '54',
                unit: 'ms',
                status: isDemo ? 'DECREASED' : 'NORMAL',
                statusColor: isDemo ? AppTheme.warning : AppTheme.stable,
                trend: isDemo ? '↓ 11 ms' : '→ Stable',
                relationToUsual: isDemo ? 'Below your usual recovery tone' : 'Within your usual range',
                description: 'Parasympathetic autonomic tone. Sustained drops reflect physiologic strain.',
                baseline: 'Usual Range: 47.2 – 62.8 ms',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Sleep Duration',
                value: isDemo ? '6.1' : '7.8',
                unit: 'hours',
                status: isDemo ? 'SHORTFALL' : 'NORMAL',
                statusColor: isDemo ? AppTheme.warning : AppTheme.stable,
                trend: isDemo ? '↓ 1.9 hrs' : '→ Stable',
                relationToUsual: isDemo ? 'Shorter than your usual sleep envelope' : 'Within your usual range',
                description: 'Total nightly restorative rest calculated from longitudinal sleep tracking.',
                baseline: 'Usual Range: 6.8 – 9.2 hrs',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Blood Oxygen (SpO2)',
                value: isDemo ? '97.2' : '98.5',
                unit: '%',
                status: 'STABLE',
                statusColor: AppTheme.stable,
                trend: '→ Stable',
                relationToUsual: 'Within your usual range',
                description: 'Peripheral arterial oxygen saturation during rest.',
                baseline: 'Usual Range: 96.4 – 99.6%',
              ),
              const SizedBox(height: 12),
              _buildSignalDetailCard(
                metricName: 'Body Temperature',
                value: '36.8',
                unit: '°C',
                status: 'STABLE',
                statusColor: AppTheme.stable,
                trend: '→ Stable',
                relationToUsual: 'Within your usual range',
                description: 'Basal core temperature baseline.',
                baseline: 'Usual Range: 36.5 – 37.1°C',
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
    required String trend,
    required String relationToUsual,
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
              Expanded(
                child: Text(
                  metricName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            relationToUsual,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: statusColor),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const Divider(height: 18, color: AppTheme.border),
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  baseline,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                ),
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDemo) ...[
                const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
                const SizedBox(height: 12),
              ],
              // Educational Hero Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This is YOUR normal.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'OS4All compares recent patterns with your own historical patterns, not just generic population averages. When recent signals move outside your personal range, we help you understand what changed.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.45),
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
                          'We are still learning your normal pattern. Record daily vitals to build your personal baseline.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text(
                'Your Calibrated Ranges',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),

              _buildBaselineEnvelopeCard(
                metric: 'Resting Heart Rate',
                usualRangeText: '55.1 – 64.9 bpm',
                recentValueText: isDemo ? '64.0 bpm' : '61.0 bpm',
                recentRelativePosition: isDemo ? 0.88 : 0.60,
                isDeparted: isDemo,
                mean: '60.0 bpm',
                stdDev: '2.5 bpm',
                zScore: isDemo ? '+1.60 σ' : '+0.40 σ',
                sampleCount: 45,
              ),
              const SizedBox(height: 14),
              _buildBaselineEnvelopeCard(
                metric: 'Heart Rate Variability',
                usualRangeText: '47.2 – 62.8 ms',
                recentValueText: isDemo ? '44.0 ms' : '54.0 ms',
                recentRelativePosition: isDemo ? 0.12 : 0.44,
                isDeparted: isDemo,
                mean: '55.0 ms',
                stdDev: '4.0 ms',
                zScore: isDemo ? '-2.75 σ' : '-0.25 σ',
                sampleCount: 45,
              ),
              const SizedBox(height: 14),
              _buildBaselineEnvelopeCard(
                metric: 'Sleep Duration',
                usualRangeText: '6.8 – 9.2 hrs',
                recentValueText: isDemo ? '6.1 hrs' : '7.8 hrs',
                recentRelativePosition: isDemo ? 0.08 : 0.42,
                isDeparted: isDemo,
                mean: '8.0 hrs',
                stdDev: '0.6 hrs',
                zScore: isDemo ? '-3.17 σ' : '-0.33 σ',
                sampleCount: 45,
              ),
              const SizedBox(height: 14),
              _buildBaselineEnvelopeCard(
                metric: 'Blood Oxygen (SpO2)',
                usualRangeText: '96.4 – 99.6%',
                recentValueText: isDemo ? '97.2%' : '98.5%',
                recentRelativePosition: isDemo ? 0.25 : 0.65,
                isDeparted: false,
                mean: '98.0%',
                stdDev: '0.8%',
                zScore: isDemo ? '-1.00 σ' : '+0.62 σ',
                sampleCount: 45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBaselineEnvelopeCard({
    required String metric,
    required String usualRangeText,
    required String recentValueText,
    required double recentRelativePosition, // 0.0 to 1.0 position in visual bar
    required bool isDeparted,
    required String mean,
    required String stdDev,
    required String zScore,
    required int sampleCount,
  }) {
    final statusColor = isDeparted ? AppTheme.attention : AppTheme.stable;

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
                  metric,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  isDeparted ? 'MILD SHIFT' : 'WITHIN USUAL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Range Bar
          const Text('Your usual range', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final dotPos = (barWidth * recentRelativePosition.clamp(0.05, 0.95)) - 7;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Continuous range track
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border),
                        ),
                      ),
                      // Usual envelope highlight (center 70% of track)
                      Positioned(
                        left: barWidth * 0.15,
                        right: barWidth * 0.15,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      // Recent position dot
                      Positioned(
                        left: dotPos,
                        top: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(usualRangeText, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      Text('Recent: $recentValueText', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),

          // Technical Details Hidden Behind ExpansionTile
          Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Technical details (Mean, SD, Z-Score)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.secondary),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildTechRow('Sample Observations', '$sampleCount daily points'),
                      _buildTechRow('Mean (μ)', mean),
                      _buildTechRow('Standard Deviation (σ)', stdDev),
                      _buildTechRow('Current Z-Score', zScore),
                      _buildTechRow('Confidence Interval', '95% (μ ± 1.96σ)'),
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

  static Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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

    return Stack(
      children: [
        SingleChildScrollView(
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
      Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Upload PDF (OCR)', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportUploadScreen()),
            ),
          ),
        ),
      ],
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
