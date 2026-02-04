import 'dart:async';
import 'package:flutter/material.dart';
import 'package:termodinamika_apps/services/platform_storage_service.dart';
import 'components/question_display.dart';
import 'components/submit_button.dart';
import 'components/time_display.dart';
import 'components/loading_overlay.dart';
import 'services/quiz_progress_service.dart';
import 'services/timer_service.dart';
import 'services/api_service.dart';
import 'services/quiz_completion_service.dart';
import 'components/quiz_confirmation_handler.dart';
import 'components/answer_feedback_handler.dart';
import 'components/final_result_handler.dart';
import '../materi/components/materi_data.dart';

class LatihanSoalScreen extends StatefulWidget {
  final List<Map<String, dynamic>> soalList;
  final String? materiName;
  final Future<void> Function(String materiName)? recordQuizAttempt;

  const LatihanSoalScreen({super.key, required this.soalList, this.materiName, this.recordQuizAttempt});

  @override
  State<LatihanSoalScreen> createState() => _LatihanSoalScreenState();
}

class _LatihanSoalScreenState extends State<LatihanSoalScreen> {
  late String soalKategori;
  late int waktuDetik;
  late String isiSoal;
  late String jawabanSiswa = '';
  TimerService timerService = TimerService();
  bool isLoading = false;
  int incorrectAttempts = 0; // Track incorrect attempts
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the first question data and start timer after loading saved progress
    _loadAndStartTimer();
  }

  // Load saved progress and then start timer with the correct time
  Future<void> _loadAndStartTimer() async {
    // Set the first question data
    if (widget.soalList.isNotEmpty) {
      var currentSoal = widget.soalList[currentQuestionIndex];
      soalKategori =
          currentSoal['soalKategori'] ?? widget.materiName ?? 'Latihan Soal';
      int batasWaktu =
          currentSoal['batasWaktuPengerjaan'] ?? 180; // Default 3 minutes
      // Initially set waktuDetik to the question's time limit
      // This will be updated if there's saved progress
      waktuDetik = batasWaktu;
      isiSoal = currentSoal['isiSoal'] ?? '';
      _answerController.clear(); // Start with an empty answer field
    } else {
      soalKategori = widget.materiName ?? 'Latihan Soal';
      waktuDetik = 180;
      isiSoal = 'Tidak ada soal tersedia';
    }

    // Load saved progress if available
    await _loadSavedProgress();

    // Now that we've loaded the saved progress, update the UI
    // to reflect the correct time remaining
    setState(() {
      // The waktuDetik has already been updated in _loadSavedProgress
    });

    startTimer();
  }

  // Load saved quiz progress
  Future<void> _loadSavedProgress() async {
    if (widget.materiName != null) {
      Map<String, dynamic>? savedProgress = await StorageService.loadQuizProgress(widget.materiName!);
      if (savedProgress != null) {
        DateTime? expectedEndTime = savedProgress['_expectedEndTime'] != null
            ? DateTime.parse(savedProgress['_expectedEndTime'])
            : null;

        // Update state values without calling setState here
        currentQuestionIndex = savedProgress['currentQuestionIndex'] ?? currentQuestionIndex;
        jawabanSiswa = savedProgress['jawabanSiswa'] ?? jawabanSiswa;
        correctAnswers = savedProgress['correctAnswers'] ?? correctAnswers;
        incorrectAttempts = savedProgress['incorrectAttempts'] ?? incorrectAttempts;

        // Calculate remaining time based on expected end time
        if (expectedEndTime != null) {
          Duration timeUntilEnd = expectedEndTime.difference(DateTime.now());
          waktuDetik = timeUntilEnd.inSeconds;
          // Ensure time doesn't go negative
          if (waktuDetik < 0) {
            waktuDetik = 0; // Time has already passed, will trigger timeout immediately
          }
        } else {
          // Fallback to the saved time remaining if expected end time is not available
          waktuDetik = savedProgress['timeRemaining'] ?? waktuDetik;
        }

        // Update the current question data
        if (widget.soalList.isNotEmpty && currentQuestionIndex < widget.soalList.length) {
          var currentSoal = widget.soalList[currentQuestionIndex];
          isiSoal = currentSoal['isiSoal'] ?? '';
          soalKategori = currentSoal['soalKategori'] ?? widget.materiName ?? 'Latihan Soal';
          _answerController.text = jawabanSiswa;
        }
      }
    }
  }

  // Save current quiz progress
  void _saveProgress() async {
    await QuizProgressService.saveQuizProgress(
      materiName: widget.materiName ?? '',
      currentQuestionIndex: currentQuestionIndex,
      timeRemaining: waktuDetik,
      jawabanSiswa: jawabanSiswa,
      correctAnswers: correctAnswers,
      incorrectAttempts: incorrectAttempts,
    );
  }

  void startTimer() {
    timerService.startTimer(
      initialTime: waktuDetik,
      onTick: (remainingTime) {
        setState(() {
          waktuDetik = remainingTime;
        });
        // Save progress every second to ensure accurate time tracking
        _saveProgress();
      },
      onTimeOver: () {
        // Timer ended, handle timeout by automatically submitting with "Siswa tidak menjawab apapun"
        jawabanSiswa = 'Siswa tidak menjawab apapun';
        _answerController.text = jawabanSiswa; // Update controller as well
        _submitAnswer();
      },
    );
  }

  @override
  void dispose() {
    timerService.cancelTimer();
    _answerController.dispose();
    // Only save progress if the quiz is not completed (not at the last question or beyond)
    // currentQuestionIndex starts at 0, so if it equals the length, the quiz is completed
    if (currentQuestionIndex < widget.soalList.length - 1) {
      // Save progress on dispose to ensure data is preserved if the app is closed
      _saveProgress();
    }
    super.dispose();
  }

  void _showConfirmationModal() {
    QuizConfirmationHandler.showConfirmationModal(
      context: context,
      answerText: _answerController.text,
      onConfirm: _submitAnswer,
    );
  }

  void _submitAnswer() async {
    // Stop the timer when submitting an answer
    timerService.cancelTimer();

    setState(() {
      isLoading = true;
    });

    try {
      var currentSoal = widget.soalList[currentQuestionIndex];

      // Call the API service
      Map<String, dynamic> result = await ApiService.submitAnswer(
        apiKey: 'AIzaSyAu8KLDdPzccOqSzZjRC6OyopIe7pSuGtk',
        question: isiSoal,
        answerKey: currentSoal['kunciJawaban'] ?? '',
        studentAnswer: jawabanSiswa,
      );

      bool isCorrect = result['correctAnswer'] ?? false;
      String explain = result['explain'] ?? '';

      // Update correct answers count
      if (isCorrect) {
        setState(() {
          correctAnswers++;
        });
      } else {
        // If incorrect, increment the counter
        setState(() {
          incorrectAttempts++;
        });
      }

      // Only save progress if this is not the last question
      // For the last question, we don't want to save progress as it will be cleared after quiz completion
      if (currentQuestionIndex < widget.soalList.length - 1) {
        _saveProgress();
      }

      // Show result modal
      _showAnswerFeedbackModal(explain, isCorrect);
    } catch (e) {
      // Handle error
      debugPrint('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi Error, silahkan kirim jawaban lagi')),
      );
      // Restart timer in case of error with the current time remaining
      startTimer();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAnswerFeedbackModal(String explanation, bool isCorrect) {
    AnswerFeedbackHandler.showAnswerFeedbackModal(
      context: context,
      isCorrect: isCorrect,
      explanation: explanation,
      onContinue: () {
        // Move to next question or finish quiz
        if (currentQuestionIndex < widget.soalList.length - 1) {
          // Move to next question
          setState(() {
            currentQuestionIndex++;
            var nextSoal = widget.soalList[currentQuestionIndex];
            isiSoal = nextSoal['isiSoal'] ?? '';
            jawabanSiswa = '';

            // Reset timer for the new question
            int batasWaktu = nextSoal['batasWaktuPengerjaan'] ?? 180;
            waktuDetik = batasWaktu;
          });

          // Clear the answer text field for the next question
          _answerController.clear();

          // Save progress for the new question
          _saveProgress();

          // Restart the timer for the next question with the new time
          startTimer();
        } else {
          // All questions answered, show final results
          // Don't save progress here as we're about to clear it in _showFinalResult anyway
          _showFinalResult();
        }
      },
    );
  }

  void _showFinalResult() {
    QuizCompletionService.handleQuizCompletion(
      materiName: widget.materiName,
      correctAnswers: correctAnswers,
      totalQuestions: widget.soalList.length,
      materiList: dataMateri,
      recordQuizAttempt: (materiName) => widget.recordQuizAttempt!(materiName),
      context: context,
    );

    FinalResultHandler.showFinalResultModal(
      context: context,
      correctAnswers: correctAnswers,
      totalQuestions: widget.soalList.length,
      onFinished: () async {
        widget.recordQuizAttempt!(widget.materiName!);
        // Refresh the quiz history after completing the quiz

        // Clear the saved progress when quiz is completed so user starts from beginning when retaking
        await _clearSavedProgress();

        Navigator.of(context).pop(); // Close modal
      },
    );
  }

  // Clear saved quiz progress
  Future<void> _clearSavedProgress() async {
    if (widget.materiName != null) {
      await StorageService.clearQuizProgressForMateri(widget.materiName!);
    }
  }

  // Helper method to get image URL for specific questions
  String? _getImageUrlForQuestion(int questionIndex) {
    // For the 9th question (index 8), return the PV graph image
    if (questionIndex == 8) {
      // Check if the question is the one about PV graph
      if (widget.soalList.length > 8) {
        String questionText = widget.soalList[8]['isiSoal'] ?? '';
        if (questionText.contains('Perhatikan grafik PV (isotermal). Analisis mengapa kurva berbentuk hiperbola!')) {
          // Return the path to the PV graph image
          // Using an existing image that might represent a PV diagram
          return 'assets/images/Aspose.Words.80cb3db8-0c0b-47fa-b3da-9e97ba6eb5fa.001.png';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: PopScope(
        canPop: false, // Prevent default back button behavior
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return; // If the default behavior already popped the route, return
          }
          await _loadSavedProgress();
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Color(0xFFFAFAFA), // White/Off-White background
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A237E), // Deep Indigo
                    Color(0xFF1A237E).withValues(alpha: 0.9), // Slightly lighter Deep Indigo
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await _loadSavedProgress();
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Soal ${currentQuestionIndex + 1}/${widget.soalList.length}',
                            style: const TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          TimeDisplay(
                            timeInSeconds: waktuDetik,
                            onTimeOver: () {}, // This is handled in the timer logic
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA), // White/Off-White background
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Soal essay
                  QuestionDisplay(
                    questionText: isiSoal,
                    answerText: _answerController.text,
                    onAnswerChanged: (value) {
                      setState(() {
                        jawabanSiswa = value;
                      });
                    },
                    controller: _answerController,
                    // Add image for the 9th question about PV graph
                    imageUrl: _getImageUrlForQuestion(currentQuestionIndex),
                  ),
                  const SizedBox(height: 24),
                  // Submit button
                  SubmitButton(onSubmit: _showConfirmationModal, isLoading: isLoading),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
