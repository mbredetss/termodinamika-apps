import 'package:flutter/material.dart';
import 'final_result_modal.dart';

class FinalResultHandler {
  /// Shows the final result modal at the end of the quiz
  static Future<void> showFinalResultModal({
    required BuildContext context,
    required int correctAnswers,
    required int totalQuestions,
    required VoidCallback onFinished,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by clicking outside
      builder: (BuildContext context) {
        return FinalResultModal(
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          onFinished: () {
            Navigator.of(context).pop(); // Close modal
            onFinished(); // Execute the finished action
          },
        );
      },
    );
  }
}