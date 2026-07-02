import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/theme/app_colors.dart';

class LastAlertCard extends StatelessWidget {
  final String time;
  final String alertTitle;
  final VoidCallback? onDetailsTap;

  const LastAlertCard({
    super.key,
    this.time = "--",
    this.alertTitle = "No alerts",
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.medDarkblueColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          // Warning icon circle
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: AppColors.primaryorange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryorange,
              size: 22.r,
            ),
          ),

          SizedBox(width: 12.w),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Last Alert",
                      style: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      " • ",
                      style: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  alertTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Details button
          GestureDetector(
            onTap: onDetailsTap,
            child: Text(
              "Details",
              style: TextStyle(
                color: AppColors.secondaryblueColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
