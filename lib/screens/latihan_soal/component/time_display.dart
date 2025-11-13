import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final int timeInSeconds;
  final VoidCallback onTimeOver;

  const TimeDisplay({
    super.key,
    required this.timeInSeconds,
    required this.onTimeOver,
  });

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isLowTime = timeInSeconds <= 30; // Red color when time is 30 seconds or less
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF1A237E), // Deep Indigo background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowTime ? Color(0xFFD50000) : Color(0xFF651FFF), // Red when time is low, Electric Violet otherwise
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: isLowTime ? Color(0xFFD50000) : Colors.white, // Red when time is low, White otherwise
          ),
          const SizedBox(width: 4),
          Text(
            formatTime(timeInSeconds),
            style: TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLowTime ? Color(0xFFD50000) : Colors.white, // Red when time is low, White otherwise
            ),
          ),
        ],
      ),
    );
  }
}