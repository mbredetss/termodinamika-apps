import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../materi/materi_screen.dart';
import '../materi/components/materi_data.dart';
import '../home/components/background_wrapper.dart';
import '../../services/learning_path_service.dart';
import '../../services/progress_tracking_service.dart';

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

  Future<void> _navigateToMateriScreen() async {
    // Use the learning path service to get the next sub-materi to navigate to
    Map<String?, String?>? nextSubMateri = await LearningPathService.getNextSubMateri();

    String? contentToNavigate;
    String? titleToNavigate = 'Prasyarat Kemampuan';

    if (nextSubMateri != null) {
      String? materiName = nextSubMateri['materiName'];
      String? subMateriName = nextSubMateri['subMateriName'];

      // Find the content for the next sub-materi
      for (var materi in dataMateri) {
        if (materi['namaMateri'] == materiName) {
          var subMateriList = materi['subMateri'] as List;

          for (var subMateri in subMateriList) {
            if (subMateri['nama'] == subMateriName) {
              contentToNavigate = subMateri['isiMateri'] as String?;
              titleToNavigate = subMateri['nama'] as String?;
              break;
            }
          }
          break;
        }
      }
    }

    // If no specific content was found, try to find the last completed content
    if (contentToNavigate == null) {
      // Find the last completed content
      for (int materiIndex = dataMateri.length - 1; materiIndex >= 0; materiIndex--) {
        var materi = dataMateri[materiIndex];
        var subMateriList = materi['subMateri'] as List;

        for (int subIndex = subMateriList.length - 1; subIndex >= 0; subIndex--) {
          var subMateri = subMateriList[subIndex];
          String materiName = materi['namaMateri'];
          String subMateriName = subMateri['nama'];

          bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
            materiName: materiName,
            subMateriName: subMateriName,
          );

          if (isCompleted) {
            contentToNavigate = subMateri['isiMateri'] as String?;
            titleToNavigate = subMateri['nama'] as String?;
            break;
          }
        }

        if (contentToNavigate != null) break;
      }
    }

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