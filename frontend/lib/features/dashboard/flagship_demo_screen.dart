import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/healthcare_widgets.dart';

class FlagshipDemoScreen extends StatefulWidget {
  const FlagshipDemoScreen({super.key});

  @override
  State<FlagshipDemoScreen> createState() => _FlagshipDemoScreenState();
}

class _FlagshipDemoScreenState extends State<FlagshipDemoScreen> {
  int _activeStep = 0;
  bool _isAutoPlaying = false;

  final List<Map<String, dynamic>> _demoSteps = [
    {
      'title': 'DATA',
      'label': 'Step 1 of 9',
      'icon': Icons.sensors_outlined,
      'color': AppTheme.cyan,
      'tag': 'Continuous Ingestion',
      'headline': '35 Days of Longitudinal Wearable Ingestion',
      'summary':
          'Raw continuous biometric signals collected across days 1–35 for synthetic subject Alex Morgan (Resting HR, nocturnal HRV, sleep duration, and body temperature).',
      'details': [
        'Days 1–30: Stable baseline tracking period',
        'Days 31–35: Controlled multi-signal perturbation',
        'Unit normalization: bpm, ms, hours, °C',
      ],
    },
    {
      'title': 'BASELINE',
      'label': 'Step 2 of 9',
      'icon': Icons.analytics_outlined,
      'color': AppTheme.cyan,
      'tag': 'Personal Baseline Engine',
      'headline': 'Personal Homeostatic Baselines Established',
      'summary':
          '"Normal for the population is not normal for the individual." The Personal Baseline Engine establishes 30-day individual historical ranges with statistical variance.',
      'details': [
        'Resting Heart Rate: 60.0 bpm (± 2.5 bpm range: 57.5 – 62.5)',
        'Nocturnal HRV: 55.0 ms (± 3.8 ms range: 51.2 – 58.8)',
        'Sleep Duration: 8.0 hrs/night (± 0.5 hrs)',
        'Body Temperature: 36.6 °C (± 0.2 °C)',
      ],
    },
    {
      'title': 'DRIFT',
      'label': 'Step 3 of 9',
      'icon': Icons.trending_up_outlined,
      'color': AppTheme.warning,
      'tag': 'Directional Divergence',
      'headline': 'Day 31–32: Persistent Directional Drift',
      'summary':
          'Signals begin to exhibit a persistent directional departure from the personal mean. Sleep begins dropping and resting heart rate shifts upward.',
      'details': [
        'Day 31: Sleep 6.5 hrs (-1.5h), Resting HR 65 bpm (+5 bpm)',
        'Day 32: Sleep 5.8 hrs (-2.2h), Resting HR 69 bpm (+9 bpm)',
        'Trend persistence counter starts: >= 2 consecutive days',
      ],
    },
    {
      'title': 'MULTI-SIGNAL PATTERN',
      'label': 'Step 4 of 9',
      'icon': Icons.hub_outlined,
      'color': AppTheme.danger,
      'tag': 'Rule-Based Anomaly Engine',
      'headline': 'Multi-Signal Correlation Layer Triggered',
      'summary':
          'Compound autonomic strain pattern detected: Sleep ↓ + Resting HR ↑ + HRV ↓ + Temp ↑ persistent across 4 consecutive days without opaque black-box AI.',
      'details': [
        'Resting HR: 74.5 bpm (+14.5 bpm above personal baseline, +2.4σ)',
        'HRV: 36.0 ms (-19.0 ms below personal baseline, -2.1σ)',
        'Sleep: 5.0 hrs (-3.0 hrs vs 8.0 hr personal average)',
        'Multi-signal confidence: 0.96 | State: ANOMALY (Multi-Signal)',
      ],
    },
    {
      'title': 'NEMOTRON REASONING',
      'label': 'Step 5 of 9',
      'icon': Icons.memory_outlined,
      'color': AppTheme.indigo,
      'tag': 'AI Intelligence Layer',
      'headline': 'NVIDIA Nemotron Multi-Agent Orchestration',
      'summary':
          'Structured health context is supplied to 5 logical agents (Health Context, Trend, Evidence, Explanation, Action). AI receives only curated read-only snapshots and never diagnoses disease.',
      'details': [
        'Observations strictly distinguished from interpretations',
        'Acknowledges statistical uncertainty & personal baseline shift',
        'Never fabricates patient history or invents lab values',
      ],
    },
    {
      'title': 'TAVILY EVIDENCE',
      'label': 'Step 6 of 9',
      'icon': Icons.travel_explore_outlined,
      'color': AppTheme.cyanMuted,
      'tag': 'Evidence Agent Retrieval',
      'headline': 'Constrained Medical Literature Retrieval',
      'summary':
          'Evidence retrieval is triggered selectively for compound autonomic deviations, fetching peer-reviewed medical citations from PubMed / Frontiers in Physiology.',
      'details': [
        'Citation: Heart rate variability as a marker of autonomic recovery and physical stress (Frontiers in Physiology)',
        'Relevance Score: 0.94',
        'Evidence kept strictly isolated from raw medical records',
      ],
    },
    {
      'title': 'OS4All INSIGHT',
      'label': 'Step 7 of 9',
      'icon': Icons.insights_outlined,
      'color': AppTheme.cyan,
      'tag': 'Structured Health Synthesis',
      'headline': 'Transparent Plain-Language Synthesis',
      'summary':
          'Produces high-confidence, non-diagnostic synthesis explaining what shifted relative to historical baselines, duration of persistence, and underlying physiological hypotheses.',
      'details': [
        'Explanation: "Personal baseline analysis indicates a multi-signal autonomic strain pattern over the last 48-72 hours."',
        'Urgency rating: MONITOR',
        'Standard OS4All clinical disclaimer enforced',
      ],
    },
    {
      'title': 'ACTION',
      'label': 'Step 8 of 9',
      'icon': Icons.task_alt_outlined,
      'color': AppTheme.success,
      'tag': 'Action Agent Plan',
      'headline': 'Personalized Non-Invasive Action Plan',
      'summary':
          'Formulates pragmatic recovery guidance and defines criteria for when in-person clinical physician evaluation is appropriate.',
      'details': [
        'Prioritize 8 hours of restorative sleep across consecutive evenings',
        'Deload high-intensity training load in favor of active recovery',
        'Clinical criterion: Seek doctor evaluation if pulse remains elevated >5 days',
      ],
    },
    {
      'title': 'TIMELINE UPDATE',
      'label': 'Step 9 of 9',
      'icon': Icons.timeline_outlined,
      'color': AppTheme.cyan,
      'tag': 'Unified Longitudinal Record',
      'headline': 'Audit Log & Unified Timeline Updated',
      'summary':
          'Real-time unified timeline records the entire chain: observations, baseline calculations, anomaly triggers, evidence lookups, and generated insights.',
      'details': [
        'Tamper-evident audit trail logged with SHA-256 integrity hash',
        'Timeline viewable in chronological unified patient interface',
        'All synthetic events tagged clearly as DEMO DATA',
      ],
    },
  ];

