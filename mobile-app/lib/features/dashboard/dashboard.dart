import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gp/core/helper/images.dart';
import 'package:gp/core/services/can_service.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/theme/styles.dart';
import 'package:gp/features/dashboard/widgets/lastsalretcard.dart';
import 'package:gp/features/dashboard/widgets/messagefrequencycard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CANService _canService = CANService();

  bool _isScanning = false;
  bool _isConnected = false;
  bool _hasAttack = false;
  String? _blockedAttackKey;
  String? _activeAttackKey;
  String? _blockingAttackKey;
  CANStats? _stats;
  CANMessage? _latestMessage;
  List<CANMessage> _messages = [];
  List<CANMessage> _receivedMessages = [];

  StreamSubscription? _statsSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _receivedMessagesSubscription;
  StreamSubscription? _latestMessageSubscription;
  StreamSubscription? _connectedSubscription;

  @override
  void initState() {
    super.initState();
    _listenToCanApi();
  }

  void _listenToCanApi() {
    _connectedSubscription = _canService.connectedStream().listen((connected) {
      if (!mounted) return;
      setState(() => _isConnected = connected);
    });

    _statsSubscription = _canService.statsStream().listen((stats) {
      if (!mounted) return;
      setState(() => _stats = stats);
    });

    _messagesSubscription = _canService.messagesStream().listen((messages) {
      if (!mounted) return;
      setState(() => _messages = messages);
    });

    _receivedMessagesSubscription = _canService.receivedMessagesStream().listen(
      (messages) {
        if (!mounted) return;
        setState(() => _receivedMessages = messages);
      },
    );

    _latestMessageSubscription = _canService.latestMessageStream().listen((
      message,
    ) {
      if (!mounted || message == null) return;
      var shouldBlockAttack = false;
      final messageKey = _messageKey(message);
      setState(() {
        final isAttack = _isAttackMessage(message);
        _latestMessage = message;

        if (isAttack && messageKey != _blockedAttackKey) {
          _activeAttackKey = messageKey;
          _hasAttack = true;
          shouldBlockAttack = !_isScanning && _blockingAttackKey != messageKey;
        } else if (!isAttack) {
          _blockedAttackKey = null;
        }
      });

      if (shouldBlockAttack) {
        unawaited(_blockAttack(automatic: true, attackKey: messageKey));
      }
    });
  }

  Future<void> _blockAttack({bool automatic = false, String? attackKey}) async {
    if (_isScanning) return;

    final targetAttackKey = attackKey ?? _activeAttackKey;
    if (targetAttackKey == null) return;

    setState(() {
      _isScanning = true;
      _blockingAttackKey = targetAttackKey;
    });

    var blockSucceeded = false;
    try {
      await _canService.blockAttack();
      blockSucceeded = true;
      if (!mounted) return;
      setState(() {
        _blockedAttackKey = targetAttackKey;
        if (_activeAttackKey == targetAttackKey) {
          _activeAttackKey = null;
          _hasAttack = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            automatic ? 'System secured automatically' : 'System is secure',
          ),
          backgroundColor: AppColors.primarygreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Block attack failed: $e'),
            backgroundColor: AppColors.primaryred,
          ),
        );
      }
    } finally {
      if (mounted) {
        String? nextAttackKey;
        setState(() {
          _isScanning = false;
          _blockingAttackKey = null;
          if (_hasAttack &&
              _activeAttackKey != null &&
              _activeAttackKey != _blockedAttackKey &&
              blockSucceeded) {
            nextAttackKey = _activeAttackKey;
          }
        });
        if (nextAttackKey != null) {
          unawaited(_blockAttack(automatic: true, attackKey: nextAttackKey));
        }
      }
    }
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _receivedMessagesSubscription?.cancel();
    _latestMessageSubscription?.cancel();
    _connectedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _messages.where(_isAttackMessage).toList();
    final lastAlert = alerts.isNotEmpty ? alerts.last : null;
    final latestScanMessage =
        _latestMessage ?? (_messages.isNotEmpty ? _messages.last : null);

    return Scaffold(
      backgroundColor: AppColors.primaryblueColor,
      appBar: AppBar(
        toolbarHeight: 90.h,
        centerTitle: true,
        backgroundColor: AppColors.primaryblueColor,
        title: Text(
          "Vehicle Sentinel",
          style: Styles.inter18bold.copyWith(color: Colors.white),
        ),
        leading: const Icon(Icons.menu_rounded, color: Colors.white),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Center(
                child: Column(
                  children: [
                    _SystemStatusBadge(
                      isConnected: _isConnected,
                      hasAttack: _hasAttack,
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      !_isConnected
                          ? "Disconnected"
                          : _hasAttack
                          ? "Threat Detected"
                          : "Safe",
                      style: Styles.inter32bold.copyWith(color: Colors.white),
                    ),
                    Text(
                      "Last scan: ${_lastScanLabel(latestScanMessage)}",
                      style: Styles.inter14medium.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24.h),
                      child: SizedBox(
                        width: 167.w,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: _hasAttack && !_isScanning
                              ? () => unawaited(_blockAttack())
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryred,
                            foregroundColor: Colors.white,
                            // remove maximumSize entirely
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isScanning
                                  ? SizedBox(
                                      width: 17.w,
                                      height: 17.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Image.asset(
                                      Images.criticalicon,
                                      width: 17.w,
                                      height: 17.h,
                                      color: Colors.white,
                                      colorBlendMode: BlendMode.srcIn,
                                    ),
                              SizedBox(width: 8.w),
                              Text(
                                "Take Action",
                                style: Styles.inter16semi.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    MessageFrequencyCard(
                      frequency: _stats?.messageFrequency ?? 0,
                      messages: _receivedMessages,
                    ),
                    SizedBox(height: 20.h),
                    LastAlertCard(
                      time: lastAlert == null
                          ? "--"
                          : _formatTimestamp(lastAlert.timestamp),
                      alertTitle: lastAlert?.label ?? "No alerts",
                      onDetailsTap: () {},
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _lastScanLabel(CANMessage? message) {
    if (message == null) return "No data";
    final timestamp = message.timestamp;
    final time = _timestampToDateTime(timestamp);
    if (time == null) return "${timestamp.toStringAsFixed(1)}s";
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inDays < 1) return "${diff.inHours} hr ago";
    return "${diff.inDays} day ago";
  }

  bool _isAttackMessage(CANMessage message) {
    return message.label.toLowerCase() != 'normal';
  }

  String _messageKey(CANMessage message) {
    return '${message.timestamp}|${message.canId}|${message.label}';
  }

  String _formatTimestamp(double timestamp) {
    final date = _timestampToDateTime(timestamp);
    if (date == null) return "${timestamp.toStringAsFixed(1)}s";
    return "${_twoDigits(date.hour)}:${_twoDigits(date.minute)}";
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

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _SystemStatusBadge extends StatelessWidget {
  final bool isConnected;
  final bool hasAttack;

  const _SystemStatusBadge({
    required this.isConnected,
    required this.hasAttack,
  });

  @override
  Widget build(BuildContext context) {
    final color = !isConnected
        ? AppColors.greyColor
        : hasAttack
        ? AppColors.primaryred
        : AppColors.primarygreen;

    final label = !isConnected
        ? "API OFFLINE"
        : hasAttack
        ? "ALERT ACTIVE"
        : "SYSTEM SECURE";

    final deticon = !isConnected
        ? Images.offlineicon
        : hasAttack
        ? Images.criticalicon
        : Images.sysSecure;

    return Container(
      height: 45.h,
      width: 210.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9999.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.9.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            deticon,
            width: 14.w,
            height: 17.h,
            color: color,
            colorBlendMode: BlendMode.srcIn,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Styles.inter14medium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
