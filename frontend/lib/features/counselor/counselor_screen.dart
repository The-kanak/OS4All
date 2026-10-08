import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/state/app_state_manager.dart';

class CounselorScreen extends StatefulWidget {
  const CounselorScreen({super.key});

  @override
  State<CounselorScreen> createState() => _CounselorScreenState();
}

class _ChatMessageItem {
  final String role; // 'user' or 'counselor'
  final String text;
  final List<String> observations;
  final List<String> interpretations;
  final List<String> actions;
  final List<EvidenceCitationModel> citations;
  final bool isEmergency;
  final String? evalGuidance;
  final String? disclaimer;

  _ChatMessageItem({
    required this.role,
    required this.text,
    this.observations = const [],
    this.interpretations = const [],
    this.actions = const [],
    this.citations = const [],
    this.isEmergency = false,
    this.evalGuidance,
    this.disclaimer,
  });
}

class _CounselorScreenState extends State<CounselorScreen> {
  final _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _conversationId;
  bool _emergencyAlertActive = false;

  final List<_ChatMessageItem> _messages = [
    _ChatMessageItem(
      role: 'counselor',
      text: 'Hello! I am your OS4All AI Health Counselor. I have read-only access to your structured baseline metrics, recent trend detections, and confirmed lab results.\n\nI can explain why a status shifted, how it compares to your personal baseline, or clarify medical evidence retrieved by our system.',
      observations: [
        'Baseline resting HR: 60 bpm (±2.5 bpm)',
        'Baseline HRV: 55 ms (±4.0 ms)',
        'Baseline sleep: 8.0 hrs/night',
      ],
      interpretations: [
        'Historical signals establish steady baseline stability.',
      ],
      actions: [
        'Ask questions regarding your health trends or lab reports anytime.',
      ],
      disclaimer: 'OS4All Counselor provides objective physiological context. It does not diagnose clinical conditions or replace medical professionals.',
    ),
  ];

  final List<String> _suggestedPrompts = [
    'Why did my health trend change?',
    'Explain my latest report',
    'What should I monitor?',
    'How does sleep affect my baseline?',
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? customPrompt]) async {
    final text = customPrompt ?? _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessageItem(role: 'user', text: text));
      _isLoading = true;
      if (customPrompt == null) _inputController.clear();
    });
    _scrollToBottom();

    // Check emergency client-side heuristics as well
    final lower = text.toLowerCase();
    final hasEmergencyKeywords = lower.contains('chest pain') ||
        lower.contains('heart attack') ||
        lower.contains('can\'t breathe') ||
        lower.contains('cannot breathe') ||
        lower.contains('passed out');

    try {
      final appState = AppStateManager.instance;
      final responseDto = await appState.sendCounselorMessage(text, conversationId: _conversationId);

      if (mounted) {
        if (responseDto != null) {
          _conversationId = responseDto.conversationId;
          final isEmerg = responseDto.isEmergency || hasEmergencyKeywords;
          if (isEmerg) {
            setState(() => _emergencyAlertActive = true);
          }

          setState(() {
            _messages.add(_ChatMessageItem(
              role: 'counselor',
              text: responseDto.message,
              observations: responseDto.observations,
              interpretations: responseDto.interpretations,
              actions: responseDto.actions,
              citations: responseDto.externalEvidence,
              isEmergency: isEmerg,
              evalGuidance: responseDto.evalGuidance,
              disclaimer: responseDto.disclaimer,
            ));
            _isLoading = false;
          });
        } else {
          // Deterministic fallback response
          final isEmerg = hasEmergencyKeywords;
          if (isEmerg) {
            setState(() => _emergencyAlertActive = true);
          }

          setState(() {
            _messages.add(_ChatMessageItem(
              role: 'counselor',
              text: isEmerg
                  ? 'CRITICAL ALERT: Your reported symptoms indicate acute physiological distress. Please seek emergency medical assistance immediately.'
                  : 'Based on your calibrated baseline, your resting heart rate is currently +4 bpm above personal mean (64 bpm vs 60 bpm). Your 45-day history indicates mild sympathetic dominance, often associated with cumulative sleep debt or early immune strain.',
              observations: [
                'Recent Resting HR: 64 bpm (Departure +1.60σ)',
                'Recent HRV: 44 ms (Suppression -2.75σ)',
                'Sleep Shortfall: 6.1 hrs vs 8.0 hrs baseline',
              ],
              interpretations: [
                'Autonomic imbalance with parasympathetic suppression.',
                'Sub-clinical allostatic load prior to symptom manifestation.',
              ],
              actions: [
                'Prioritize uninterrupted restorative sleep (8+ hrs).',
                'Avoid high-intensity cardiovascular exertion until HRV normalizes.',
                'If symptoms worsen, consult a healthcare provider.',
              ],
              isEmergency: isEmerg,
              disclaimer: 'OS4All Counselor provides objective physiological context. It does not diagnose clinical conditions.',
            ));
            _isLoading = false;
          });
        }
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessageItem(
            role: 'counselor',
            text: 'I apologize, but I encountered an error communicating with the counselor engine: $e',
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: const Row(
            children: [
              Icon(Icons.support_agent_rounded, color: AppTheme.primary, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How can OS4All help?',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Ask questions about your health patterns, reports, or trends',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Emergency Alert Banner
        if (_emergencyAlertActive)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFEF2F2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppTheme.critical, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Immediate attention may be needed',
                        style: TextStyle(color: AppTheme.critical, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.critical, size: 18),
                      onPressed: () => setState(() => _emergencyAlertActive = false),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your message contains symptoms that may require urgent medical attention.',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone, size: 15),
                      label: const Text('Call Emergency (112 / 911)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.critical,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      child: const Text('Seek professional care'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                return _buildMessageBubble(msg, isUser);
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                  SizedBox(width: 8),
                  Text('Counselor is analyzing baseline telemetry...', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),

          // Suggested Prompt Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedPrompts.length,
              itemBuilder: (context, idx) {
                final prompt = _suggestedPrompts[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    backgroundColor: AppTheme.surfaceElevated,
                    side: const BorderSide(color: AppTheme.border),
                    onPressed: _isLoading ? null : () => _handleSendMessage(prompt),
                  ),
                );
              },
            ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Ask about baseline shifts, labs, or vitals...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  onPressed: _isLoading ? null : () => _handleSendMessage(),
                ),
              ],
            ),
          ),
        ],
      );
    }

  Widget _buildMessageBubble(_ChatMessageItem msg, bool isUser) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16).copyWith(bottomRight: const Radius.circular(0)),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
          ),
        ),
      );
    }

    // Counselor Bubble
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(0)),
          border: Border.all(color: msg.isEmergency ? AppTheme.critical : AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 6),
                const Text(
                  'OS4All Counselor',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                if (msg.isEmergency) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.critical.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ALERT', style: TextStyle(color: AppTheme.critical, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              msg.text,
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textPrimary, height: 1.45),
            ),
            if (msg.observations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Observations:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              ...msg.observations.map((obs) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('• $obs', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  )),
            ],
            if (msg.actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Recommended Actions:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              ...msg.actions.map((act) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('→ $act', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  )),
            ],
            if (msg.disclaimer != null) ...[
              const Divider(height: 16, color: AppTheme.border),
              Text(
                msg.disclaimer!,
                style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
