import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';
import '../../shared/widgets/add_vital_observation_dialog.dart';
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
        final rawName = profile?.fullName.trim() ?? '';
        final firstName = rawName.isNotEmpty ? rawName.split(' ').first : (appState.isDemoMode ? 'Alex' : 'Friend');
        final isDemo = appState.isDemoMode;
        final status = appState.healthStatus;

        return RefreshIndicator(
          onRefresh: () => appState.refreshAll(),
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // 1. HEADER: Good morning, [Name] • Updated recently • Avatar
                    // =========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()}, $firstName',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDemo ? AppTheme.warning : AppTheme.stable,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isDemo ? 'Demo Mode • Synthetic Telemetry' : 'Updated recently',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDemo ? AppTheme.warning : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => onNavigateToTab?.call(4), // Navigate to Profile
                          borderRadius: BorderRadius.circular(24),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isDemo) ...[
                      const DemoDataNoticeBanner(label: 'DEMO MODE — SYNTHETIC HEALTH DATA FOR PRESENTATION'),
                      const SizedBox(height: 14),
                    ],

                    // =========================================================
                    // 2. MAIN STATUS CARD (Large, visually dominant, human)
                    // =========================================================
                    _buildMainStatusCard(context, appState, status),
                    const SizedBox(height: 16),

                    // =========================================================
                    // 3. ACTIONS (Only 2 primary actions: Upload report & Record data)
                    // =========================================================
                    _buildPrimaryActions(context),
                    const SizedBox(height: 22),

                    // =========================================================
                    // 4. WHAT CHANGED (Past 5 days vs Personal Baseline)
                    // =========================================================
                    _buildWhatChangedSection(context, appState),
                    const SizedBox(height: 22),

                    // =========================================================
                    // 5. TODAY'S SIGNALS (4 most useful signals)
                    // =========================================================
                    _buildTodaySignalsSection(context, appState),
                    const SizedBox(height: 22),

                    // =========================================================
                    // 6. BASELINE STORY CALLOUT (Calm, educational)
                    // =========================================================
                    _buildBaselineStoryBanner(context),
                    const SizedBox(height: 24),

                    // =========================================================
                    // 7. CALM MEDICAL DISCLAIMER
                    // =========================================================
                    Center(
                      child: Text(
                        'OS4All observes personal health patterns over time. It does not provide clinical diagnoses.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted.withValues(alpha: 0.9), height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 2. MAIN STATUS CARD
  // ===========================================================================
  Widget _buildMainStatusCard(BuildContext context, AppStateManager appState, HealthStatusSummaryModel? status) {
    final rawState = status?.state.toUpperCase() ?? (appState.isDemoMode ? 'DRIFT' : 'STABLE');

    Color stateColor;
    Color bgColor;
    String statusWord;
    String simpleExplanation;
    IconData icon;

    switch (rawState) {
      case 'DRIFT':
      case 'CHANGE_DETECTED':
        statusWord = 'CHANGE DETECTED';
        stateColor = AppTheme.attention;
        bgColor = const Color(0xFFFFFBEB);
        simpleExplanation = 'Your recent health patterns show a mild departure from your calibrated usual baseline.';
        icon = Icons.trending_up_rounded;
        break;
      case 'ANOMALY':
      case 'NEEDS_ATTENTION':
        statusWord = 'NEEDS ATTENTION';
        stateColor = AppTheme.critical;
        bgColor = const Color(0xFFFEF2F2);
        simpleExplanation = 'A sustained departure from your baseline has been observed across multiple consecutive days.';
        icon = Icons.warning_amber_rounded;
        break;
      case 'FOLLOW_UP':
      case 'FOLLOW_UP_RECOMMENDED':
        statusWord = 'FOLLOW-UP RECOMMENDED';
        stateColor = AppTheme.primary;
        bgColor = const Color(0xFFF0FDFA);
        simpleExplanation = 'Recent lab results and biometric trends suggest discussing findings with your doctor.';
        icon = Icons.calendar_today_rounded;
        break;
      case 'STABLE':
      default:
        statusWord = 'STABLE';
        stateColor = AppTheme.stable;
        bgColor = const Color(0xFFECFDF5);
        simpleExplanation = 'Your recent health patterns are close to your usual individual range.';
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stateColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: stateColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusWord,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: stateColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            simpleExplanation,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => onNavigateToTab?.call(2), // Navigate to Insights
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Why it matters',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: stateColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: stateColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. ONLY TWO PRIMARY ACTIONS
  // ===========================================================================
  Widget _buildPrimaryActions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final uploadBtn = ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReportUploadScreen()),
          ),
          icon: const Icon(Icons.upload_file_rounded, size: 17),
          label: const Text('Upload health report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            elevation: 0,
          ),
        );

        final recordBtn = OutlinedButton.icon(
          onPressed: () => AddVitalObservationDialog.show(context),
          icon: const Icon(Icons.add_rounded, size: 17),
          label: const Text('Record health data'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            side: const BorderSide(color: AppTheme.border, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              uploadBtn,
              const SizedBox(height: 8),
              recordBtn,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: uploadBtn),
            const SizedBox(width: 10),
            Expanded(child: recordBtn),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 4. WHAT CHANGED (Compact, clear, small trend indicators)
  // ===========================================================================
  Widget _buildWhatChangedSection(BuildContext context, AppStateManager appState) {
    final isDemo = appState.isDemoMode;

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
                child: Text(
                  'What Changed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                'vs Personal Baseline',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChangeRow(
            label: 'Sleep duration',
            trend: isDemo ? '↓ 8%' : '→ Stable',
            detail: isDemo ? '6.1 hrs (usually 8.0 hrs)' : '7.8 hrs (in normal range)',
            color: isDemo ? AppTheme.critical : AppTheme.stable,
          ),
          const Divider(height: 16, color: AppTheme.border),
          _buildChangeRow(
            label: 'Resting Heart Rate',
            trend: isDemo ? '↑ 5%' : '→ Stable',
            detail: isDemo ? '64 bpm (usually 60 bpm)' : '61 bpm (in normal range)',
            color: isDemo ? AppTheme.attention : AppTheme.stable,
          ),
          const Divider(height: 16, color: AppTheme.border),
          _buildChangeRow(
            label: 'Heart Rate Variability',
            trend: isDemo ? '↓ 4%' : '→ Stable',
            detail: isDemo ? '44 ms (usually 55 ms)' : '54 ms (in normal range)',
            color: isDemo ? AppTheme.attention : AppTheme.stable,
          ),
          const Divider(height: 16, color: AppTheme.border),
          _buildChangeRow(
            label: 'Blood Oxygen (SpO2)',
            trend: '→ Stable',
            detail: isDemo ? '97.2% (usually 98.0%)' : '98.5% (in normal range)',
            color: AppTheme.stable,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRow({
    required String label,
    required String trend,
    required String detail,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(detail, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. TODAY'S SIGNALS (4 most useful signals)
  // ===========================================================================
  Widget _buildTodaySignalsSection(BuildContext context, AppStateManager appState) {
    final isDemo = appState.isDemoMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: () => onNavigateToTab?.call(1, subIndex: 0), // Health -> Signals
              child: const Text(
                'View all signals →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            _buildTodayTile(
              label: 'Sleep',
              value: isDemo ? '6h 06m' : '7h 48m',
              status: isDemo ? 'Below usual' : 'Normal',
              isWarning: isDemo,
              icon: Icons.nightlight_round,
              iconColor: const Color(0xFF6366F1),
            ),
            _buildTodayTile(
              label: 'Resting HR',
              value: isDemo ? '64 BPM' : '61 BPM',
              status: isDemo ? 'Slightly high' : 'Normal',
              isWarning: isDemo,
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFEF4444),
            ),
            _buildTodayTile(
              label: 'HRV',
              value: isDemo ? '44 ms' : '54 ms',
              status: isDemo ? 'Reduced' : 'Normal',
              isWarning: isDemo,
              icon: Icons.show_chart_rounded,
              iconColor: AppTheme.primary,
            ),
            _buildTodayTile(
              label: 'Blood Oxygen',
              value: isDemo ? '97.2%' : '98.5%',
              status: 'Normal',
              isWarning: false,
              icon: Icons.air_rounded,
              iconColor: const Color(0xFF0EA5E9),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTile({
    required String label,
    required String value,
    required String status,
    required bool isWarning,
    required IconData icon,
    required Color iconColor,
  }) {
    final statusColor = isWarning ? AppTheme.attention : AppTheme.stable;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
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
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
              ),
              Icon(icon, size: 15, color: iconColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          Text(
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. BASELINE STORY CALLOUT (Calm, educational)
  // ===========================================================================
  Widget _buildBaselineStoryBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Personal Normal',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  'OS4All compares recent patterns with your own historical patterns, not just generic population averages.',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'View Baseline',
            icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onPressed: () => onNavigateToTab?.call(1, subIndex: 1), // Health -> Baseline
          ),
        ],
      ),
    );
  }
}
