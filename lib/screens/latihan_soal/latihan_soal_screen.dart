import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/prompting.dart';
import 'component/answer_modal.dart';
import 'component/confirmation_modal.dart';
import 'component/final_result_modal.dart';
import 'component/question_display.dart';
import 'component/submit_button.dart';
import 'component/time_display.dart';
import 'service/answer_validation_service.dart';
import '../materi/component/materi_data.dart';
import '../../services/storage_service.dart';
import '../../services/cooldown_service.dart';

class LatihanSoalScreen extends StatefulWidget {
  final List<Map<String, dynamic>> soalList;
  final String? materiName;
  final Future<void> Function(String materiName)? recordQuizAttempt;

  const LatihanSoalScreen({
    super.key,
    required this.soalList,
    this.materiName,
    this.recordQuizAttempt,
  });

  @override
  State<LatihanSoalScreen> createState() => _LatihanSoalScreenState();
}

class _LatihanSoalScreenState extends State<LatihanSoalScreen> {
  late String soalKategori;
  late int waktuDetik;
  late String isiSoal;
  late String jawabanSiswa = '';
  late Timer? timer;
  bool isLoading = false;
  int incorrectAttempts = 0; // Track incorrect attempts
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the first question data
    if (widget.soalList.isNotEmpty) {
      var currentSoal = widget.soalList[currentQuestionIndex];
      soalKategori =
          currentSoal['soalKategori'] ?? widget.materiName ?? 'Latihan Soal';
      int batasWaktu =
          currentSoal['batasWaktuPengerjaan'] ?? 180; // Default 3 minutes
      waktuDetik = batasWaktu;
      isiSoal = currentSoal['isiSoal'] ?? '';
      _answerController.clear(); // Start with an empty answer field
    } else {
      soalKategori = widget.materiName ?? 'Latihan Soal';
      waktuDetik = 180;
      isiSoal = 'Tidak ada soal tersedia';
    }

    // Load saved progress if available
    _loadSavedProgress();

