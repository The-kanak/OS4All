import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/health_connect_service.dart';
import '../../core/theme/app_theme.dart';
import '../state/app_state_manager.dart';

/// Interactive Google Health Connect card used across Profile and Health screens.
/// Truthfully reflects native Android Health Connect availability and permission states.
class GoogleHealthConnectCard extends StatefulWidget {
  final bool compact;

  const GoogleHealthConnectCard({super.key, this.compact = false});

  @override
  State<GoogleHealthConnectCard> createState() => _GoogleHealthConnectCardState();
}

class _GoogleHealthConnectCardState extends State<GoogleHealthConnectCard> {
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppStateManager.instance.checkHealthConnectStatus();
    });
  }

  Future<void> _handleConnect() async {
    setState(() => _isActionInProgress = true);
    final appState = AppStateManager.instance;

    try {
      final success = await appState.connectHealthConnect();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Health Connect successfully authorized!'),
              backgroundColor: AppTheme.stable,
            ),
          );
        } else {
          final err = appState.healthConnect.lastError;
          if (err != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err), backgroundColor: AppTheme.attention),
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isActionInProgress = true);
    final appState = AppStateManager.instance;

    try {
      final result = await appState.syncHealthConnect();
      if (mounted) {
        if (result.isSuccess) {
          final msg = result.importedCount > 0
              ? 'Health Connect synced: ${result.importedCount} new records imported (${result.skippedDuplicates} duplicates skipped).'
              : 'Health Connect synced: Up to date (0 new records, ${result.skippedDuplicates} existing records verified).';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppTheme.stable),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Sync failed'),
              backgroundColor: AppTheme.critical,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager.instance,
      builder: (context, _) {
        final appState = AppStateManager.instance;
        final hc = appState.healthConnect;
        final status = hc.status;
        final isSyncing = status == HealthConnectStatus.syncing || _isActionInProgress;

        return Container(
          padding: EdgeInsets.all(widget.compact ? 14 : 18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Google Health Connect',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getStatusSubtitle(status, hc),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (!widget.compact) ...[
                const SizedBox(height: 14),
                // Capabilities Chips
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MetricChip(label: 'Heart Rate'),
                    _MetricChip(label: 'Resting HR'),
                    _MetricChip(label: 'HRV (RMSSD)'),
                    _MetricChip(label: 'Blood Oxygen (SpO2)'),
                    _MetricChip(label: 'Daily Steps'),
                    _MetricChip(label: 'Sleep Duration'),
                  ],
                ),
              ],

              // Last sync info if available
              if (hc.lastSyncTime != null && status != HealthConnectStatus.unsupportedPlatform) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Last synced: ${_formatSyncTime(hc.lastSyncTime!)} • ${hc.lastImportedCount} imported • ${hc.lastSkippedCount} deduplicated',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),
              // Action Buttons
              _buildActionRow(context, appState, status, isSyncing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(HealthConnectStatus status) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case HealthConnectStatus.connected:
      case HealthConnectStatus.syncSuccess:
        badgeColor = AppTheme.stable;
        badgeText = 'CONNECTED';
        break;
      case HealthConnectStatus.syncing:
        badgeColor = AppTheme.primary;
        badgeText = 'SYNCING';
        break;
      case HealthConnectStatus.permissionRequired:
      case HealthConnectStatus.permissionPartiallyGranted:
        badgeColor = AppTheme.attention;
        badgeText = 'PERMISSIONS NEEDED';
        break;
      case HealthConnectStatus.sdkUpdateRequired:
        badgeColor = AppTheme.attention;
        badgeText = 'UPDATE REQUIRED';
        break;
      case HealthConnectStatus.sdkUnavailable:
        badgeColor = AppTheme.textMuted;
        badgeText = 'NOT INSTALLED';
        break;
      case HealthConnectStatus.unsupportedPlatform:
        badgeColor = AppTheme.textMuted;
        badgeText = 'ANDROID ONLY';
        break;
      case HealthConnectStatus.syncError:
        badgeColor = AppTheme.critical;
        badgeText = 'SYNC ERROR';
        break;
      case HealthConnectStatus.notConnected:
      case HealthConnectStatus.connecting:
        badgeColor = AppTheme.secondary;
        badgeText = 'READY TO CONNECT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: badgeColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _getStatusSubtitle(HealthConnectStatus status, HealthConnectService hc) {
    switch (status) {
      case HealthConnectStatus.connected:
      case HealthConnectStatus.syncSuccess:
        return 'Connected to Android Health Connect. Tap "Sync Now" to import your latest continuous readings.';
      case HealthConnectStatus.syncing:
        return 'Reading authorized health metrics and updating your personal baseline...';
      case HealthConnectStatus.permissionRequired:
        return 'Health Connect is installed. Tap below to review and grant read permissions for heart rate, sleep, steps, and HRV.';
      case HealthConnectStatus.permissionPartiallyGranted:
        return 'Partial permissions granted. Some metrics may not be available until authorized.';
      case HealthConnectStatus.sdkUpdateRequired:
        return 'Google Health Connect requires an update from the Play Store on this device.';
      case HealthConnectStatus.sdkUnavailable:
        return 'Google Health Connect is not currently installed on this Android device.';
      case HealthConnectStatus.unsupportedPlatform:
        return kIsWeb
            ? 'Web environment detected. Health Connect runs natively on Android. Manual vital entry is active and fully functional.'
            : 'Native Health Connect is supported on Android devices. Manual vital entry is available.';
      case HealthConnectStatus.syncError:
        return hc.lastError ?? 'An error occurred during synchronization. You can try syncing again.';
      case HealthConnectStatus.connecting:
        return 'Requesting Android Health Connect permissions...';
      case HealthConnectStatus.notConnected:
        return 'Connect to automatically sync resting HR, HRV, SpO2, sleep sessions, and daily step counts.';
    }
  }

  Widget _buildActionRow(BuildContext context, AppStateManager appState, HealthConnectStatus status, bool isSyncing) {
    if (status == HealthConnectStatus.unsupportedPlatform) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Use "Record health data" on the Home screen to enter vitals on Web & desktop.',
                style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    if (status == HealthConnectStatus.sdkUnavailable || status == HealthConnectStatus.sdkUpdateRequired) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => appState.healthConnect.installHealthConnect(),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: Text(status == HealthConnectStatus.sdkUpdateRequired ? 'Update Health Connect' : 'Install Health Connect'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11)),
        ),
      );
    }

    if (status == HealthConnectStatus.connected || status == HealthConnectStatus.syncSuccess) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isSyncing ? null : _handleSync,
              icon: isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: isSyncing ? null : _handleConnect,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14)),
            child: const Text('Permissions', style: TextStyle(fontSize: 12.5)),
          ),
        ],
      );
    }

    // Permission required or not connected
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSyncing ? null : _handleConnect,
        icon: isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.link_rounded, size: 18),
        label: Text(isSyncing ? 'Connecting...' : 'Connect Health Connect'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  String _formatSyncTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return DateFormat('h:mm a').format(dt);
    return DateFormat('MMM d, h:mm a').format(dt);
  }
}

class _MetricChip extends StatelessWidget {
  final String label;

  const _MetricChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
      ),
    );
  }
}
