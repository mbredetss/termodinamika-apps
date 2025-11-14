import 'package:flutter/material.dart';
import '../materi/materi_screen.dart';
import '../materi/component/materi_data.dart';
import '../../services/storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Beranda'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ini adalah halaman home',
              style: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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

                // Find the first incomplete subMateri that is accessible
                String? firstAccessibleContent;
                String? firstAccessibleTitle;

                // Track the last completed content in case all content is done
                String? lastCompletedContent;
                String? lastCompletedTitle;

                bool foundFirstIncomplete = false;

                for (int materiIndex = 0; materiIndex < dataMateri.length; materiIndex++) {
                  var materi = dataMateri[materiIndex];
                  var subMateriList = materi['subMateri'] as List;

                  // Check if materi is accessible (either first materi or previous materi is completed)
                  bool isMateriAccessible = (materiIndex == 0) || (dataMateri[materiIndex - 1]['isDoneMateri'] == true);

                  if (!isMateriAccessible) {
                    // If the materi itself is not accessible, skip to next materi
                    continue;
                  }

                  // Find the first incomplete subMateri in this materi
                  for (int subIndex = 0; subIndex < subMateriList.length; subIndex++) {
                    var subMateri = subMateriList[subIndex];

                    // Check if this subMateri is accessible (either first subMateri or previous one is done)
                    bool isSubMateriAccessible = (subIndex == 0) || (subMateriList[subIndex - 1]['isDone'] == true);

                    if (!isSubMateriAccessible) {
                      // If the subMateri is not accessible, stop looking in this materi
                      break;
                    }

                    if (subMateri['isDone'] == false) {
                      firstAccessibleContent = subMateri['isiMateri'] as String?;
                      firstAccessibleTitle = subMateri['nama'] as String?;
                      foundFirstIncomplete = true;
                      break;
                    } else {
                      // Track the last completed content
                      lastCompletedContent = subMateri['isiMateri'] as String?;
                      lastCompletedTitle = subMateri['nama'] as String?;
                    }
                  }

                  if (foundFirstIncomplete) break;

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

                // If no incomplete content was found, navigate to the last completed content
                String? contentToNavigate = foundFirstIncomplete ? firstAccessibleContent : lastCompletedContent;
                String? titleToNavigate = foundFirstIncomplete ? firstAccessibleTitle : lastCompletedTitle ?? 'Prasyarat Kemampuan';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MateriScreen(
                      initialContent: contentToNavigate,
                      bottomAppBarTitle: titleToNavigate,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Lihat Materi Termodinamika',
                style: TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}