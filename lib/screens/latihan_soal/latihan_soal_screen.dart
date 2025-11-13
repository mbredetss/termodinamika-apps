import 'dart:async';
import 'package:flutter/material.dart';
import 'package:termodinamika_apps/services/storage_service.dart';
import 'component/question_display.dart';
import 'component/submit_button.dart';
import 'component/time_display.dart';
import 'component/loading_overlay.dart';
import 'services/quiz_progress_service.dart';
import 'services/timer_service.dart';
import 'services/api_service.dart';
import 'services/quiz_completion_service.dart';
import 'component/quiz_confirmation_handler.dart';
import 'component/answer_feedback_handler.dart';
import 'component/final_result_handler.dart';
import '../materi/component/materi_data.dart';

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
    // Save progress on dispose to ensure data is preserved if the app is closed
    _saveProgress();
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

      // Save progress after submitting an answer
      _saveProgress();

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
      onFinished: () {
        Navigator.of(context).pop(); // Close modal
      },
    );
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
                    Color(0xFF1A237E).withOpacity(0.9), // Slightly lighter Deep Indigo
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
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
                      Container(
                        child: Row(
                          children: [
                            TimeDisplay(
                              timeInSeconds: waktuDetik,
                              onTimeOver: () {}, // This is handled in the timer logic
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        ),
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
                  ),
                  const SizedBox(height: 24),
                  // Submit button
                  SubmitButton(onSubmit: _showConfirmationModal, isLoading: isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
