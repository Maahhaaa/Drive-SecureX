import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/helper/images.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/theme/styles.dart';

enum AlertSeverity { critical, warning, info }

class AlertCard extends StatelessWidget {
  final AlertSeverity severity;
  final String title;
  final String description;
  final String timeAgo;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.severity,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.onTap,
  });

  Color get _severityColor => switch (severity) {
    AlertSeverity.critical => AppColors.primaryred,
    AlertSeverity.warning => AppColors.primaryorange,
    AlertSeverity.info => AppColors.primarygreen,
  };

  String get _severityLabel => switch (severity) {
    AlertSeverity.critical => "CRITICAL",
    AlertSeverity.warning => "WARNING",
    AlertSeverity.info => "INFO",
  };

  String get _severityIcon => switch (severity) {
    AlertSeverity.critical => Images.criticalicon,
    AlertSeverity.warning => Images.warningicon,
    AlertSeverity.info => Images.infoicon,
  };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:360.w,
        height: 145.h,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.medDarkblueColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: _severityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Image.asset(
                    _severityIcon,
                    color: _severityColor,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + time row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: _severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _severityLabel,
                          style: Styles.inter18bold.copyWith(
                            color: _severityColor,
                            letterSpacing: 0.8,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timeAgo,
                        style: Styles.inter12regular.copyWith(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Title
                  Text(
                    title,
                    style:Styles.inter18bold.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ) ,
                  ),

                  SizedBox(height: 4.h),

                  // Description
                  Text(
                    description,
                    style: Styles.inter12regular.copyWith(
                      color: AppColors.greyColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Arrow
            Icon(Icons.chevron_right, color: AppColors.greyColor, size: 20.r),
          ],
        ),
      ),
    );
  }
}
