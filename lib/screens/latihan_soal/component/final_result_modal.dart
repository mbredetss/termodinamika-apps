import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:getwidget/getwidget.dart';

class FinalResultModal extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onFinished;

  const FinalResultModal({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    double scorePercentage = (correctAnswers / totalQuestions) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              child: Lottie.asset(
                isPassed 
                  ? 'assets/animations/Success.json' 
                  : 'assets/animations/Error animation.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPassed ? 'Selamat! 🎉' : 'Perlu Belajar Lagi 😢',
              style: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isPassed 
                  ? Color(0xFF00C853) // Bright Green
                  : Color(0xFFD50000), // Warning Red
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda telah menyelesaikan kuis dengan skor:',
              style: const TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 16,
                color: Color(0xFF212121), // Dark Grey
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA), // White/Off-White background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPassed 
                    ? Color(0xFF00C853) // Bright Green
                    : Color(0xFFD50000), // Warning Red
                  width: 1,
                ),
              ),
              child: Text(
                '$correctAnswers/$totalQuestions (${scorePercentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isPassed 
                    ? Color(0xFF00C853) // Bright Green
                    : Color(0xFFD50000), // Warning Red
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPassed
                ? 'Anda dinyatakan lulus. Pengetahuan Anda tentang materi ini sudah cukup baik.'
                : 'Anda belum mencapai skor minimum. Silakan pelajari kembali materi sebelumnya.',
              style: const TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 16,
                color: Color(0xFF212121), // Dark Grey
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: GFButton(
              onPressed: onFinished,
              text: 'Selesai',
              textStyle: const TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              color: Color(0xFFFF6D00), // Energetic Orange
              shape: GFButtonShape.pills,
              fullWidthButton: true,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}