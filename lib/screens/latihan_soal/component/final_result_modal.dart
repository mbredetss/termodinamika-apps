import 'package:flutter/material.dart';

class FinalResultModal extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onFinished;

  const FinalResultModal({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scorePercentage = (correctAnswers / totalQuestions) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(
        isPassed ? 'Selamat! 🎉' : 'Perlu Belajar Lagi 😢',
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Anda telah menyelesaikan kuis dengan skor:',
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correctAnswers/$totalQuestions (${scorePercentage.toStringAsFixed(1)}%)',
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isPassed
              ? 'Anda dinyatakan lulus. Pengetahuan Anda tentang materi ini sudah cukup baik.'
              : 'Anda belum mencapai skor minimum. Silakan pelajari kembali materi sebelumnya.',
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onFinished,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}