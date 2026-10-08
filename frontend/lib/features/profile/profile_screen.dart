import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/network/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';
import '../../shared/widgets/healthcare_widgets.dart';
import '../auth/login_screen.dart';
import '../consent/consent_screen.dart';
import '../dashboard/flagship_demo_screen.dart';
import '../dashboard/launch_demo_modal.dart';
import '../insights/intelligence_trace_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.apiBaseUrl;
  }

  void _showEditProfileDialog(BuildContext context, UserProfileModel? profile) {
    final nameCtrl = TextEditingController(text: profile?.fullName ?? 'Patient');
    final sexCtrl = TextEditingController(text: profile?.biologicalSex ?? 'MALE');
    final ageCtrl = TextEditingController(text: '${profile?.age ?? 34}');
    final heightCtrl = TextEditingController(text: '${profile?.heightCm ?? 178.0}');
    final weightCtrl = TextEditingController(text: '${profile?.weightKg ?? 74.0}');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit Biometric Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sexCtrl,
                decoration: const InputDecoration(labelText: 'Biological Sex (MALE/FEMALE)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age (Years)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height (cm)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final appState = AppStateManager.instance;
              await appState.updateProfile(UserProfileModel(
                id: profile?.id ?? 'user-me',
                email: profile?.email ?? 'user@os4all.demo',
                fullName: nameCtrl.text.trim(),
                biologicalSex: sexCtrl.text.trim(),
                age: int.tryParse(ageCtrl.text.trim()) ?? 34,
                heightCm: double.tryParse(heightCtrl.text.trim()) ?? 178.0,
                weightKg: double.tryParse(weightCtrl.text.trim()) ?? 74.0,
              ));
              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConfigureUrlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Configure Backend URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify Spring Boot 3.3 backend REST API base URL (Default port 8080):',
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:8080/api/v1',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = _urlController.text.trim();
              if (newUrl.isNotEmpty) {
                AppStateManager.instance.setCustomBaseUrl(newUrl);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated API base URL to $newUrl')),
                );
              }
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager.instance,
      builder: (context, _) {
        final appState = AppStateManager.instance;
        final profile = appState.userProfile;
        final isDemo = appState.isDemoMode;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppTheme.critical),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await appState.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDemo) ...[
                  const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
                  const SizedBox(height: 12),
                ],

                // User Info Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? (isDemo ? 'Dr. Alex Taylor' : 'Patient User'),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile?.email ?? (isDemo ? 'alex.taylor@os4all.demo' : 'user@os4all.com'),
                              style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _showEditProfileDialog(context, profile),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Biometrics Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Physiological Demographics',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                      const Divider(height: 16, color: AppTheme.border),
                      _buildProfileRow('Biological Sex', profile?.biologicalSex ?? 'MALE'),
                      _buildProfileRow('Age', '${profile?.age ?? 34} years'),
                      _buildProfileRow('Height', '${profile?.heightCm ?? 178.0} cm'),
                      _buildProfileRow('Weight', '${profile?.weightKg ?? 74.0} kg'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Honest Device Connections
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Health Data & Device Connections',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('TRANSPARENT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: AppTheme.border),
                      _buildDeviceRow('Google Health Connect', 'Not connected (Tap to connect)', false),
                      _buildDeviceRow('Smart Biosensor Watch', 'Sensor sync connector in development', false),
                      _buildDeviceRow('Manual Vital Telemetry', 'Active & calibrated', true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Mode & Backend Settings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Environment & Operating Mode',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const Divider(height: 16, color: AppTheme.border),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Deterministic Demo Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            isDemo
                                ? 'Running with deterministic synthetic data for judging'
                                : 'Connected directly to live Spring Boot backend',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          value: isDemo,
                          activeThumbColor: AppTheme.warning,
                          onChanged: (val) {
                            if (val) {
                              appState.setDemoMode();
                            } else {
                              appState.setLiveMode();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('API Base URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(AppConfig.apiBaseUrl, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showConfigureUrlDialog(context),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Hackathon Showcase & Judge Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Hackathon Presentation Showcase',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Instant one-click pipeline executions for judges to inspect multi-signal baseline deviation, anomaly detection, and intelligence synthesis.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => LaunchDemoModal.show(context),
                              icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                              label: const Text('10-Step Demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const IntelligenceTraceScreen()),
                              ),
                              icon: const Icon(Icons.account_tree_rounded, size: 16),
                              label: const Text('Trace Pipeline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FlagshipDemoScreen()),
                          ),
                          icon: const Icon(Icons.play_circle_filled_rounded, size: 16),
                          label: const Text('Flagship Scenario Walkthrough'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Privacy & Consents Link
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.textSecondary),
                    title: const Text('Patient Data Sovereignty & Consents', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ConsentScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await appState.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (r) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.critical, size: 18),
                    label: const Text('Sign Out', style: TextStyle(color: AppTheme.critical)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDeviceRow(String device, String status, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(status, style: TextStyle(fontSize: 11, color: active ? AppTheme.success : AppTheme.textMuted)),
            ],
          ),
          Icon(
            active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: active ? AppTheme.success : AppTheme.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}
