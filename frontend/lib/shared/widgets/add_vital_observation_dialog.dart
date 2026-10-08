import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../state/app_state_manager.dart';

class AddVitalObservationDialog extends StatefulWidget {
  const AddVitalObservationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const AddVitalObservationDialog(),
    );
  }

  @override
  State<AddVitalObservationDialog> createState() => _AddVitalObservationDialogState();
}

class _AddVitalObservationDialogState extends State<AddVitalObservationDialog> {
  String _selectedMetric = 'RESTING_HR';
  final _valueController = TextEditingController(text: '62');
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  final Map<String, Map<String, String>> _metricDetails = {
    'RESTING_HR': {'name': 'Resting Heart Rate', 'unit': 'bpm', 'default': '62'},
    'HRV': {'name': 'Heart Rate Variability', 'unit': 'ms', 'default': '52'},
    'SPO2': {'name': 'Blood Oxygen (SpO2)', 'unit': '%', 'default': '98'},
    'SLEEP_DURATION': {'name': 'Sleep Duration', 'unit': 'hours', 'default': '7.5'},
    'BODY_TEMP': {'name': 'Body Temperature', 'unit': '°C', 'default': '36.8'},
    'ACTIVITY': {'name': 'Daily Steps', 'unit': 'steps', 'default': '8500'},
  };

  void _onMetricChanged(String? newMetric) {
    if (newMetric == null) return;
    setState(() {
      _selectedMetric = newMetric;
      _valueController.text = _metricDetails[newMetric]?['default'] ?? '0';
    });
  }

  Future<void> _handleSubmit() async {
    final valueText = _valueController.text.trim();
    final value = double.tryParse(valueText);
    if (value == null) {
      setState(() => _errorMessage = 'Please enter a valid numeric value');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final unit = _metricDetails[_selectedMetric]?['unit'] ?? '';
      final appState = AppStateManager.instance;
      final success = await appState.addObservation(
        HealthObservationModel(
          metricType: _selectedMetric,
          value: value,
          unit: unit,
          recordedAt: DateTime.now(),
          source: 'MANUAL_ENTRY',
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        ),
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recorded ${_metricDetails[_selectedMetric]?['name']}: $value $unit'),
              backgroundColor: AppTheme.success,
            ),
          );
        } else {
          setState(() {
            _isSubmitting = false;
            _errorMessage = appState.errorMessage ?? 'Failed to submit observation';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_chart_rounded, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Record Vital Observation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Metric',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedMetric,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _metricDetails.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text('${entry.value['name']} (${entry.value['unit']})'),
                );
              }).toList(),
              onChanged: _onMetricChanged,
            ),
            const SizedBox(height: 16),
            Text(
              'Value (${_metricDetails[_selectedMetric]?['unit']})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixText: _metricDetails[_selectedMetric]?['unit'],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Context / Notes (Optional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'e.g. Morning fasting, post-exercise, rest',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.critical, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Record Vital'),
        ),
      ],
    );
  }
}
