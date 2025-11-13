import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:getwidget/getwidget.dart';

class AnswerModal extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final VoidCallback onContinue;

  const AnswerModal({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
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
            // Lottie animation based on correctness
            Container(
              height: 120,
              child: Lottie.asset(
                isCorrect 
                  ? 'assets/animations/Success.json' 
                  : 'assets/animations/Error animation.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect ? 'Jawaban Benar!' : 'Jawaban Salah!',
              style: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCorrect 
                  ? Color(0xFF00C853) // Bright Green
                  : Color(0xFFD50000), // Warning Red
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA), // White/Off-White background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect 
                    ? Color(0xFF00C853) // Bright Green
                    : Color(0xFFD50000), // Warning Red
                  width: 1,
                ),
              ),
              child: Text(
                explanation,
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                  color: Color(0xFF212121), // Dark Grey
                ),
              ),
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
              onPressed: onContinue,
              text: 'Lanjut',
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