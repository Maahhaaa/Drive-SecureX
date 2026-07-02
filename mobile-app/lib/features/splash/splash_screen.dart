import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/features/onboarding/page_indactor.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Timer _stepTimer;

  final List<String> _steps = const [
    'INITIALIZING CORE',
    'SYNCING VEHICLE',
    'ENABLING SHIELD',
    'SYSTEM READY',
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.65, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) return;

      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
        return;
      }

      timer.cancel();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PageIndactor(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _stepTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      backgroundColor: AppColors.primaryblueColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _SplashBackdrop(),
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: _ScannerCorners(),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SizedBox(
                    width: 245.w,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      cacheWidth: 700,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 62.w,
              right: 62.w,
              bottom: 46.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2.h,
                      backgroundColor: const Color(0xff111a2a),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xff287cff),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      key: ValueKey(_currentStep),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentStep == _steps.length - 1
                              ? Icons.lock_outline
                              : Icons.sync,
                          color: const Color(0xff89a1ca),
                          size: 10.sp,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            _steps[_currentStep],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xff7d8dab),
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Color(0xff122a78), Color(0xff07111f), Color(0xff020409)],
          stops: [0, 0.48, 1],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScannerCornerPainter());
  }
}

class _ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff14223a)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const corner = 15.0;

    void drawCorner(Offset origin, bool right, bool bottom) {
      final horizontalEnd = origin + Offset(right ? -corner : corner, 0);
      final verticalEnd = origin + Offset(0, bottom ? -corner : corner);
      canvas.drawLine(origin, horizontalEnd, paint);
      canvas.drawLine(origin, verticalEnd, paint);
    }

    drawCorner(Offset.zero, false, false);
    drawCorner(Offset(size.width, 0), true, false);
    drawCorner(Offset(0, size.height), false, true);
    drawCorner(Offset(size.width, size.height), true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
