import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart';
import 'components/module_list_screen.dart';
import 'components/materi_data.dart';
import 'components/warning_modal.dart';
import 'components/countdown_display.dart';
import 'components/start_quiz_button.dart';
import '../latihan_soal/latihan_soal_screen.dart';
import '../../services/cooldown_service.dart';
import '../../services/progress_tracking_service.dart';
import '../../services/learning_path_service.dart';

class MateriScreen extends StatefulWidget {
  final String? initialContent;
  final String? bottomAppBarTitle;

  const MateriScreen({super.key, this.initialContent, this.bottomAppBarTitle});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  String? currentContent;
  String? currentSubMateriName;
  String? bottomAppBarTitle;
  Timer? _countdownTimer;
  int _remainingCooldownTime = 0; // In seconds
  bool _isQuizAvailable = true;
  // Key to force rebuild of Markdown widget when content changes
  Key? _markdownKey;
  String _activeSearchKeyword = ''; // Track active search keyword for highlighting

  @override
  void initState() {
    super.initState();

    // Load saved progress from SharedPreferences
    _loadSavedProgress();

    // Set the initial content from props if provided
    currentContent = widget.initialContent;
    // Find the subMateri name based on the initial content
    currentSubMateriName = findSubMateriName(currentContent);
    // Initialize bottom app bar title
    bottomAppBarTitle = widget.bottomAppBarTitle ?? 'Prasyarat Kemampuan';
    // Initialize the key for the Markdown widget
    _markdownKey = Key('${currentContent.hashCode}');

    // Check if there's a cooldown for the current materi
    checkQuizAvailability();
  }

  @override
  void didUpdateWidget(MateriScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the content has changed, if so, re-check quiz availability
    if (oldWidget.initialContent != widget.initialContent) {
      currentContent = widget.initialContent;
      currentSubMateriName = findSubMateriName(currentContent);
      bottomAppBarTitle = widget.bottomAppBarTitle ?? 'Prasyarat Kemampuan';
      // Remove the active search keyword when widget is updated (manual navigation)
      _activeSearchKeyword = '';
      // Change the key to force rebuild of Markdown widget and reset scroll
      _markdownKey = Key('${currentContent.hashCode}');
      checkQuizAvailability();
    }
  }

  // Helper method to find subMateri name based on content
  String? findSubMateriName(String? content) {
    if (content == null) return null;

    for (var materi in dataMateri) {
      var subMateriList = materi['subMateri'] as List;
      for (var subMateri in subMateriList) {
        if (subMateri['isiMateri'] == content) {
          return subMateri['nama'] as String?;
        }
      }
    }
    return null;
  }

  // Helper method to find the index of a subMateri by its content
  ({int materiIndex, int subMateriIndex})? findSubMateriIndex(String? content) {
    if (content == null) return null;

    for (int i = 0; i < dataMateri.length; i++) {
      var materi = dataMateri[i];
      var subMateriList = materi['subMateri'] as List;

      for (int j = 0; j < subMateriList.length; j++) {
        if (subMateriList[j]['isiMateri'] == content) {
          return (materiIndex: i, subMateriIndex: j);
        }
      }
    }

    return null;
  }

