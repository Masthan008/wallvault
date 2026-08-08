import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/effects/entrance.dart';
import '../../../core/widgets/effects/glass_panel.dart';
import '../../../core/widgets/effects/progress_bar.dart';

/// S22 — Creator analytics: animated downloads/revenue charts + top performers.
///
/// Charts render sample data until a creator-stats endpoint lands. Swap
/// [downloads] / [revenue] / [performers] sources once wired to Firestore.
class CreatorAnalyticsScreen extends StatefulWidget {
  const CreatorAnalyticsScreen({super.key});

  @override
  State<CreatorAnalyticsScreen> createState() => _CreatorAnalyticsScreenState();
}

class _CreatorAnalyticsScreenState extends State<CreatorAnalyticsScreen> {
  static const _ranges = ['7D', '30D', '90D', 'All'];
  String _selected = '30D';

  static const _downloads = <double>[
    42, 58, 39, 71, 64, 88, 96, 74, 83, 102, 118, 130,
    122, 141, 156, 149, 168, 175, 189, 182, 204, 221, 210, 240,
  ];

  static const _revenue = <double>[
    412, 380, 495, 520, 470, 612, 700, 648, 725, 810, 788, 934,
  ];

  static const _performers = <(String, int)>[
    ('Neon Horizon', 3420),
    ('Cyber Alley', 3110),
    ('Midnight Bloom', 2870),
    ('Static Dreams', 2550),
    ('Frost Peak', 2290),
  ];

  List<double> get _downloadsForRange {
    switch (_selected) {
      case '7D':
        return _downloads.sublist(_downloads.length - 7);
      case '90D':
        return List<double>.generate(
          12,
          (i) => 44 + (i % 5) * 16 + math.sin(i / 2) * 12,
        );
      case 'All':
        return List<double>.generate(
          18,
          (i) => 48 + (i % 6) * 13 + math.cos(i / 3) * 16,
        );
      default:
        return _downloads;
    }
  }

  List<double> get _revenueData {
    if (_selected != 'All' && _selected != '90D') return _revenue;
    return _revenue.sublist(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Range pills ────────────────────────────────────────────
              Entrance.fadeUp(
                Row(
                  children: _ranges.map((label) {
                    final selected = label == _selected;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = label),
                        child: AnimatedContainer(
                          duration: AppAnimations.fast,
                          curve: AppAnimations.easeOutExpo,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentPurple
                                : AppColors.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accentPurple
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentPurple
                                          .withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      spreadRadius: -2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                delayMs: 60,
              ),
              const SizedBox(height: 24),

              // ── KPI cards ──────────────────────────────────────────────
              Entrance.fadeUp(
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        label: 'Earnings',
                        value: '₹12.4k',
                        delta: '+23.5%',
                        icon: Icons.payments_rounded,
                        gradient: AppColors.gradientHero,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiCard(
                        label: 'Downloads',
                        value: '3.4k',
                        delta: '+12.1%',
                        icon: Icons.download_rounded,
                        gradient: AppColors.gradientPremium,
                      ),
                    ),
                  ],
                ),
                delayMs: 100,
              ),
              const SizedBox(height: 12),
              Entrance.fadeUp(
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        label: 'Wallpapers',
                        value: '47',
                        delta: '+4',
                        icon: Icons.collections_rounded,
                        gradient: AppColors.gradientGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiCard(
                        label: 'Followers',
                        value: '892',
                        delta: '+8.3%',
                        icon: Icons.people_rounded,
                        gradient: AppColors.gradientSuccess,
                      ),
                    ),
                  ],
                ),
                delayMs: 160,
              ),
              const SizedBox(height: 28),

              // ── Downloads over time ────────────────────────────────────
              Entrance.fadeUp(
                Text('Downloads Over Time', style: AppTypography.h3),
                delayMs: 200,
              ),
              const SizedBox(height: 12),
              Entrance.fadeUp(
                GlassPanel(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                  child: SizedBox(
                    height: 210,
                    child: _DownloadsChart(values: _downloadsForRange),
                  ),
                ),
                delayMs: 240,
              ),
              const SizedBox(height: 28),

              // ── Revenue ────────────────────────────────────────────────
              Entrance.fadeUp(
                Text('Revenue', style: AppTypography.h3),
                delayMs: 280,
              ),
              const SizedBox(height: 12),
              Entrance.fadeUp(
                GlassPanel(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: SizedBox(
                    height: 190,
                    child: _RevenueBars(values: _revenueData),
                  ),
                ),
                delayMs: 320,
              ),
              const SizedBox(height: 28),

              // ── Top performers ─────────────────────────────────────────
              Entrance.fadeUp(
                Text('Top Performers', style: AppTypography.h3),
                delayMs: 360,
              ),
              const SizedBox(height: 12),
              _TopPerformers(performers: _performers),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact KPI card with gradient icon chip and delta pill.
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final LinearGradient gradient;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '▲ $delta',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentSuccess,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Smooth gradient area chart of downloads over the range.
class _DownloadsChart extends StatelessWidget {
  final List<double> values;

  const _DownloadsChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];
    final maxY = values.fold(0.0, math.max) * 1.2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(1, values.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).roundToDouble(),
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: values.length > 12 ? (values.length / 4).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${value.toInt() + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.bgElevated,
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '${s.y.toInt()} DL',
                TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            barWidth: 3,
            color: AppColors.accentCyan,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentCyan.withValues(alpha: 0.30),
                  AppColors.accentCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      duration: AppAnimations.slow,
      curve: AppAnimations.easeOutExpo,
    );
  }
}

/// Rounded gradient revenue bars.
class _RevenueBars extends StatelessWidget {
  final List<double> values;

  const _RevenueBars({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold(0.0, math.max) * 1.2;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxV,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxV / 4).roundToDouble(),
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${value.toInt() + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.bgElevated,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '₹${rod.toY.round()}',
              TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: values.length > 12 ? 6 : 10,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.accentPurple.withValues(alpha: 0.5),
                      AppColors.accentPurple,
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: AppAnimations.slow,
      curve: AppAnimations.easeOutExpo,
    );
  }
}

/// Ranked performer rows with animated progress bars.
class _TopPerformers extends StatelessWidget {
  final List<(String, int)> performers;

  const _TopPerformers({required this.performers});

  @override
  Widget build(BuildContext context) {
    final maxDl = performers.fold<int>(0, (m, p) => math.max(m, p.$2));

    return Column(
      children: [
        for (var i = 0; i < performers.length; i++)
          Entrance.fadeUp(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                  vertical: 14,
                ),
                radius: AppSpacing.radiusInput,
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '#${i + 1}',
                        style: AppTypography.h3.copyWith(
                          color: i == 0
                              ? AppColors.accentGold
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            performers[i].$1,
                            style:
                                AppTypography.h4.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          AnimatedProgressBar(
                            value: performers[i].$2 / maxDl,
                            color: i == 0
                                ? AppColors.accentGold
                                : AppColors.accentPurple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${performers[i].$2} DL',
                      style: AppTypography.caption.copyWith(
                        color: performers[i].$2 > 2500
                            ? AppColors.accentCyan
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            delayMs: 200 + i * 60,
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}