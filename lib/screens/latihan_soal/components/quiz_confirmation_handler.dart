import 'package:flutter/material.dart';
import 'confirmation_modal.dart';
import '../services/answer_validation_service.dart';

class QuizConfirmationHandler {
  /// Shows a confirmation modal before submitting the answer
  static Future<void> showConfirmationModal({
    required BuildContext context,
    required String answerText,  // Add the answer text as a parameter
    required VoidCallback onConfirm,
  }) async {
    // Check if the answer field is empty
    if (!AnswerValidationService.isAnswerValid(answerText)) {
      // Show warning message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AnswerValidationService.getEmptyAnswerErrorMessage()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show confirmation modal
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationModal(
          title: 'Konfirmasi',
          content: 'Apakah Anda yakin mengirim jawaban?',
          onConfirm: () {
            Navigator.of(context).pop(); // Close the confirmation modal
            onConfirm(); // Execute the confirm action
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the confirmation modal
          },
        );
      },
    );
  }
}