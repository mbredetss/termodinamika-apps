import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/prompting.dart';
import 'component/answer_modal.dart';
import 'component/final_result_modal.dart';
import 'component/question_display.dart';
import 'component/submit_button.dart';
import 'component/time_display.dart';
import '../materi/component/materi_data.dart';
import '../../services/storage_service.dart';
import '../../services/cooldown_service.dart';

class LatihanSoalScreen extends StatefulWidget {
  final List<Map<String, dynamic>> soalList;
  final String? materiName;

  const LatihanSoalScreen({super.key, required this.soalList, this.materiName});

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

  @override
  void initState() {
    super.initState();

    // Set the first question data
    if (widget.soalList.isNotEmpty) {
      var currentSoal = widget.soalList[currentQuestionIndex];
      soalKategori = currentSoal['soalKategori'] ?? widget.materiName ?? 'Latihan Soal';
      int batasWaktu = currentSoal['batasWaktuPengerjaan'] ?? 180; // Default 3 minutes
      waktuDetik = batasWaktu;
      isiSoal = currentSoal['isiSoal'] ?? '';
    } else {
      soalKategori = widget.materiName ?? 'Latihan Soal';
      waktuDetik = 180;
      isiSoal = 'Tidak ada soal tersedia';
    }

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waktuDetik > 0) {
        setState(() {
          waktuDetik--;
        });
      } else {
        // Timer ended, handle timeout by automatically submitting with "Siswa tidak menjawab apapun"
        timer.cancel();
        jawabanSiswa = 'Siswa tidak menjawab apapun';
        kirimJawaban();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatWaktu(int detik) {
    int menit = detik ~/ 60;
    int sisaDetik = detik % 60;
    return '${menit.toString().padLeft(2, '0')}:${sisaDetik.toString().padLeft(2, '0')}';
  }

  void kirimJawaban() async {
    // Stop the timer when submitting an answer
    timer?.cancel();

    setState(() {
      isLoading = true;
    });

    try {
      // Load the .env file

      var currentSoal = widget.soalList[currentQuestionIndex];
      
      // Call the prompting function
      Map<String, dynamic> result = {
        'correctAnswer': true, 
        'explain': 'Jawaban Anda Benar Sekali!'
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

      // Show result modal
      showCorrectAnswerModal(explain, isCorrect);
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
      DateTime cooldownEndTime = DateTime.now().add(Duration(minutes: 15)); // 15 minutes from now
      CooldownService.saveCooldown(widget.materiName!, cooldownEndTime);
    }
    
    double scorePercentage = (correctAnswers / widget.soalList.length) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing

    // If the quiz was passed, update the materi's isDoneMateri to true
    if (isPassed && widget.materiName != null) {
      for (var materi in dataMateri) {
        if (materi['namaMateri'] == widget.materiName) {
          materi['isDoneMateri'] = true;
          break;
        }
      }
      
      // Save the updated progress
      StorageService.saveProgress(dataMateri);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FinalResultModal(
          correctAnswers: correctAnswers,
          totalQuestions: widget.soalList.length,
          onFinished: () {
            Navigator.of(context).pop(); // Close modal
            Navigator.of(context).pop(); // Return to previous screen
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF555555), // Dark gray
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
            onTimeOver: () {}, // This is handled in the timer logic
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
              answerText: jawabanSiswa,
              onAnswerChanged: (value) {
                setState(() {
                  jawabanSiswa = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Submit button
            SubmitButton(
              onSubmit: kirimJawaban,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}