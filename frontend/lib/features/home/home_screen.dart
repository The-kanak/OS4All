import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';
import '../../shared/widgets/add_vital_observation_dialog.dart';
import '../../shared/widgets/baseline_signal_chart.dart';
import '../../shared/widgets/healthcare_widgets.dart';
import '../labs/report_upload_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int tabIndex, {int? subIndex})? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager.instance,
      builder: (context, _) {
        final appState = AppStateManager.instance;
        final profile = appState.userProfile;
        final displayName = profile?.fullName ?? (appState.isDemoMode ? 'Dr. Alex Taylor' : 'Patient');
        final status = appState.healthStatus;
        final isDemo = appState.isDemoMode;

        return RefreshIndicator(
          onRefresh: () => appState.refreshAll(),
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Freshness
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $displayName',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDemo ? AppTheme.warning : AppTheme.success,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isDemo ? 'Demo Mode • Synthetic Telemetry' : 'Live Mode • Connected to BodyOS Engine',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDemo ? AppTheme.warning : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
                      tooltip: 'Refresh Telemetry',
                      onPressed: () => appState.refreshAll(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Notice banner in Demo Mode
                if (isDemo) ...[
                  const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
                  const SizedBox(height: 12),
                ],

                // Main Health Status Card
                _buildMainStatusCard(context, appState, status),
                const SizedBox(height: 16),

                // Quick Action Strip
                _buildQuickActionStrip(context, appState),
                const SizedBox(height: 20),

                // "What Changed?" Summary Card
                _buildWhatChangedCard(context, appState),
                const SizedBox(height: 20),

                // Today's Biometric Signals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monitored Signals',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateToTab?.call(1, subIndex: 0),
                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSignalsGrid(context, appState),
                const SizedBox(height: 20),

                // Baseline Signal Visual Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Baseline Trajectory (Resting HR)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => onNavigateToTab?.call(1, subIndex: 1),
                      child: const Text('Baseline Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BaselineSignalChart(
                  metricName: 'Resting Heart Rate',
                  unit: 'bpm',
                  values: isDemo
                      ? const [59.0, 60.5, 60.0, 61.2, 63.8, 64.5, 64.0]
                      : const [60.0, 60.5, 60.0, 60.2, 60.8, 61.0, 61.0],
                  labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  baselineMean: 60.0,
                  baselineLow: 55.1,
                  baselineHigh: 64.9,
                  state: isDemo ? 'DRIFT' : 'STABLE',
                ),
                const SizedBox(height: 20),

                // Non-diagnostic Medical Disclaimer Footer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.textSecondary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'OS4All is an objective health pattern intelligence platform designed for personal tracking. It is not an emergency response service and does not provide clinical diagnoses.',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStatusCard(BuildContext context, AppStateManager appState, HealthStatusSummaryModel? status) {
    if (status == null && !appState.isDemoMode) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to OS4All',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Establishing Baseline Calibration',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'No biometric telemetry recorded yet. Add vital observations or upload a medical PDF report to begin computing your individual statistical baseline.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => AddVitalObservationDialog.show(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Record Vital'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportUploadScreen())),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final stateStr = status?.state ?? (appState.isDemoMode ? 'DRIFT' : 'STABLE');
    Color statusColor;
    String statusTitle;
    String statusExplanation;
    IconData statusIcon;

    switch (stateStr.toUpperCase()) {
      case 'DRIFT':
        statusColor = AppTheme.warning;
        statusTitle = 'Early Signal Drift Detected';
        statusExplanation = status?.summary ?? 'Subtle multi-day departures detected in your autonomic baselines (Resting HR elevated +4 bpm, HRV down 11 ms).';
        statusIcon = Icons.trending_up_rounded;
        break;
      case 'ANOMALY':
        statusColor = AppTheme.critical;
        statusTitle = 'Biometric Departure Needs Attention';
        statusExplanation = status?.summary ?? 'Persistent departure beyond your 95% baseline envelope across 3+ consecutive days.';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'FOLLOW_UP':
        statusColor = AppTheme.primary;
        statusTitle = 'Follow-Up Recommended';
        statusExplanation = status?.summary ?? 'Lab biomarkers and biometric trends suggest discussing findings with your healthcare provider.';
        statusIcon = Icons.calendar_month_rounded;
        break;
      case 'STABLE':
      default:
        statusColor = AppTheme.stable;
        statusTitle = 'All Signals Within Usual Range';
        statusExplanation = status?.summary ?? 'Your monitored vitals align closely with your 45-day personal baseline envelope.';
        statusIcon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      stateStr.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Personal Baseline Model',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statusTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            statusExplanation,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => onNavigateToTab?.call(2), // Navigate to Insights
                icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                label: const Text('View AI Synthesis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => onNavigateToTab?.call(3), // Navigate to Care / Counselor
                icon: const Icon(Icons.support_agent_rounded, size: 15),
                label: const Text('Ask Counselor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionStrip(BuildContext context, AppStateManager appState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.add_chart_rounded,
            label: 'Record Vital',
            color: AppTheme.primary,
            onTap: () => AddVitalObservationDialog.show(context),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.upload_file_rounded,
            label: 'Upload Lab PDF',
            color: AppTheme.secondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportUploadScreen()),
            ),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.question_answer_rounded,
            label: 'Ask Counselor',
            color: const Color(0xFF6366F1),
            onTap: () => onNavigateToTab?.call(3),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.timeline_rounded,
            label: 'Health Timeline',
            color: const Color(0xFF0D9488),
            onTap: () => onNavigateToTab?.call(1, subIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatChangedCard(BuildContext context, AppStateManager appState) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'What Changed? (vs Baseline)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Past 5 Days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricDelta(
                  metric: 'Resting HR',
                  recentValue: appState.isDemoMode ? '64 bpm' : '61 bpm',
                  baselineValue: '60 bpm',
                  delta: appState.isDemoMode ? '+4 bpm' : '+1 bpm',
                  isWorsening: appState.isDemoMode,
                ),
              ),
              Container(height: 40, width: 1, color: AppTheme.border),
              Expanded(
                child: _buildMetricDelta(
                  metric: 'HRV',
                  recentValue: appState.isDemoMode ? '44 ms' : '54 ms',
                  baselineValue: '55 ms',
                  delta: appState.isDemoMode ? '-11 ms' : '-1 ms',
                  isWorsening: appState.isDemoMode,
                ),
              ),
              Container(height: 40, width: 1, color: AppTheme.border),
              Expanded(
                child: _buildMetricDelta(
                  metric: 'Sleep',
                  recentValue: appState.isDemoMode ? '6.1 hrs' : '7.8 hrs',
                  baselineValue: '8.0 hrs',
                  delta: appState.isDemoMode ? '-1.9 hrs' : '-0.2 hrs',
                  isWorsening: appState.isDemoMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDelta({
    required String metric,
    required String recentValue,
    required String baselineValue,
    required String delta,
    required bool isWorsening,
  }) {
    final deltaColor = isWorsening ? AppTheme.critical : AppTheme.stable;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 3,
            children: [
              Text(recentValue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text(
                delta,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: deltaColor),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Base: $baselineValue', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSignalsGrid(BuildContext context, AppStateManager appState) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildSignalCard(
          title: 'Resting HR',
          value: appState.isDemoMode ? '64' : '61',
          unit: 'bpm',
          badge: appState.isDemoMode ? 'DRIFT' : 'NORMAL',
          badgeColor: appState.isDemoMode ? AppTheme.warning : AppTheme.stable,
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFEF4444),
        ),
        _buildSignalCard(
          title: 'HRV',
          value: appState.isDemoMode ? '44' : '54',
          unit: 'ms',
          badge: appState.isDemoMode ? 'LOW' : 'NORMAL',
          badgeColor: appState.isDemoMode ? AppTheme.warning : AppTheme.stable,
          icon: Icons.show_chart_rounded,
          iconColor: AppTheme.primary,
        ),
        _buildSignalCard(
          title: 'Sleep Duration',
          value: appState.isDemoMode ? '6.1' : '7.8',
          unit: 'hrs',
          badge: appState.isDemoMode ? 'REDUCED' : 'NORMAL',
          badgeColor: appState.isDemoMode ? AppTheme.warning : AppTheme.stable,
          icon: Icons.nightlight_round,
          iconColor: const Color(0xFF6366F1),
        ),
        _buildSignalCard(
          title: 'Blood Oxygen (SpO2)',
          value: appState.isDemoMode ? '97.2' : '98.5',
          unit: '%',
          badge: 'NORMAL',
          badgeColor: AppTheme.stable,
          icon: Icons.air_rounded,
          iconColor: const Color(0xFF0EA5E9),
        ),
      ],
    );
  }

  Widget _buildSignalCard({
    required String title,
    required String value,
    required String unit,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}
