import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/helper/images.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/theme/styles.dart';
import 'package:gp/features/navbar/bottom_nav_bar.dart';

class OnboardAppBar extends StatelessWidget {
  const OnboardAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryblueColor,
      toolbarHeight: 63.h,
      title: Padding(
        padding: EdgeInsets.only(left: 110.w),
        child: Row(
          children: [
            Image.asset(Images.secureIcon, width: 16.w, height: 20.h),
            SizedBox(width: 7.w),
            Text(
              "DriveSecureX",
              style: Styles.inter18bold.copyWith(color:Colors.white),
            ),
          ],
        ),
      ),
      // centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 19.w),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => BottomNavBar()));
              },
            child: Text(
              "Skip",
              style: Styles.inter14medium.copyWith(color: Color(0xff9CA3AF)),
            ),
          ),
        ),
      ],
    );
  }
}
