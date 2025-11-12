import 'package:flutter/material.dart';
import '../component/answer_modal.dart';

class AnswerFeedbackHandler {
  /// Shows the answer feedback modal with explanation
  static Future<void> showAnswerFeedbackModal({
    required BuildContext context,
    required bool isCorrect,
    required String explanation,
    required VoidCallback onContinue,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by clicking outside
      builder: (BuildContext context) {
        return AnswerModal(
          isCorrect: isCorrect,
          explanation: explanation,
          onContinue: () {
            Navigator.of(context).pop(); // Close modal
            onContinue(); // Execute the continue action
          },
        );
      },
    );
  }
}