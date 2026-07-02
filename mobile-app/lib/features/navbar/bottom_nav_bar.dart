import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/helper/images.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/features/alrets/alrets.dart';
import 'package:gp/features/dashboard/dashboard.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  Widget activeIcon(String path) => Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: SizedBox(
      width: 21.w,
      height: 21.h,
      child: Image.asset(
        path,
        color: AppColors.secondaryblueColor,
        colorBlendMode: BlendMode.srcIn,
      ),
    ),
  );

  Widget inactiveIcon(String path) => SizedBox(
    width: 21.w,
    height: 21.h,
    child: Image.asset(
      path,
      color: AppColors.greyColor,
      colorBlendMode: BlendMode.srcIn,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      backgroundColor: AppColors.medDarkblueColor,
      navBarOverlap: const NavBarOverlap.none(),
      tabs: [
        PersistentTabConfig(
          screen: Dashboard(),
          item: ItemConfig(
            icon: activeIcon(Images.dashboard),
            inactiveIcon: inactiveIcon(Images.dashboard),
            title: "Dashboard",
            activeForegroundColor: AppColors.secondaryblueColor,
            inactiveForegroundColor: AppColors.greyColor,
          ),
        ),
        PersistentTabConfig(
          screen: Alrets(),
          item: ItemConfig(
            icon: activeIcon(Images.alrets),
            inactiveIcon: inactiveIcon(Images.alrets),
            title: "Alert",
            activeForegroundColor: AppColors.secondaryblueColor,
            inactiveForegroundColor: AppColors.greyColor,
          ),
        ),
        PersistentTabConfig(
          screen: Container(),
          item: ItemConfig(
            icon: activeIcon(Images.vehicles),
            inactiveIcon: inactiveIcon(Images.vehicles),
            title: "Vehicles",
            activeForegroundColor: AppColors.secondaryblueColor,
            inactiveForegroundColor: AppColors.greyColor,
          ),
        ),
        PersistentTabConfig(
          screen: Container(),
          item: ItemConfig(
            icon: activeIcon(Images.settings),
            inactiveIcon: inactiveIcon(Images.settings),
            title: "Settings",
            activeForegroundColor: AppColors.secondaryblueColor,
            inactiveForegroundColor: AppColors.greyColor,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style7BottomNavBar(
        navBarConfig: navBarConfig,
        height: 88.h,
        navBarDecoration: NavBarDecoration(
          color: AppColors.medDarkblueColor,
          padding: EdgeInsets.only(top:12.h ,bottom: 20.h ,right: 20.w ,left: 20.w),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.2),
              blurRadius: 1,
              spreadRadius: 0.5,
              offset: const Offset(0, -0.06),
            ),
          ],
        ),
      ),
    );
  }
}
