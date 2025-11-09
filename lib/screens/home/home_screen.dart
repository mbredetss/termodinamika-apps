import 'package:flutter/material.dart';
import '../materi/materi_screen.dart';
import '../materi/component/materi_data.dart';

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
              onPressed: () {
                // Find the first incomplete subMateri that is accessible
                String? firstAccessibleContent;
                String? firstAccessibleTitle;

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
                    }
                  }
                  
                  if (foundFirstIncomplete) break;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MateriScreen(
                      initialContent: firstAccessibleContent,
                      bottomAppBarTitle: firstAccessibleTitle ?? 'Prasyarat Kemampuan',
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