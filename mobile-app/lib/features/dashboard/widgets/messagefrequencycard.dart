import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/services/can_service.dart';
import 'package:gp/core/theme/app_colors.dart';

class MessageFrequencyCard extends StatelessWidget {
  final double frequency;
  final List<CANMessage> messages;

  const MessageFrequencyCard({
    super.key,
    required this.frequency,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final displayFrequency = _receivedFrequency;
    final spots = _frequencySpots;
    final labels = _timeLabels;
    final maxY = _maxY(spots);
    final yInterval = maxY / 4;
    final spikePercent = _spikePercent(spots);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.medDarkblueColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.secondaryblueColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
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
                    Text(
                      "MESSAGE FREQUENCY",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.greyColor.withValues(alpha: 0.9),
                        fontSize: 12.sp,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${_formatFrequency(displayFrequency)} Hz",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (spikePercent > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryred.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "+${spikePercent.toStringAsFixed(0)}% Spike",
                    style: TextStyle(
                      color: const Color(0xFFFF7B7B),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 180.h,
            child: Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.greyColor.withValues(alpha: 0.24),
                      strokeWidth: 1,
                      dashArray: [5, 6],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 30,
                        reservedSize: 30.h,
                        getTitlesWidget: (value, meta) {
                          final index = (value / 30).round();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                color: AppColors.greyColor.withValues(
                                  alpha: 0.72,
                                ),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: spots.length > 2,
                      curveSmoothness: 0.38,
                      color: AppColors.secondaryblueColor,
                      barWidth: 4.w,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.secondaryblueColor.withValues(
                              alpha: 0.58,
                            ),
                            AppColors.secondaryblueColor.withValues(
                              alpha: 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: 60,
                  minY: 0,
                  maxY: maxY,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _receivedFrequency {
    if (messages.length < 2) {
      return messages.isNotEmpty ? messages.length.toDouble() : frequency;
    }
    final elapsed = messages.last.timestamp - messages.first.timestamp;
    if (elapsed <= 0) return messages.length.toDouble();
    return messages.length / elapsed;
  }

  List<FlSpot> get _frequencySpots {
    if (messages.isEmpty) return const [FlSpot(0, 0), FlSpot(60, 0)];

    const bucketCount = 7;
    const maxX = 60.0;
    final buckets = List<double>.filled(bucketCount, 0);
    final firstTimestamp = messages.first.timestamp;
    final elapsed = messages.last.timestamp - firstTimestamp;

    for (final message in messages) {
      final normalizedX = elapsed > 0
          ? ((message.timestamp - firstTimestamp) / elapsed) * maxX
          : maxX;
      final bucket = ((normalizedX / maxX) * (bucketCount - 1))
          .round()
          .clamp(0, bucketCount - 1)
          .toInt();
      buckets[bucket] += 1;
    }

    return [
      for (var i = 0; i < bucketCount; i++)
        FlSpot((maxX / (bucketCount - 1)) * i, buckets[i]),
    ];
  }

  List<String> get _timeLabels {
    if (messages.isEmpty) return const ["--:--", "--:--", "--:--"];
    return [
      _formatTimestamp(messages.first.timestamp),
      _formatTimestamp(messages[messages.length ~/ 2].timestamp),
      _formatTimestamp(messages.last.timestamp),
    ];
  }

  double _maxY(Iterable<FlSpot> spots) {
    final highest = spots.map((spot) => spot.y).fold<double>(1, (a, b) {
      return a > b ? a : b;
    });
    return highest * 1.35;
  }

  double _spikePercent(List<FlSpot> spots) {
    final nonZero = spots.where((spot) => spot.y > 0).toList();
    if (nonZero.length < 2) return 0;
    final previous = nonZero[nonZero.length - 2].y;
    final current = nonZero.last.y;
    if (previous <= 0 || current <= previous) return 0;
    return ((current - previous) / previous) * 100;
  }

  String _formatFrequency(double value) {
    if (value >= 1000) {
      return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
    }
    if (value >= 100) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  String _formatTimestamp(double timestamp) {
    if (timestamp <= 0) return "--:--";
    final millis = timestamp > 1000000000000
        ? timestamp.toInt()
        : timestamp > 1000000000
        ? (timestamp * 1000).toInt()
        : null;
    if (millis == null) return "${timestamp.toStringAsFixed(1)}s";
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return "${_twoDigits(date.hour)}:${_twoDigits(date.minute)}:${_twoDigits(date.second)}";
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
