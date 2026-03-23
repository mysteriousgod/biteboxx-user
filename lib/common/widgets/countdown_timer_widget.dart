import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:get/get.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime startTime;
  final int durationMinutes;
  final TextStyle? textStyle;
  final bool showMessageOnTimeUp;
  final String? messageOnTimeUp;

  const CountdownTimerWidget({
    super.key,
    required this.startTime,
    required this.durationMinutes,
    this.textStyle,
    this.showMessageOnTimeUp = true,
    this.messageOnTimeUp,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Calculate end time: StartTime + Duration (e.g. 35 mins)
    DateTime endTime =
        widget.startTime.add(Duration(minutes: widget.durationMinutes));

    _calculateRemainingTime(endTime);

    // Tick every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemainingTime(endTime);
    });
  }

  void _calculateRemainingTime(DateTime endTime) {
    if (!mounted) return;

    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative || difference.inSeconds <= 0) {
      setState(() {
        _remainingSeconds = 0;
        _isTimeUp = true;
      });
      _timer?.cancel();
    } else {
      setState(() {
        _remainingSeconds = difference.inSeconds;
        _isTimeUp = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Logic to show message when time is up
    if (_isTimeUp) {
      if (!widget.showMessageOnTimeUp) {
        // Don't show anything when time expires
        return const SizedBox.shrink();
      }
      
      final message = widget.messageOnTimeUp ?? 'your_order_is_arriving_soon'.tr;
      
      return Text(
        message,
        style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).primaryColor),
        textAlign: TextAlign.center,
      );
    }

    // Show Countdown
    return Text(
      _formattedTime,
      style: widget.textStyle ?? const TextStyle(fontSize: 16),
      textDirection: TextDirection.ltr,
    );
  }
}
