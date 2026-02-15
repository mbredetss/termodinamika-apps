import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:termodinamika_apps/services/cooldown_service.dart';
import 'package:termodinamika_apps/services/progress_tracking_service.dart';
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
  }) async {
    // Record the quiz attempt to start the 15-minute cooldown
    if (materiName != null) {
      DateTime cooldownEndTime = DateTime.now().add(
        Duration(minutes: 15),
      ); // 15 minutes from now
      CooldownService.saveCooldown(materiName, cooldownEndTime);

      // Record the quiz attempt in Firestore
      await _recordQuizAttemptToFirestore(
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
      
      // Update user's isCompleted status in Firestore
      await _updateUserCompletionStatus(isPassed);
    }

    // Clear the saved quiz progress as the quiz is completed
    if (materiName != null) {
      QuizProgressService.clearQuizProgressForMateri(materiName);
    }
  }
  
  /// Updates the user's isCompleted status in Firestore
  static Future<void> _updateUserCompletionStatus(bool isPassed) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'isCompleted': isPassed,
        });
      }
    } catch (e) {
      print('Error updating user completion status: $e');
    }
  }
  
  /// Records the quiz attempt to Firestore
  static Future<void> _recordQuizAttemptToFirestore({
    required String materiName,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Add to user's quiz history subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quizHistory')
            .add({
          'materiName': materiName,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'date': FieldValue.serverTimestamp(),
          'isPassed': (correctAnswers / totalQuestions) >= 0.8,
          'percentage': (correctAnswers / totalQuestions) * 100,
        });
      }
    } catch (e) {
      print('Error recording quiz attempt to Firestore: $e');
    }
  }
}