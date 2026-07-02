import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/theme/app_colors.dart';

class GlowEffect extends StatelessWidget {
  const GlowEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450.w,
      height: 380.h,
      decoration: BoxDecoration(
        color: AppColors.primaryblueColor,
        borderRadius: BorderRadius.circular(30.r),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.75.r,
          colors: [
            Color(0xFF1337EC).withValues(alpha: 0.1),
            Color.fromARGB(255, 19, 43, 164).withValues(alpha: 0.001),
            AppColors.primaryblueColor.withValues(alpha: 0.001),
            Color.fromARGB(255, 19, 43, 164).withValues(alpha: 0.001),
            Colors.white.withValues(alpha: .01),
          ],
          stops: [0.2, 5, 8,10,15],
        ),
      ),
    );
  }
}