  void _nextStep() {
    if (_activeStep < _demoSteps.length - 1) {
      setState(() => _activeStep++);
    }
  }

  void _prevStep() {
    if (_activeStep > 0) {
      setState(() => _activeStep--);
    }
  }

  void _playAutoSequence() async {
    setState(() {
      _isAutoPlaying = true;
      _activeStep = 0;
    });

    for (int i = 0; i < _demoSteps.length; i++) {
      if (!_isAutoPlaying || !mounted) break;
      setState(() => _activeStep = i);
      await Future.delayed(const Duration(milliseconds: 1400));
    }

    if (mounted) {
      setState(() => _isAutoPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _demoSteps[_activeStep];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.surfaceLight,
              child: Icon(Icons.play_circle_filled, color: AppTheme.cyan, size: 18),
            ),
            SizedBox(width: 10),
            Text('Flagship Demo: Complete Chain'),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: Icon(_isAutoPlaying ? Icons.stop : Icons.play_arrow, color: AppTheme.cyan, size: 18),
            label: Text(_isAutoPlaying ? 'Stop' : 'Autoplay', style: const TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (_isAutoPlaying) {
                setState(() => _isAutoPlaying = false);
              } else {
                _playAutoSequence();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Synthetic Demo Notice Banner
            const DemoDataNoticeBanner(
              label: 'DEMO DATA — NOT A REAL PATIENT',
            ),
            const SizedBox(height: 12),

            // Horizontal Chain Progression Pills
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _demoSteps.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final s = _demoSteps[idx];
                  final isCurrent = idx == _activeStep;
                  final isPast = idx < _activeStep;

                  return GestureDetector(
                    onTap: () => setState(() => _activeStep = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.cyan.withValues(alpha: 0.2)
                            : (isPast ? AppTheme.surfaceLight : AppTheme.cardBg),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isCurrent ? AppTheme.cyan : (isPast ? AppTheme.indigo : AppTheme.cardBorder),
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPast ? Icons.check_circle : s['icon'],
                            size: 16,
                            color: isCurrent ? AppTheme.cyan : (isPast ? AppTheme.indigo : AppTheme.textMuted),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s['title'],
                            style: TextStyle(
                              color: isCurrent ? AppTheme.cyan : AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Main Step Showcase Card
            HealthcareCard(
              padding: const EdgeInsets.all(20),
              borderColor: step['color'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (step['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(step['icon'], color: step['color'], size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['label'],
                              style: TextStyle(color: step['color'], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step['title'],
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      HealthcareBadge(
                        label: step['tag'],
                        color: step['color'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    step['headline'],
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['summary'],
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Key Evidence & Parameters', style: TextStyle(color: AppTheme.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...(step['details'] as List<String>).map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppTheme.cyan, fontSize: 12)),
                              Expanded(
                                child: Text(d, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, height: 1.35)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step Navigation Controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    onPressed: _activeStep > 0 ? _prevStep : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_activeStep == _demoSteps.length - 1 ? 'Finish Demo' : 'Next Step'),
                    onPressed: _activeStep < _demoSteps.length - 1 ? _nextStep : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
