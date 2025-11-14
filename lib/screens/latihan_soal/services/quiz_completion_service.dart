import 'package:flutter/material.dart';
import 'package:termodinamika_apps/services/cooldown_service.dart';
import 'package:termodinamika_apps/services/platform_storage_service.dart';
import 'quiz_progress_service.dart';

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
    }

    double scorePercentage = (correctAnswers / totalQuestions) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing

    // If the quiz was passed, update the materi's isDoneMateri to true and quiz subMateri's isDone status
    if (isPassed && materiName != null) {
      for (var materi in materiList) {
        if (materi['namaMateri'] == materiName) {
          // Update the materi's completion status
          materi['isDoneMateri'] = true;

          // Find and update the quiz subMateri's isDone status
          var subMateriList = materi['subMateri'] as List;
          for (int i = 0; i < subMateriList.length; i++) {
            var subMateri = subMateriList[i];
            String subMateriName = subMateri['nama'] as String;

            // Update isDone status for the quiz/latihan soal subMateri
            if (subMateriName.toLowerCase().contains('latihan soal') ||
                subMateriName.toLowerCase().contains('ujian')) {
              subMateriList[i]['isDone'] = true;
              break; // Exit after updating the quiz subMateri
            }
          }

          break;
        }
      }

      // Save the updated progress
      StorageService.saveProgress(materiList);
    }

    // Clear the saved quiz progress as the quiz is completed
    if (materiName != null) {
      QuizProgressService.clearQuizProgressForMateri(materiName);
    }
  }
}