  // Load saved progress using platform-specific storage
  Future<void> _loadSavedProgress() async {
    // Load progress using the new progress tracking service
    // This method now initializes the UI based on stored progress
    for (var materi in dataMateri) {
      String materiName = materi['namaMateri'];
      var subMateriList = materi['subMateri'] as List;

      for (var subMateri in subMateriList) {
        String subMateriName = subMateri['nama'];
        bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
          materiName: materiName,
          subMateriName: subMateriName,
        );

        // Update the in-memory data structure to reflect the saved progress
        // This is needed for the UI to display the correct state
        subMateri['isDone'] = isCompleted;
      }
    }
  }

  // Navigate to the previous subMateri
  Future<void> goToPreviousSubMateri() async {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex == null) return;

    int currentMateriIndex = currentIndex.materiIndex;
    int currentSubMateriIndex = currentIndex.subMateriIndex;
    var currentMateri = dataMateri[currentMateriIndex];
    var currentSubMateriList = currentMateri['subMateri'] as List;

    // Try to go to the previous subMateri in the same materi
    if (currentSubMateriIndex > 0) {
      var prevSubMateri = currentSubMateriList[currentSubMateriIndex - 1];
      // Update the current subMateri status to done before navigating (but not for the quiz)
      var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
      String currentSubMateriNameTemp = currentSubMateri['nama'] as String;

      // Only update progress if it's not a quiz/latihan soal
      if (!currentSubMateriNameTemp.toLowerCase().contains('latihan soal') &&
          !currentSubMateriNameTemp.toLowerCase().contains('ujian')) {
        ProgressTrackingService.saveSubMateriProgress(
          materiName: currentMateri['namaMateri'],
          subMateriName: currentSubMateriNameTemp,
          isCompleted: true,
        );
      }

      setState(() {
        currentContent = prevSubMateri['isiMateri'] as String;
        currentSubMateriName = prevSubMateri['nama'] as String;
        bottomAppBarTitle = currentSubMateriName;
        // Remove the active search keyword when navigating manually
        _activeSearchKeyword = '';
        // Change the key to force rebuild of Markdown widget and reset scroll
        _markdownKey = Key('${currentContent.hashCode}');
      });
      // Check quiz availability for the new content
      checkQuizAvailability();
    }
    // If at the first subMateri of this materi, go to the last subMateri of the previous materi
    else if (currentMateriIndex > 0) {
      // Update the current subMateri status to done before navigating (but not for the quiz)
      var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
      String currentSubMateriName = currentSubMateri['nama'] as String;

      // Only update progress if it's not a quiz/latihan soal
      if (!currentSubMateriName.toLowerCase().contains('latihan soal') &&
          !currentSubMateriName.toLowerCase().contains('ujian')) {
        ProgressTrackingService.saveSubMateriProgress(
          materiName: currentMateri['namaMateri'],
          subMateriName: currentSubMateriName,
          isCompleted: true,
        );
      }

      // Find the previous materi that has subMateri
      int prevMateriIndex = currentMateriIndex - 1;
      while (prevMateriIndex >= 0) {
        var subMateriList = dataMateri[prevMateriIndex]['subMateri'] as List;
        if (subMateriList.isNotEmpty) {
          int lastSubIndex = subMateriList.length - 1;
          var lastSubMateri = subMateriList[lastSubIndex];
          setState(() {
            currentContent = lastSubMateri['isiMateri'] as String;
            currentSubMateriName = lastSubMateri['nama'] as String;
            bottomAppBarTitle = currentSubMateriName;
            // Remove the active search keyword when navigating manually
            _activeSearchKeyword = '';
            // Change the key to force rebuild of Markdown widget and reset scroll
            _markdownKey = Key('${currentContent.hashCode}');
          });
          // Check quiz availability for the new content
          checkQuizAvailability();
          break;
        }
        prevMateriIndex--;
      }
    }
  }

  // Save progress using platform-specific storage
  Future<void> _saveProgress() async {
    // Save progress using the new progress tracking service
    // This method is kept for compatibility but the new service handles saving automatically
    // when progress is updated
  }

  // Navigate to the next subMateri
  Future<void> goToNextSubMateri() async {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex == null) return;

    int currentMateriIndex = currentIndex.materiIndex;
    int currentSubMateriIndex = currentIndex.subMateriIndex;
    var currentMateri = dataMateri[currentMateriIndex];
    var currentSubMateriList = currentMateri['subMateri'] as List;

    // Check if we are at the last subMateri (latihan soal) in the final evaluation
    if (currentMateri['namaMateri'] == 'Evaluasi Akhir' && currentSubMateriIndex == currentSubMateriList.length - 1) {
      // Check if this last subMateri is the latihan soal (ujian)
      var lastSubMateri = currentSubMateriList[currentSubMateriIndex];
      String lastSubMateriName = lastSubMateri['nama'] as String;

      // If it's the last subMateri and its name contains "Latihan Soal" or "ujian",
      // check if the quiz has been completed before allowing to move on
      if (lastSubMateriName.toLowerCase().contains('latihan soal') ||
          lastSubMateriName.toLowerCase().contains('ujian')) {

        bool isQuizCompleted = lastSubMateri['isDone'] == true;

        // If quiz is not completed, show warning and don't allow navigation
        if (!isQuizCompleted) {
          // Show error message that user needs to complete the quiz first
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  'Peringatan',
                  style: TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'Kerjakan Latihan Soal terlebih dahulu sebelum Anda bisa lanjut ke materi berikutnya!',
                  style: TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the modal
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          return; // Don't proceed with navigation
        }
      }
    }

    // Try to go to the next subMateri in the same materi
    if (currentSubMateriIndex < currentSubMateriList.length - 1) {
      var nextSubMateri = currentSubMateriList[currentSubMateriIndex + 1];
      // Update the current subMateri status to done before navigating (but not for the quiz)
      var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
      String currentSubMateriNameTemp = currentSubMateri['nama'] as String;

      // Only update progress if it's not a quiz/latihan soal
      if (!currentSubMateriNameTemp.toLowerCase().contains('latihan soal') &&
          !currentSubMateriNameTemp.toLowerCase().contains('ujian')) {
        ProgressTrackingService.saveSubMateriProgress(
          materiName: currentMateri['namaMateri'],
          subMateriName: currentSubMateriNameTemp,
          isCompleted: true,
        );
      }

      setState(() {
        currentContent = nextSubMateri['isiMateri'] as String;
        currentSubMateriName = nextSubMateri['nama'] as String;
        bottomAppBarTitle = currentSubMateriName;
        // Remove the active search keyword when navigating manually
        _activeSearchKeyword = '';
        // Change the key to force rebuild of Markdown widget and reset scroll
        _markdownKey = Key('${currentContent.hashCode}');
      });
      // Check quiz availability for the new content
      checkQuizAvailability();
    }
    // If at the last subMateri of this materi, check if we can go to the next materi
    else if (currentMateriIndex < dataMateri.length - 1) {
      // Update the current subMateri status to done before navigating (but not for the quiz)
      var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
      String currentSubMateriNameTemp = currentSubMateri['nama'] as String;

      // Only update progress if it's not a quiz/latihan soal
      if (!currentSubMateriNameTemp.toLowerCase().contains('latihan soal') &&
          !currentSubMateriNameTemp.toLowerCase().contains('ujian')) {
        ProgressTrackingService.saveSubMateriProgress(
          materiName: currentMateri['namaMateri'],
          subMateriName: currentSubMateriNameTemp,
          isCompleted: true,
        );
      }

      // Find the next materi that has subMateri
      int nextMateriIndex = currentMateriIndex + 1;
      while (nextMateriIndex < dataMateri.length) {
        // Check if the next materi is accessible based on learning path
        bool isAccessible = await LearningPathService.canAccessSubMateri(
          materiName: dataMateri[nextMateriIndex]['namaMateri'],
          subMateriName: (dataMateri[nextMateriIndex]['subMateri'] as List)[0]['nama'],
        );

        if (isAccessible) {
          var subMateriList = dataMateri[nextMateriIndex]['subMateri'] as List;
          if (subMateriList.isNotEmpty) {
            var firstSubMateri = subMateriList[0];
            setState(() {
              currentContent = firstSubMateri['isiMateri'] as String;
              currentSubMateriName = firstSubMateri['nama'] as String;
              bottomAppBarTitle = currentSubMateriName;
              // Remove the active search keyword when navigating manually
              _activeSearchKeyword = '';
              // Change the key to force rebuild of Markdown widget and reset scroll
              _markdownKey = Key('${currentContent.hashCode}');
            });
            // Check quiz availability for the new content
            checkQuizAvailability();
            break;
          }
        } else {
          // Show warning that the next materi is not accessible yet
          showMateriPrerequisiteWarning();
          break;
        }
        nextMateriIndex++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303F9F), // Deep Indigo (primary)
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFF6D00), // Orange icon
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFFFF6D00), // Orange icon
            ),
            onPressed: () {
              _showSearchOverlay();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.list,
              color: Color(0xFFFF6D00), // Orange icon
            ),
            onPressed: () {
              // Navigate to module list screen with slide-in animation
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ModuleListScreen(
                        currentSubMateriName: currentSubMateriName,
                      ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          // PopupMenuButton(
          //   icon: Icon(
          //     Icons.more_vert,
          //     color: Color(0xFFFF6D00), // Orange icon
          //   ),
          //   itemBuilder: (context) => [
          //     const PopupMenuItem(value: 'option1', child: Text('Menu Opsi 1')),
          //     const PopupMenuItem(value: 'option2', child: Text('Menu Opsi 2')),
          //     const PopupMenuItem(value: 'option3', child: Text('Menu Opsi 3')),
          //   ],
          // ),
          // const SizedBox(width: 16.0), // Add some spacing at the right end
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: currentContent != null && currentContent!.isNotEmpty
                  ? _buildContentWithHighlights(currentContent!)
                  : const Center(
                      child: Text(
                        'Tidak ada konten untuk ditampilkan',
                        style: TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            // Show the cooldown message if this is the last subMateri and the quiz is on cooldown
            if (isLastSubMateri() && !_isQuizAvailable)
              CountdownDisplay(
                remainingCooldownTime: _remainingCooldownTime,
              ),
            // Show the "Mulai" button if this is the last subMateri in the final evaluation materi and quiz is available
            if (isLastSubMateri() && _isQuizAvailable && isFinalEvaluation())
              StartQuizButton(
                onPressed: () {
                  showUjianModal();
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF555555), // Dark gray
                  size: 18,
                ),
                onPressed: () {
                  goToPreviousSubMateri();
                },
              ),
              Expanded(
                child: Text(
                  bottomAppBarTitle ?? 'Prasyarat Kemampuan',
                  style: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (!isLastSubMateri())
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF555555), // Dark gray
                    size: 18,
                  ),
                  onPressed: () {
                    goToNextSubMateri();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if the current subMateri is the last one in its materi
  bool isLastSubMateri() {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex == null) return false;

    int currentMateriIndex = currentIndex.materiIndex;
    int currentSubMateriIndex = currentIndex.subMateriIndex;
    var currentMateri = dataMateri[currentMateriIndex];
    var currentSubMateriList = currentMateri['subMateri'] as List;

    // Check if this is the final evaluation materi
    if (currentMateri['namaMateri'] == 'Evaluasi Akhir') {
      return currentSubMateriIndex == currentSubMateriList.length - 1;
    }

    // For regular materi, check if it's the last subMateri and if it's the last materi in the list
    bool isLastMateri = currentMateriIndex == dataMateri.length - 2; // -2 because the last one is the evaluation
    return isLastMateri && currentSubMateriIndex == currentSubMateriList.length - 1;
  }

  // Check if the current subMateri is in the final evaluation section
  bool isFinalEvaluation() {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex == null) return false;

    int currentMateriIndex = currentIndex.materiIndex;
    var currentMateri = dataMateri[currentMateriIndex];

    return currentMateri['namaMateri'] == 'Evaluasi Akhir';
  }



  // Check if the specified materi is completed (all subMateri done)
  Future<bool> isMateriCompleted(int materiIndex) async {
    if (materiIndex < 0 || materiIndex >= dataMateri.length) return false;

    var materi = dataMateri[materiIndex];
    var subMateriList = materi['subMateri'] as List;
    String materiName = materi['namaMateri'];

    // Special handling for the final evaluation materi
    if (materiName == 'Evaluasi Akhir') {
      // For the final evaluation, check if the quiz has been completed
      for (var subMateri in subMateriList) {
        String subMateriName = subMateri['nama'] as String;
        if (subMateriName.toLowerCase().contains('latihan soal') ||
            subMateriName.toLowerCase().contains('ujian')) {
          bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
            materiName: materiName,
            subMateriName: subMateriName,
          );
          return isCompleted;
        }
      }
      return false;
    }

    // For other materi, check if all subMateri are completed
    for (var subMateri in subMateriList) {
      String subMateriName = subMateri['nama'] as String;
      bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
        materiName: materiName,
        subMateriName: subMateriName,
      );
      if (!isCompleted) {
        return false;
      }
    }
    return true;
  }

  // Show warning modal for prerequisite
  void showPrerequisiteWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningModal(
          title: 'Warning',
          content: 'Maaf, Anda belum bisa membuka modul ini. Mohon pastikan semua modul sebelumnya (termasuk submission) sudah diselesaikan.',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Close the modal
          },
        );
      },
    );
  }

  // Show warning modal for trying to navigate across different materi
  void showCrossMateriWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningModal(
          title: 'Warning',
          content: 'Anda hanya dapat berpindah ke submateri lain dalam materi yang sama. Mohon selesaikan materi saat ini terlebih dahulu.',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Close the modal
          },
        );
      },
    );
  }

  // Show warning modal when trying to access next materi before completing current one
  void showMateriPrerequisiteWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningModal(
          title: 'Warning',
          content: 'Maaf, Anda belum bisa membuka modul ini. Mohon pastikan semua modul sebelumnya (termasuk latihan soal) sudah diselesaikan.',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Close the modal
          },
        );
      },
    );
  }

  void checkQuizAvailability() async {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex != null) {
      var materi = dataMateri[currentIndex.materiIndex];
      String materiName = materi['namaMateri'] as String;

      bool isInCooldown = await CooldownService.isInCooldown(materiName);
      if (isInCooldown) {
        DateTime? cooldownEndTime = await CooldownService.loadCooldown(materiName);
        if (cooldownEndTime != null) {
          Duration timeUntilEnd = cooldownEndTime.difference(DateTime.now());
          int remainingSeconds = timeUntilEnd.inSeconds;

          if (remainingSeconds > 0) {
            // Cancel any existing countdown timer before starting a new one
            _countdownTimer?.cancel();
            _remainingCooldownTime = remainingSeconds;
            setState(() {
              _isQuizAvailable = false; // Explicitly mark quiz as unavailable
            });
            startCountdown();
          } else {
            // Cooldown has ended
            setState(() {
              _isQuizAvailable = true;
            });
          }
        }
      } else {
        // No cooldown for this material
        setState(() {
          _isQuizAvailable = true;
        });
      }
    }
  }

  void startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingCooldownTime > 0) {
        setState(() {
          _remainingCooldownTime--;
        });
      } else {
        _countdownTimer?.cancel();
        // When countdown is complete, the quiz will be available again
        setState(() {
          _isQuizAvailable = true;
        });
      }
    });
  }

  Future<void> recordQuizAttempt(String materiName) async {
    DateTime cooldownEndTime = DateTime.now().add(Duration(minutes: 15)); // 15 minutes from now
    await CooldownService.saveCooldown(materiName, cooldownEndTime);

    setState(() {
      _isQuizAvailable = false;
    });
    _remainingCooldownTime = 15 * 60; // 15 minutes in seconds
    startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    // Save progress before disposing
    _saveProgress(); // Not awaited as dispose is synchronous
    super.dispose();
  }

  String formatCountdownTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Show the modal for ujian confirmation
  void showUjianModal() async {
    // Check if quiz is available
    var currentIndex = findSubMateriIndex(currentContent);
    String? materiName = '';
    if (currentIndex != null) {
      materiName = dataMateri[currentIndex.materiIndex]['namaMateri'] as String?;
    }

    // For the new structure, the quiz is only in the "Evaluasi Akhir" section
    if (materiName != null) {
      bool isInCooldown = await CooldownService.isInCooldown(materiName);
      if (isInCooldown) {
        // Show a message that the quiz is still on cooldown
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: const Color(0xFFFF6D00), // Orange color
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kuis dalam cooldown',
                    style: TextStyle(
                      fontFamily: 'StackSansText',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Anda harus menunggu sebelum mengambil kuis ini lagi. Tersisa: ${formatCountdownTime(_remainingCooldownTime)}',
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              actions: [
                Center(
                  child: GFButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the modal
                    },
                    text: 'OK',
                    textStyle: const TextStyle(
                      fontFamily: 'StackSansText',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    color: const Color(0xFF303F9F), // Deep Indigo color
                    shape: GFButtonShape.pills,
                    size: GFSize.SMALL,
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
        return; // Exit the function without showing the confirmation modal
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.quiz,
                color: const Color(0xFFFF6D00), // Orange color
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Konfirmasi Ujian',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin mengambil ujian ini?',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika Anda mengambil ujian ini, maka Anda baru akan dapat mengambilnya lagi 15 menit setelah ujian berakhir',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GFButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the modal
                    },
                    text: 'Batal',
                    textStyle: const TextStyle(
                      fontFamily: 'StackSansText',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    color: Colors.grey[300] ?? Colors.grey, // Fallback to Colors.grey if Colors.grey[300] is null
                    shape: GFButtonShape.pills,
                    size: GFSize.SMALL,
                    elevation: 2,
                  ),
                  const SizedBox(width: 16),
                  GFButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the modal
                      // Navigate to the quiz screen without recording the attempt here
                      var currentIndex = findSubMateriIndex(currentContent);
                      if (currentIndex != null) {
                        var materi = dataMateri[currentIndex.materiIndex];

                        // For the new structure, if we're in the final evaluation, get questions from there
                        // Otherwise, we need to collect all questions from all materi
                        List<Map<String, dynamic>> allQuestions = [];

                        if (materi['namaMateri'] == 'Evaluasi Akhir') {
                          // Get questions from the final evaluation section
                          var soalList = materi['soal'] as List?;
                          if (soalList != null && soalList.isNotEmpty) {
                            allQuestions = soalList.cast<Map<String, dynamic>>();
                          }
                        } else {
                          // Collect questions from all materi sections
                          for (var materiSection in dataMateri) {
                            var soalList = materiSection['soal'] as List?;
                            if (soalList != null && soalList.isNotEmpty) {
                              allQuestions.addAll(soalList.cast<Map<String, dynamic>>());
                            }
                          }
                        }

                        if (allQuestions.isNotEmpty) {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LatihanSoalScreen(
                                      soalList: allQuestions,
                                      materiName: materi['namaMateri'] as String?,
                                      recordQuizAttempt: recordQuizAttempt,
                                    ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    text: 'Lanjut',
                    textStyle: const TextStyle(
                      fontFamily: 'StackSansText',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    color: const Color(0xFF303F9F), // Deep Indigo color
                    shape: GFButtonShape.pills,
                    size: GFSize.SMALL,
                    elevation: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to show search overlay
  void _showSearchOverlay() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchOverlay(
          dataMateri: dataMateri,
          onResultTap: (result, searchKeyword) {
            // Find the index of the selected subMateri
            int? materiIndex, subMateriIndex;

            for (int i = 0; i < dataMateri.length; i++) {
              var subMateriList = dataMateri[i]['subMateri'] as List;
              for (int j = 0; j < subMateriList.length; j++) {
                if (subMateriList[j]['isiMateri'] == result['isiMateri']) {
                  materiIndex = i;
                  subMateriIndex = j;
                  break;
                }
              }
              if (materiIndex != null && subMateriIndex != null) break;
            }

            if (materiIndex != null && subMateriIndex != null) {
              // Check if the selected subMateri is accessible
              if (isSubMateriAccessible(materiIndex, subMateriIndex)) {
                // Navigate back to main screen and update content
                Navigator.pop(context);
                setState(() {
                  currentContent = result['isiMateri'];
                  currentSubMateriName = result['nama'] as String?;
                  bottomAppBarTitle = currentSubMateriName;
                  // Set the active search keyword for highlighting
                  _activeSearchKeyword = searchKeyword;
                  _markdownKey = Key('${currentContent.hashCode}');
                });

                // Save progress after updating isDone status
                _saveProgress();

                // Check quiz availability for the new content
                checkQuizAvailability();
              } else {
                // Show warning that this subMateri is not accessible yet
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Warning',
                            style: TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Maaf, Anda belum bisa membuka modul ini. Mohon pastikan semua modul sebelumnya (termasuk latihan soal) sudah diselesaikan.',
                        style: TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      actions: [
                        Center(
                          child: GFButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the modal
                            },
                            text: 'OK',
                            textStyle: const TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            color: const Color(0xFF303F9F), // Deep Indigo color
                            shape: GFButtonShape.pills,
                            size: GFSize.SMALL,
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }

  // Check if the subMateri at the given indices is accessible
  bool isSubMateriAccessible(int materiIndex, int subMateriIndex) {
    // If it's the first subMateri of the first materi, it's always accessible
    if (materiIndex == 0 && subMateriIndex == 0) {
      return true;
    }

    // Check if it's the final evaluation materi
    if (materiIndex == dataMateri.length - 1 && dataMateri[materiIndex]['namaMateri'] == 'Evaluasi Akhir') {
      // The final evaluation is accessible only when all other materi are completed
      for (int i = 0; i < dataMateri.length - 1; i++) {
        if (dataMateri[i]['isDoneMateri'] != true) {
          return false;
        }
      }
      return true;
    }

    // Check if it's the first subMateri of a materi
    if (subMateriIndex == 0) {
      // It's accessible if the previous materi is completed
      if (materiIndex > 0) {
        var previousMateri = dataMateri[materiIndex - 1];
        return previousMateri['isDoneMateri'] == true;
      }
      return false;
    } else {
      // It's a subMateri within the same materi, check if the previous subMateri is done
      var currentMateri = dataMateri[materiIndex];
      var subMateriList = currentMateri['subMateri'] as List;

      // Check if the previous subMateri is completed
      var previousSubMateri = subMateriList[subMateriIndex - 1];
      return previousSubMateri['isDone'] == true;
    }
  }

  // Build content with highlighted search keywords
  Widget _buildContentWithHighlights(String content) {
    // If there's no active search keyword, just render the content as Markdown
    if (_activeSearchKeyword.isEmpty) {
      return Markdown(
        key: _markdownKey,
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          h2: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
          p: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 20,
            height: 1.6,
          ),
          listBullet: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 20,
          ),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 18,
            backgroundColor: Colors.grey,
            color: Colors.white,
          ),
          a: const TextStyle(
            color: Color(0xFF303F9F), // Deep Indigo
            decoration: TextDecoration.underline,
          ),
        ),
        onTapLink: (text, href, title) async {
          if (href != null) {
            // Check if we're on the web
            if (kIsWeb) {
              // For web, open link in a new tab
              await launchUrl(
                Uri.parse(href),
                mode: LaunchMode.externalApplication,
              );
            } else {
              // For mobile, open link in an in-app browser
              await launchUrl(
                Uri.parse(href),
                mode: LaunchMode.inAppBrowserView,
              );
            }
          }
        },
        imageBuilder: (Uri uri, String? title, String? altText) {
          // Check if the URI is a relative path that should point to assets
          if (uri.path.contains('Aspose.Words')) {
            // Map the image names to actual asset paths
            String assetPath =
                'assets/images/${uri.path.split('/').last}';
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 5.0,
              ),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image: ${uri.path.split('/').last}',
                                style: const TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '(Place image in assets/images/)',
                                style: const TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (altText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        altText,
                        style: const TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else {
            // For other image URLs, use standard network loading
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 5.0,
              ),
              child: Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        uri.toString(),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (altText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        altText,
                        style: const TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      );
    }

    // If there's an active search keyword, we need to highlight it in the content
    // First, we'll convert the markdown content to plain text with highlights
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 20,
              height: 1.6,
              color: Colors.black87,
            ),
            children: _createTextSpans(content, _activeSearchKeyword),
          ),
        ),
      ),
    );
  }

  // Create text spans with highlighted keywords
  List<InlineSpan> _createTextSpans(String content, String keyword) {
    if (keyword.isEmpty) {
      return [TextSpan(text: content)];
    }

    List<InlineSpan> spans = [];
    String lowerContent = content.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();
    int startIndex = 0;
    int index;

    while ((index = lowerContent.indexOf(lowerKeyword, startIndex)) != -1) {
      // Add text before the keyword
      if (index > startIndex) {
        spans.add(TextSpan(text: content.substring(startIndex, index)));
      }

      // Add highlighted keyword
      spans.add(
        TextSpan(
          text: content.substring(index, index + keyword.length),
          style: const TextStyle(
            backgroundColor: Color.fromARGB(120, 255, 235, 59), // Pale yellow
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      startIndex = index + keyword.length;
    }

    // Add any remaining text after the last keyword
    if (startIndex < content.length) {
      spans.add(TextSpan(text: content.substring(startIndex)));
    }

    return spans;
  }
}

class SearchOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> dataMateri;
  final Function(Map<String, dynamic> result, String searchKeyword) onResultTap;

  const SearchOverlay({
    super.key,
    required this.dataMateri,
    required this.onResultTap,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Map<String, dynamic>> _searchResults = [];
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchKeyword = '';
      });
      return;
    }

    setState(() {
      _searchKeyword = keyword.toLowerCase();
      _searchResults = [];

      for (var materi in widget.dataMateri) {
        var subMateriList = materi['subMateri'] as List;

        for (var subMateri in subMateriList) {
          String isiMateri = subMateri['isiMateri'] as String;
          String namaSubMateri = subMateri['nama'] as String;

          // Count occurrences of the keyword in the content
          int count = _countKeywordOccurrences(isiMateri.toLowerCase(), _searchKeyword);

          if (count > 0) {
            _searchResults.add({
              'materi': materi['namaMateri'],
              'nama': namaSubMateri,
              'isiMateri': isiMateri,
              'count': count,
            });
          }
        }
      }
    });
  }

  int _countKeywordOccurrences(String content, String keyword) {
    if (keyword.isEmpty) return 0;

    int count = 0;
    int index = 0;

    while (index < content.length) {
      index = content.indexOf(keyword, index);
      if (index == -1) {
        break;
      }
      count++;
      index += keyword.length;
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303F9F), // Deep Indigo (primary)
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFF6D00), // Orange icon
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari dalam materi...',
            hintStyle: const TextStyle(color: Colors.white),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6D00)), // Orange icon
          ),
          style: const TextStyle(color: Colors.white), // White text for contrast
          autofocus: true,
        ),
      ),
      body: _searchResults.isEmpty
          ? (_searchKeyword.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Masukkan kata kunci untuk pencarian',
                        style: TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ditemukan hasil pencarian',
                        style: TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                var result = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0B2), // Light orange background
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${result['count']} kecocokan',
                            style: const TextStyle(
                              fontFamily: 'StackSansText',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6D00), // Orange color
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result['nama'],
                            style: const TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildHighlightedPreview(result['isiMateri'], _searchKeyword),
                    ),
                    onTap: () {
                      widget.onResultTap(result, _searchKeyword);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Build a preview of the content with the search keyword highlighted
  Widget _buildHighlightedPreview(String content, String keyword) {
    if (keyword.isEmpty) return const SizedBox.shrink();

    // Find the first occurrence of the keyword to create a preview
    int startIndex = content.toLowerCase().indexOf(keyword);

    // If the keyword exists in the content
    if (startIndex != -1) {
      // Get the text before the keyword (up to 50 characters before)
      int startPreview = (startIndex - 50).clamp(0, content.length);
      // Get the text after the keyword (up to 100 characters after)
      int endPreview = (startIndex + keyword.length + 100).clamp(0, content.length);

      String before = content.substring(startPreview, startIndex);
      String matched = content.substring(startIndex, startIndex + keyword.length);
      String after = content.substring(startIndex + keyword.length, endPreview);

      // Add "..." if the preview is truncated
      String prefix = startPreview > 0 ? '... ' : '';
      String suffix = endPreview < content.length ? ' ...' : '';

      return Container(
        padding: const EdgeInsets.only(top: 4.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 14,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: prefix + before,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              TextSpan(
                text: matched,
                style: const TextStyle(
                  backgroundColor: Color.fromARGB(120, 255, 235, 59), // Pale yellow
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: after + suffix,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If keyword is not found, return an empty container
    return const SizedBox.shrink();
  }
}
