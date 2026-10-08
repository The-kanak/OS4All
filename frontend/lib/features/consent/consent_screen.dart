import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';
import '../../shared/widgets/healthcare_widgets.dart';
import '../shell/app_shell.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _dataStorageGranted = true;
  bool _aiInferenceGranted = true;
  bool _evidenceSearchGranted = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingConsents();
  }

  void _loadExistingConsents() {
    final consent = AppStateManager.instance.consent;
    if (consent != null) {
      setState(() {
        _dataStorageGranted = consent.dataStorageConsent;
        _aiInferenceGranted = consent.aiProcessingConsent;
        _evidenceSearchGranted = consent.evidenceSearchConsent;
      });
    }
  }

  Future<void> _submitConsent() async {
    setState(() => _isLoading = true);

    final appState = AppStateManager.instance;
    await appState.submitConsent(UserConsentModel(
      dataStorageConsent: _dataStorageGranted,
      aiProcessingConsent: _aiInferenceGranted,
      evidenceSearchConsent: _evidenceSearchGranted,
      grantedAt: DateTime.now().toIso8601String(),
      revokedAt: null,
    ));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Patient Health Consent')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data Sovereignty & Privacy',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You maintain total ownership of your biometric data. Choose how OS4All processes your signals.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              HealthcareCard(
                child: Column(
                  children: [
                    _buildConsentTile(
                      title: 'Local Health Data Storage',
                      subtitle: 'Store and calculate individual baseline metrics from continuous sensor observations.',
                      value: _dataStorageGranted,
                      onChanged: (val) => setState(() => _dataStorageGranted = val),
                    ),
                    const Divider(color: AppTheme.cardBorder, height: 24),
                    _buildConsentTile(
                      title: 'AI Multi-Agent Inference',
                      subtitle: 'Permit non-diagnostic reasoning agents to interpret personal baseline trends into structured insights.',
                      value: _aiInferenceGranted,
                      onChanged: (val) => setState(() => _aiInferenceGranted = val),
                    ),
                    const Divider(color: AppTheme.cardBorder, height: 24),
                    _buildConsentTile(
                      title: 'Biomedical Evidence Retrieval',
                      subtitle: 'Allow selective literature lookups against peer-reviewed journals (Tavily/PubMed) during anomaly detection.',
                      value: _evidenceSearchGranted,
                      onChanged: (val) => setState(() => _evidenceSearchGranted = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_clock_outlined, color: AppTheme.primary, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All consent updates are logged to tamper-evident SHA-256 audit trails. You may revoke consent at any time in Profile & Settings.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitConsent,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Preferences & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.35)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          activeThumbColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
