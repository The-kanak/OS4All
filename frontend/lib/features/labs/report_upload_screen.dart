import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';

class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({super.key});

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  bool _isProcessing = false;
  String? _statusMessage;
  LabReportModel? _extractedReport;
  String? _errorMessage;
  bool _isConfirmed = false;

  Future<void> _pickAndUploadPdf() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) {
        return;
      }

      final file = files.first;
      final bytes = await file.readAsBytes();
      final filename = file.name;

      await _uploadBytes(bytes, filename);
    } catch (e) {
      setState(() {
        _errorMessage = 'File selection error: $e';
      });
    }
  }

  Future<void> _uploadSamplePdf() async {
    setState(() {
      _errorMessage = null;
    });

    const samplePdfContent = '''
%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R >> endobj
4 0 obj << /Length 200 >> stream
BT
/F1 12 Tf
72 712 Td
(OS4All Synthetic Clinical Laboratory Panel) Tj
0 -20 Td
(Total Cholesterol: 215 mg/dL [Reference: <200]) Tj
0 -20 Td
(Fasting Glucose: 94 mg/dL [Reference: 70-99]) Tj
0 -20 Td
(hs-CRP: 2.1 mg/L [Reference: <1.0]) Tj
ET
endstream
endobj
xref
0 5
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000216 00000 n 
trailer << /Size 5 /Root 1 0 R >>
startxref
468
%%EOF
''';
    final bytes = Uint8List.fromList(utf8.encode(samplePdfContent));
    await _uploadBytes(bytes, 'sample_blood_panel.pdf');
  }

  Future<void> _uploadBytes(Uint8List bytes, String filename) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Reading document and extracting biomarkers...';
    });

    final appState = AppStateManager.instance;
    final report = await appState.uploadReport(bytes, filename);

    if (mounted) {
      if (report != null) {
        setState(() {
          _isProcessing = false;
          _extractedReport = report;
          _statusMessage = null;
        });
      } else if (appState.isDemoMode) {
        // Deterministic fallback exclusively for offline demo presentation
        setState(() {
          _isProcessing = false;
          _extractedReport = LabReportModel(
            id: 'mock-report-uuid-01',
            reportTitle: 'Comprehensive Blood Panel',
            laboratoryName: 'Clinical Pathology Laboratory',
            collectionDate: DateTime.now().toIso8601String(),
            fileName: filename,
            results: [
              LabResultItemModel(
                id: '1',
                biomarker: 'Total Cholesterol',
                standardizedBiomarker: 'TOTAL_CHOLESTEROL',
                value: 215.0,
                unit: 'mg/dL',
                referenceHigh: 200.0,
                reviewRequired: true,
                confidence: 0.98,
              ),
              LabResultItemModel(
                id: '2',
                biomarker: 'Fasting Blood Glucose',
                standardizedBiomarker: 'FASTING_GLUCOSE',
                value: 94.0,
                unit: 'mg/dL',
                referenceLow: 70.0,
                referenceHigh: 99.0,
                reviewRequired: false,
                confidence: 0.99,
              ),
              LabResultItemModel(
                id: '3',
                biomarker: 'hs-CRP (Inflammation)',
                standardizedBiomarker: 'HS_CRP',
                value: 2.1,
                unit: 'mg/L',
                referenceHigh: 1.0,
                reviewRequired: true,
                confidence: 0.95,
              ),
              LabResultItemModel(
                id: '4',
                biomarker: 'HDL Cholesterol',
                standardizedBiomarker: 'HDL_CHOLESTEROL',
                value: 52.0,
                unit: 'mg/dL',
                referenceLow: 40.0,
                referenceHigh: 99.0,
                reviewRequired: false,
                confidence: 0.97,
              ),
            ],
          );
          _statusMessage = null;
        });
      } else {
        // Live Mode: Honest error display
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
          _errorMessage = appState.errorMessage ?? 'Report processing failed. Please verify the document format.';
        });
      }
    }
  }

  Future<void> _confirmReport() async {
    if (_extractedReport == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Saving markers into your personal health record...';
    });

    final appState = AppStateManager.instance;
    await appState.confirmReport(_extractedReport!.id);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isConfirmed = true;
        _statusMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lab markers confirmed and added to your health records.'),
          backgroundColor: AppTheme.stable,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Upload Health Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calm, Trustworthy Ingestion Callout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_user_outlined, color: AppTheme.primary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Upload medical lab reports in PDF format. OS4All carefully extracts key health markers so you can review and verify each value before it becomes part of your health baseline.',
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textPrimary, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Supported Format Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Supported format: PDF documents. (Mobile photo capture is in development)',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_isProcessing) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primary),
                        const SizedBox(height: 20),
                        Text(
                          _statusMessage ?? 'Processing document...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Extracting analytes, reference ranges, and test values',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ] else if (_extractedReport == null) ...[
                  // Upload Selection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primary, size: 36),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Select Medical Report',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Choose a lab report or clinical blood panel from your device',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickAndUploadPdf,
                              icon: const Icon(Icons.folder_open_rounded, size: 18),
                              label: const Text('Browse Device PDF'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _uploadSamplePdf,
                              icon: const Icon(Icons.science_outlined, size: 18),
                              label: const Text('Use Sample PDF'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.critical.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.critical.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 18, color: AppTheme.critical),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.critical, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  // Extracted Markers Review
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Extracted Health Markers',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${_extractedReport!.results.length} results found in ${_extractedReport!.fileName}',
                                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isConfirmed ? AppTheme.stable.withValues(alpha: 0.12) : AppTheme.attention.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isConfirmed ? 'CONFIRMED' : 'READY FOR REVIEW',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _isConfirmed ? AppTheme.stable : AppTheme.attention,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 26, color: AppTheme.border),
                        const Text(
                          'Review each extracted marker and its range before confirming:',
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 14),

                        // List of Extracted Biomarkers
                        ..._extractedReport!.results.map((result) {
                          final isOutOfRange = result.reviewRequired || result.flag.toUpperCase() == 'HIGH';
                          final statusColor = isOutOfRange ? AppTheme.attention : AppTheme.stable;
                          final statusLabel = isOutOfRange ? 'Elevated' : 'Normal';
                          final isHighConf = result.confidence >= 0.90;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.testName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Ref: ${result.referenceRange} ${result.unit}',
                                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isHighConf ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.attention.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isHighConf ? 'High confidence' : 'Review suggested',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: isHighConf ? AppTheme.primary : AppTheme.attention,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${result.value} ${result.unit}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 18),

                        if (!_isConfirmed) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _confirmReport,
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                              label: const Text('Confirm & Save to Health Records'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _extractedReport = null;
                                  _errorMessage = null;
                                });
                              },
                              child: const Text('Choose Another File', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.stable.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.stable.withValues(alpha: 0.25)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.stable, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Report confirmed and integrated into your health timeline.',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Done • Return'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
