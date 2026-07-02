import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/services/can_service.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/theme/styles.dart';
import 'package:gp/features/alrets/widget/alretcard.dart';

class Alrets extends StatefulWidget {
  const Alrets({super.key});

  @override
  State<Alrets> createState() => _AlretsState();
}

class _AlretsState extends State<Alrets> {
  final List<String> _filters = ["All", "Critical", "Warnings", "Info"];
  final CANService _canService = CANService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryblueColor,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 110.h,
        backgroundColor: AppColors.medDarkblueColor,
        title: Text(
          "Alerts",
          style: Styles.inter18bold.copyWith(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(52.h),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, bottom: 18.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_filters.length, (index) {
                  final bool isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryblueColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondaryblueColor
                              : AppColors.greyColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: Styles.inter14medium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.greyColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<CANMessage>>(
        stream: _canService.alertsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = (snapshot.data ?? [])
              .reversed
              .where(_matchesFilter)
              .toList();

          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      "LATEST",
                      style: Styles.inter16semi.copyWith(
                        color: AppColors.greyColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (alerts.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: Center(
                          child: Text(
                            "No alerts found",
                            style: Styles.inter14medium.copyWith(
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                    else
                      ...alerts.map(
                        (alert) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: AlertCard(
                            severity: _severityFor(alert),
                            title: _titleFor(alert),
                            description: _descriptionFor(alert),
                            timeAgo: _timeLabel(alert.timestamp),
                            onTap: () {},
                          ),
                        ),
                      ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(CANMessage message) {
    final severity = _severityFor(message);
    return switch (_selectedIndex) {
      1 => severity == AlertSeverity.critical,
      2 => severity == AlertSeverity.warning,
      3 => severity == AlertSeverity.info,
      _ => true,
    };
  }

  AlertSeverity _severityFor(CANMessage message) {
    final label = message.label.toLowerCase();
    if (label.contains('dos') ||
        label.contains('flood') ||
        label.contains('attack') ||
        label.contains('critical')) {
      return AlertSeverity.critical;
    }
    if (label.contains('info')) return AlertSeverity.info;
    return AlertSeverity.warning;
  }

  String _titleFor(CANMessage message) {
    final label = message.label.trim();
    if (label.isEmpty) return "CAN Alert";
    return label
        .split(RegExp(r'[_\s-]+'))
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _descriptionFor(CANMessage message) {
    return "Attack detected in CAN message ID ${message.canId}.";
  }

  String _timeLabel(double timestamp) {
    final date = _timestampToDateTime(timestamp);
    if (date == null) return "${timestamp.toStringAsFixed(1)}s";
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inDays < 1) return "${diff.inHours} hr ago";
    return "${diff.inDays} day ago";
  }

  DateTime? _timestampToDateTime(double timestamp) {
    if (timestamp <= 0) return null;
    if (timestamp > 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }
    if (timestamp > 1000000000) {
      return DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    }
    return null;
  }
}
