import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../home/home_screen.dart';
import 'component/module_list_screen.dart';
import 'component/materi_data.dart';
import 'component/warning_modal.dart';
import 'component/countdown_display.dart';
import 'component/start_quiz_button.dart';
import '../latihan_soal/latihan_soal_screen.dart';
import '../../services/progress_service.dart';

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
  Map<String, DateTime>? lastQuizAttemptTime; // Track last quiz attempt time for each materi
  Timer? _countdownTimer;
  int _remainingCooldownTime = 0; // In seconds
  bool _isQuizAvailable = true;

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
    
    // Initialize cooldown tracking
    lastQuizAttemptTime = <String, DateTime>{};
    
    // Check if there's a cooldown for the current materi
    checkQuizAvailability();
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

  // Load saved progress from SharedPreferences
  Future<void> _loadSavedProgress() async {
    List<Map<String, dynamic>>? savedData = await ProgressService.loadProgress();
    if (savedData != null) {
      // Update the global dataMateri with saved progress
      for (int i = 0; i < dataMateri.length; i++) {
        if (i < savedData.length) {
          var savedMateri = savedData[i];
          dataMateri[i]['isDoneMateri'] = savedMateri['isDoneMateri'] ?? false;
          
          var savedSubMateriList = savedMateri['subMateri'] as List;
          var currentSubMateriList = dataMateri[i]['subMateri'] as List;
          
          for (int j = 0; j < currentSubMateriList.length; j++) {
            if (j < savedSubMateriList.length) {
              var savedSubMateri = savedSubMateriList[j] as Map<String, dynamic>;
              currentSubMateriList[j]['isDone'] = savedSubMateri['isDone'] ?? false;
            }
          }
        }
      }
    }
  }

  // Navigate to the previous subMateri
  void goToPreviousSubMateri() {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex == null) return;

    int currentMateriIndex = currentIndex.materiIndex;
    int currentSubMateriIndex = currentIndex.subMateriIndex;
    var currentMateri = dataMateri[currentMateriIndex];
    var currentSubMateriList = currentMateri['subMateri'] as List;

    // Try to go to the previous subMateri in the same materi
    if (currentSubMateriIndex > 0) {
      var prevSubMateri = currentSubMateriList[currentSubMateriIndex - 1];
      setState(() {
        // Update the current subMateri status to done before navigating (but not for the quiz)
        var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
        String currentSubMateriName = currentSubMateri['nama'] as String;
        
        // Only update isDone if it's not a quiz/latihan soal
        if (!currentSubMateriName.toLowerCase().contains('latihan soal') && 
            !currentSubMateriName.toLowerCase().contains('ujian')) {
          currentMateri['subMateri'][currentSubMateriIndex]['isDone'] = true;
        }
        
        currentContent = prevSubMateri['isiMateri'] as String;
        currentSubMateriName = prevSubMateri['nama'] as String;
        bottomAppBarTitle = currentSubMateriName;
      });
      // Save progress after updating isDone status
      _saveProgress();
    }
    // If at the first subMateri of this materi, go to the last subMateri of the previous materi
    else if (currentMateriIndex > 0) {
      // Update the current subMateri status to done before navigating (but not for the quiz)
      var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
      String currentSubMateriName = currentSubMateri['nama'] as String;
      
      // Only update isDone if it's not a quiz/latihan soal
      if (!currentSubMateriName.toLowerCase().contains('latihan soal') && 
          !currentSubMateriName.toLowerCase().contains('ujian')) {
        currentMateri['subMateri'][currentSubMateriIndex]['isDone'] = true;
      }
      // Save progress after updating isDone status
      _saveProgress();
      
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
          });
          break;
        }
        prevMateriIndex--;
      }
    }
  }

  // Save progress to SharedPreferences
  Future<void> _saveProgress() async {
    await ProgressService.saveProgress(dataMateri);
  }

  // Navigate to the next subMateri
  void goToNextSubMateri() {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex == null) return;

    int currentMateriIndex = currentIndex.materiIndex;
    int currentSubMateriIndex = currentIndex.subMateriIndex;
    var currentMateri = dataMateri[currentMateriIndex];
    var currentSubMateriList = currentMateri['subMateri'] as List;

    // Check if we are at the last subMateri (latihan soal) 
    if (currentSubMateriIndex == currentSubMateriList.length - 1) {
      // Check if this last subMateri is the latihan soal (ujian)
      var lastSubMateri = currentSubMateriList[currentSubMateriIndex];
      String lastSubMateriName = lastSubMateri['nama'] as String;
      
      // If it's the last subMateri and its name contains "Latihan Soal" or "ujian", 
      // check if the materi is completed before allowing to move on
      if (lastSubMateriName.toLowerCase().contains('latihan soal') || 
          lastSubMateriName.toLowerCase().contains('ujian')) {
        
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

    // Try to go to the next subMateri in the same materi
    if (currentSubMateriIndex < currentSubMateriList.length - 1) {
      var nextSubMateri = currentSubMateriList[currentSubMateriIndex + 1];
      setState(() {
        // Update the current subMateri status to done before navigating (but not for the quiz)
        var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
        String currentSubMateriName = currentSubMateri['nama'] as String;
        
        // Only update isDone if it's not a quiz/latihan soal
        if (!currentSubMateriName.toLowerCase().contains('latihan soal') && 
            !currentSubMateriName.toLowerCase().contains('ujian')) {
          currentMateri['subMateri'][currentSubMateriIndex]['isDone'] = true;
        }
        
        currentContent = nextSubMateri['isiMateri'] as String;
        currentSubMateriName = nextSubMateri['nama'] as String;
        bottomAppBarTitle = currentSubMateriName;
      });
      // Save progress after updating isDone status
      _saveProgress();
    }
    // If at the last subMateri of this materi, check if we can go to the next materi
    else if (currentMateriIndex < dataMateri.length - 1) {
      // Update the current subMateri status to done before navigating (but not for the quiz)
      var currentSubMateri = currentSubMateriList[currentSubMateriIndex];
      String currentSubMateriName = currentSubMateri['nama'] as String;
      
      // Only update isDone if it's not a quiz/latihan soal
      if (!currentSubMateriName.toLowerCase().contains('latihan soal') && 
          !currentSubMateriName.toLowerCase().contains('ujian')) {
        currentMateri['subMateri'][currentSubMateriIndex]['isDone'] = true;
      }
      // Save progress after updating isDone status
      _saveProgress();
      
      // Check if the current materi is completed before allowing navigation to the next one
      if (isMateriCompleted(currentMateriIndex)) {
        // Find the next materi that has subMateri
        int nextMateriIndex = currentMateriIndex + 1;
        while (nextMateriIndex < dataMateri.length) {
          // Check if the next materi is available to access (previous materi isDoneMateri = true)
          if (dataMateri[nextMateriIndex - 1]['isDoneMateri'] == true || nextMateriIndex == currentMateriIndex + 1) {
            var subMateriList = dataMateri[nextMateriIndex]['subMateri'] as List;
            if (subMateriList.isNotEmpty) {
              var firstSubMateri = subMateriList[0];
              setState(() {
                currentContent = firstSubMateri['isiMateri'] as String;
                currentSubMateriName = firstSubMateri['nama'] as String;
                bottomAppBarTitle = currentSubMateriName;
              });
              break;
            }
          } else {
            // Show warning that previous materi is not completed
            showMateriPrerequisiteWarning();
            break;
          }
          nextMateriIndex++;
        }
      } else {
        // Show warning modal if the current materi is not completed
        showPrerequisiteWarning();
      }
    }
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
              color: Colors.grey, // Medium gray
            ),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.list,
              color: Colors.grey, // Medium gray
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
          //     color: Colors.grey, // Medium gray
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
              child: Markdown(
                data: currentContent ?? '',
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
                ),
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
              ),
            ),
            // Show the cooldown message if this is the last subMateri and the quiz is on cooldown
            if (isLastSubMateri() && !_isQuizAvailable)
              CountdownDisplay(
                remainingCooldownTime: _remainingCooldownTime,
              ),
            // Show the "Mulai" button if this is the last subMateri in the current materi and quiz is available
            if (isLastSubMateri() && _isQuizAvailable)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                bottomAppBarTitle ?? 'Prasyarat Kemampuan',
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
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

    return currentSubMateriIndex == currentSubMateriList.length - 1;
  }

  // Check if the specified materi is completed (all subMateri done)
  bool isMateriCompleted(int materiIndex) {
    if (materiIndex < 0 || materiIndex >= dataMateri.length) return false;

    var materi = dataMateri[materiIndex];
    var subMateriList = materi['subMateri'] as List;

    // Check if all subMateri in this materi are marked as done
    for (var subMateri in subMateriList) {
      if (subMateri['isDone'] == false) {
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

  void checkQuizAvailability() {
    var currentIndex = findSubMateriIndex(currentContent);
    if (currentIndex != null) {
      var materi = dataMateri[currentIndex.materiIndex];
      String materiName = materi['namaMateri'] as String;
      
      if (lastQuizAttemptTime!.containsKey(materiName)) {
        DateTime lastAttempt = lastQuizAttemptTime![materiName]!;
        Duration timeDifference = DateTime.now().difference(lastAttempt);
        int remainingSeconds = (15 * 60) - timeDifference.inSeconds; // 15 minutes in seconds
        
        if (remainingSeconds > 0) {
          _remainingCooldownTime = remainingSeconds;
          _isQuizAvailable = false;
          startCountdown();
        } else {
          _isQuizAvailable = true;
        }
      } else {
        _isQuizAvailable = true;
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
        setState(() {
          _isQuizAvailable = true;
        });
      }
    });
  }
  
  void recordQuizAttempt(String materiName) {
    lastQuizAttemptTime![materiName] = DateTime.now();
    _isQuizAvailable = false;
    _remainingCooldownTime = 15 * 60; // 15 minutes in seconds
    startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    // Save progress before disposing
    _saveProgress();
    super.dispose();
  }

  String formatCountdownTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Show the modal for ujian confirmation
  void showUjianModal() {
    // Check if quiz is available
    var currentIndex = findSubMateriIndex(currentContent);
    String? materiName = '';
    if (currentIndex != null) {
      materiName = dataMateri[currentIndex.materiIndex]['namaMateri'] as String?;
    }

    if (!_isQuizAvailable && materiName != null && lastQuizAttemptTime!.containsKey(materiName)) {
      // Show a message that the quiz is still on cooldown
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Kuis dalam cooldown',
              style: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Anda harus menunggu sebelum mengambil kuis ini lagi. Tersisa: ${formatCountdownTime(_remainingCooldownTime)}',
              style: const TextStyle(
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
      return; // Exit the function without showing the confirmation modal
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin mengambil ujian ini?',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika Anda mengambil ujian ini, maka Anda baru akan dapat mengambilnya lagi 15 menit setelah ujian berakhir',
                style: TextStyle(fontFamily: 'StackSansText', fontSize: 14),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 1.0),
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the modal
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the modal
                      // Navigate to the latihan soal screen with the current materi's complete soal data
                      // First, find the current materi name
                      var currentIndex = findSubMateriIndex(currentContent);
                      if (currentIndex != null) {
                        var materi = dataMateri[currentIndex.materiIndex];
                        var soalList = materi['soal'] as List?;
                        if (soalList != null && soalList.isNotEmpty) {
                          // Convert the list to a list of Map<String, dynamic>
                          List<Map<String, dynamic>> typedSoalList = 
                              soalList.cast<Map<String, dynamic>>();
                          
                          // Record the quiz attempt to start the cooldown
                          recordQuizAttempt(materi['namaMateri'] as String);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LatihanSoalScreen(
                                    soalList: typedSoalList,
                                    materiName: materi['namaMateri'] as String?,
                                  ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Lanjut',
                      style: TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
