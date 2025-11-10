import 'package:flutter/material.dart';

class CountdownDisplay extends StatelessWidget {
  final int remainingCooldownTime;

  const CountdownDisplay({
    Key? key,
    required this.remainingCooldownTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        'Silahkan tunggu untuk mengambil soal latihan ulang: ${formatCountdownTime(remainingCooldownTime)}',
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 14,
          color: Colors.blue, // Blue text as requested
        ),
      ),
    );
  }

  String formatCountdownTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}