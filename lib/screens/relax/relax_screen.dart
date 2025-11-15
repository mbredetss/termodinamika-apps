import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../materi/materi_screen.dart';
import '../materi/components/materi_data.dart';
import '../home/components/background_wrapper.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to materi screen after 9 seconds
    Future.delayed(const Duration(seconds: 9)).then((_) {
      _navigateToMateriScreen();
    });
  }

  void _navigateToMateriScreen() {
    // Find the first incomplete content to navigate to
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MateriScreen(
          initialContent: contentToNavigate,
          bottomAppBarTitle: titleToNavigate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation - now responsive to screen size
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Lottie.asset(
                  'assets/animations/relax.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Instruction text (now bold and larger)
            Text(
              'Luangkan waktu sebentar untuk menenangkan pikiranmu sebelum belajar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}