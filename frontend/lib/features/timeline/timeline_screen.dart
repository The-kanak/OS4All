import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/demo_data.dart';
import '../../shared/widgets/healthcare_widgets.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _activeFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filtered = DemoData.timelineItems.where((item) {
      if (_activeFilter == 'ALL') return true;
      if (_activeFilter == 'LABS') return item['category'] == 'LAB';
      if (_activeFilter == 'VITALS') return item['category'] == 'VITAL';
      if (_activeFilter == 'LIFESTYLE') return item['category'] == 'LIFESTYLE';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Unified Health Timeline')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DemoDataNoticeBanner(label: 'DEMO DATA — NOT A REAL PATIENT'),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['ALL', 'LABS', 'VITALS', 'LIFESTYLE'].map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _activeFilter = filter),
                    backgroundColor: AppTheme.surfaceLight,
                    selectedColor: AppTheme.cyan.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.cyan : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: isSelected ? AppTheme.cyan : AppTheme.cardBorder),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const HealthcareEmptyState(
                    icon: Icons.history,
                    title: 'No Timeline Events',
                    description: 'No health events recorded under this filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HealthcareCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item['category'] == 'LAB'
                                      ? Icons.science
                                      : item['category'] == 'VITAL'
                                          ? Icons.favorite
                                          : Icons.bedtime,
                                  color: AppTheme.cyan,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item['timestamp'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                        HealthcareBadge(label: item['category'], color: AppTheme.indigo),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item['title'], style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text(item['subtitle'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('Source: ${item['source']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
