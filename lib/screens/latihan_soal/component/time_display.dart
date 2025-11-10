import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final int timeInSeconds;
  final VoidCallback onTimeOver;

  const TimeDisplay({
    Key? key,
    required this.timeInSeconds,
    required this.onTimeOver,
  }) : super(key: key);

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        formatTime(timeInSeconds),
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}