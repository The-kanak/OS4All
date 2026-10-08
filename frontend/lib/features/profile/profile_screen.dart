import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/demo_data.dart';
import '../../shared/widgets/healthcare_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Patient Health Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.cyan, width: 2),
                    ),
                    child: const Icon(Icons.person, color: AppTheme.cyan, size: 44),
                  ),
                  const SizedBox(height: 12),
                  const Text(DemoData.userFullName, style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text(DemoData.userEmail, style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            HealthcareCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Demographics & Biometric Baselines', style: TextStyle(color: AppTheme.cyan, fontSize: 14, fontWeight: FontWeight.w700)),
                  const Divider(color: AppTheme.cardBorder, height: 20),
                  _buildProfileRow('Biological Sex', DemoData.biologicalSex),
                  _buildProfileRow('Age', '${DemoData.userAge} years'),
                  _buildProfileRow('Height', '180 cm'),
                  _buildProfileRow('Weight', '75.5 kg'),
                  _buildProfileRow('Blood Type', 'O Positive'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HealthcareCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wearable Device Connections', style: TextStyle(color: AppTheme.cyan, fontSize: 14, fontWeight: FontWeight.w700)),
                  const Divider(color: AppTheme.cardBorder, height: 20),
                  _buildConnectionRow('Smart Biosensor Watch', 'Connected • Continuous Syncing', true),
                  _buildConnectionRow('Smart Sleep Ring', 'Connected • Last Synced 2 hrs ago', true),
                  _buildConnectionRow('Continuous Glucose Sensor', 'Available for Pairing', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildConnectionRow(String device, String status, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(status, style: TextStyle(color: active ? AppTheme.success : AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          Icon(active ? Icons.bluetooth_connected : Icons.bluetooth, color: active ? AppTheme.cyan : AppTheme.textMuted, size: 20),
        ],
      ),
    );
  }
}
