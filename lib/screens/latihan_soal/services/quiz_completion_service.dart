import 'package:flutter/material.dart';
import 'package:termodinamika_apps/services/cooldown_service.dart';
import 'package:termodinamika_apps/services/progress_tracking_service.dart';
import 'quiz_progress_service.dart';
import 'quiz_history_service.dart';

class QuizCompletionService {
  /// Handles quiz completion logic, including updating progress and saving cooldown
  static void handleQuizCompletion({
    required String? materiName,
    required int correctAnswers,
    required int totalQuestions,
    required List<Map<String, dynamic>> materiList,
    required Function(String materiName) recordQuizAttempt,
    required BuildContext context,
  }) {
    // Record the quiz attempt to start the 15-minute cooldown
    if (materiName != null) {
      DateTime cooldownEndTime = DateTime.now().add(
        Duration(minutes: 15),
      ); // 15 minutes from now
      CooldownService.saveCooldown(materiName, cooldownEndTime);

      // Record the quiz attempt in history
      QuizHistoryService.recordQuizAttempt(
        materiName: materiName,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
      );
    }

    double scorePercentage = (correctAnswers / totalQuestions) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing

    // If the quiz was passed, update the materi's isDoneMateri to true and quiz subMateri's isDone status
    if (isPassed && materiName != null) {
      // Mark the quiz as passed, which will update all related sub-materi as completed
      ProgressTrackingService.markQuizAsPassed(materiName);
    }

    // Clear the saved quiz progress as the quiz is completed
    if (materiName != null) {
      QuizProgressService.clearQuizProgressForMateri(materiName);
    }
  }
}