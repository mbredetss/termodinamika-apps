import 'package:flutter/material.dart';

class CountdownDisplay extends StatelessWidget {
  final int remainingCooldownTime;

  const CountdownDisplay({
    super.key,
    required this.remainingCooldownTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light grey background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF303F9F), // Deep Indigo border
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Color(0xFF303F9F), // Deep Indigo color
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Silahkan tunggu untuk mengambil soal latihan ulang: ${formatCountdownTime(remainingCooldownTime)}',
              style: const TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 14,
                color: Color(0xFF303F9F), // Deep Indigo color
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatCountdownTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}