    startTimer();
  }

  // Load saved quiz progress
  void _loadSavedProgress() async {
    if (widget.materiName != null) {
      Map<String, dynamic>? savedProgress =
          await StorageService.loadQuizProgress(widget.materiName!);
      if (savedProgress != null) {
        DateTime? expectedEndTime = savedProgress['_expectedEndTime'] != null
            ? DateTime.parse(savedProgress['_expectedEndTime'])
            : null;

        setState(() {
          currentQuestionIndex =
              savedProgress['currentQuestionIndex'] ?? currentQuestionIndex;
          jawabanSiswa = savedProgress['jawabanSiswa'] ?? jawabanSiswa;
          correctAnswers = savedProgress['correctAnswers'] ?? correctAnswers;
          incorrectAttempts =
              savedProgress['incorrectAttempts'] ?? incorrectAttempts;
        });

        // Calculate remaining time based on expected end time
        if (expectedEndTime != null) {
          Duration timeUntilEnd = expectedEndTime.difference(DateTime.now());
          waktuDetik = timeUntilEnd.inSeconds;
          // Ensure time doesn't go negative
          if (waktuDetik < 0) {
            waktuDetik =
                0; // Time has already passed, will trigger timeout immediately
          }
        } else {
          // Fallback to the saved time remaining if expected end time is not available
          waktuDetik = savedProgress['timeRemaining'] ?? waktuDetik;
        }

        // Update the current question data
        if (widget.soalList.isNotEmpty &&
            currentQuestionIndex < widget.soalList.length) {
          var currentSoal = widget.soalList[currentQuestionIndex];
          isiSoal = currentSoal['isiSoal'] ?? '';
          soalKategori =
              currentSoal['soalKategori'] ??
              widget.materiName ??
              'Latihan Soal';
          _answerController.text = jawabanSiswa;
        }
      }
    }
  }

  // Save current quiz progress
  void _saveProgress() async {
    if (widget.materiName != null) {
      Map<String, dynamic> quizProgress = {
        'currentQuestionIndex': currentQuestionIndex,
        'timeRemaining': waktuDetik,
        'jawabanSiswa': jawabanSiswa,
        'correctAnswers': correctAnswers,
        'incorrectAttempts': incorrectAttempts,
        '_expectedEndTime': DateTime.now()
            .add(Duration(seconds: waktuDetik))
            .toIso8601String(),
      };

      await StorageService.saveQuizProgress(widget.materiName!, quizProgress);
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waktuDetik > 0) {
        setState(() {
          waktuDetik--;
        });
        // Save progress every second to ensure accurate time tracking
        _saveProgress();
      } else {
        // Timer ended, handle timeout by automatically submitting with "Siswa tidak menjawab apapun"
        timer.cancel();
        jawabanSiswa = 'Siswa tidak menjawab apapun';
        _answerController.text = jawabanSiswa; // Update controller as well
        kirimJawaban();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  String formatWaktu(int detik) {
    int menit = detik ~/ 60;
    int sisaDetik = detik % 60;
    return '${menit.toString().padLeft(2, '0')}:${sisaDetik.toString().padLeft(2, '0')}';
  }

  void _showConfirmationModal() {
    // Check if the answer field is empty
    if (!AnswerValidationService.isAnswerValid(_answerController.text)) {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationModal(
          title: 'Konfirmasi',
          content: 'Apakah Anda yakin mengirim jawaban?',
          onConfirm: () {
            Navigator.of(context).pop(); // Close the confirmation modal
            kirimJawaban();
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the confirmation modal
          },
        );
      },
    );
  }

  void kirimJawaban() async {
    // Stop the timer when submitting an answer
    timer?.cancel();

    setState(() {
      isLoading = true;
    });

    try {
      var currentSoal = widget.soalList[currentQuestionIndex];

      // Call the prompting function
      Map<String, dynamic> result = {
        'correctAnswer': true, 
        'explain': 'anjay!', 
      };

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
      showCorrectAnswerModal(explain, isCorrect);
    } catch (e) {
      // Handle error
      debugPrint('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi Error, silahkan kirim jawaban lagi')),
      );
      // Restart timer in case of error
      startTimer();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCorrectAnswerModal(String explanation, bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by clicking outside
      builder: (BuildContext context) {
        return AnswerModal(
          isCorrect: isCorrect,
          explanation: explanation,
          onContinue: () {
            Navigator.of(context).pop(); // Close modal

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

              // Restart the timer for the next question
              startTimer();
            } else {
              // All questions answered, show final results
              showFinalResult();
            }
          },
        );
      },
    );
  }

  void showFinalResult() {
    // Record the quiz attempt to start the 15-minute cooldown (always done when finishing the quiz)
    if (widget.materiName != null) {
      DateTime cooldownEndTime = DateTime.now().add(
        Duration(minutes: 15),
      ); // 15 minutes from now
      CooldownService.saveCooldown(widget.materiName!, cooldownEndTime);
    }

    double scorePercentage = (correctAnswers / widget.soalList.length) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing

    // If the quiz was passed, update the materi's isDoneMateri to true and quiz subMateri's isDone status
    if (isPassed && widget.materiName != null) {
      for (var materi in dataMateri) {
        if (materi['namaMateri'] == widget.materiName) {
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
      StorageService.saveProgress(dataMateri);
    }

    // Clear the saved quiz progress as the quiz is completed
    if (widget.materiName != null) {
      StorageService.clearQuizProgressForMateri(widget.materiName!);
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by clicking outside
      builder: (BuildContext context) {
        return FinalResultModal(
          correctAnswers: correctAnswers,
          totalQuestions: widget.soalList.length,
          onFinished: () {
            widget.recordQuizAttempt!(widget.materiName!);
            Navigator.of(context).pop(); // Close modal
            Navigator.of(context).pop(); // Return to previous screen
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back button behavior
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return; // If the default behavior already popped the route, return
        }
        _loadSavedProgress();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Soal ${currentQuestionIndex + 1}/${widget.soalList.length} • $soalKategori',
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          actions: [
            TimeDisplay(
              timeInSeconds: waktuDetik,
              onTimeOver: () {
                debugPrint('IM DONE');
              }, // This is handled in the timer logic
            ),
            const SizedBox(width: 16.0),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
              const SizedBox(height: 16),
              // Submit button
              SubmitButton(
                onSubmit: _showConfirmationModal,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
