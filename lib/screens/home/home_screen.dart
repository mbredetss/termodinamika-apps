import 'package:flutter/material.dart';
import '../materi/materi_screen.dart';
import '../materi/component/materi_data.dart';
import '../../services/storage_service.dart';
import '../relax/relax_screen.dart';
import 'components/background_wrapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Load saved progress before determining which content to navigate to
                List<Map<String, dynamic>>? savedData = await StorageService.loadProgress();
                if (savedData != null && savedData.isNotEmpty) {
                  // Update the global dataMateri with saved progress
                  for (int i = 0; i < dataMateri.length && i < savedData.length; i++) {
                    var savedMateri = savedData[i];
                    if (savedMateri.containsKey('isDoneMateri')) {
                      dataMateri[i]['isDoneMateri'] = savedMateri['isDoneMateri'] ?? false;
                    }

                    var savedSubMateriList = savedMateri['subMateri'] as List?;
                    var currentSubMateriList = dataMateri[i]['subMateri'] as List?;

                    if (savedSubMateriList != null && currentSubMateriList != null) {
                      for (int j = 0; j < currentSubMateriList.length && j < savedSubMateriList.length; j++) {
                        var savedSubMateri = savedSubMateriList[j] as Map<String, dynamic>?;
                        if (savedSubMateri != null && savedSubMateri.containsKey('isDone')) {
                          currentSubMateriList[j]['isDone'] = savedSubMateri['isDone'] ?? false;
                        }
                      }
                    }
                  }
                }

                // Check if all content is completed before navigating
                bool allDone = true;
                for (int materiIndex = 0; materiIndex < dataMateri.length; materiIndex++) {
                  var materi = dataMateri[materiIndex];
                  if (materi['isDoneMateri'] == false) {
                    allDone = false;
                    break;
                  }

                  var subMateriList = materi['subMateri'] as List;
                  for (int subIndex = 0; subIndex < subMateriList.length; subIndex++) {
                    var subMateri = subMateriList[subIndex];
                    if (subMateri['isDone'] == false) {
                      allDone = false;
                      break;
                    }
                  }

                  if (!allDone) break;
                }

                if (allDone) {
                  // If all content is done, navigate directly to materi screen
                  String? lastCompletedContent;
                  String? lastCompletedTitle;

                  // Find the last completed content
                  for (int materiIndex = 0; materiIndex < dataMateri.length; materiIndex++) {
                    var materi = dataMateri[materiIndex];
                    var subMateriList = materi['subMateri'] as List;

                    // If this materi was completed, update last completed content to the ujianAkhir of this materi
                    if (materi['isDoneMateri'] == true) {
                      // The last subMateri in the list should be the ujianAkhir
                      if (subMateriList.isNotEmpty) {
                        var lastSubMateri = subMateriList.last;
                        lastCompletedContent = lastSubMateri['isiMateri'] as String?;
                        lastCompletedTitle = lastSubMateri['nama'] as String?;
                      }
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MateriScreen(
                        initialContent: lastCompletedContent,
                        bottomAppBarTitle: lastCompletedTitle ?? 'Prasyarat Kemampuan',
                      ),
                    ),
                  );
                } else {
                  // Navigate to RelaxScreen instead of directly to materi screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RelaxScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E), // Deep Indigo
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Mulai Belajar',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Added white color for better visibility on background
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}