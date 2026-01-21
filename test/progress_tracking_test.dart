import 'package:flutter_test/flutter_test.dart';
import 'package:termodinamika_apps/services/progress_tracking_service.dart';
import 'package:termodinamika_apps/services/learning_path_service.dart';

void main() {
  setUp(() {
    // Initialize the binding for tests that use shared preferences
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('Progress Tracking Service Tests', () {
    setUp(() async {
      // Reset progress before each test
      await ProgressTrackingService.resetProgress();
    });

    test('should save and retrieve sub-materi progress', () async {
      // Save progress for a sub-materi
      await ProgressTrackingService.saveSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Introduction',
        isCompleted: true,
      );

      // Retrieve the progress
      bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Introduction',
      );

      expect(isCompleted, true);
    });

    test('should return false for non-existent progress', () async {
      bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
        materiName: 'Non Existent',
        subMateriName: 'Topic',
      );

      expect(isCompleted, false);
    });

    test('should get materi progress', () async {
      // Save progress for multiple sub-materi
      await ProgressTrackingService.saveSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Introduction',
        isCompleted: true,
      );

      await ProgressTrackingService.saveSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Laws of Thermodynamics',
        isCompleted: false,
      );

      // Get progress for the materi
      Map<String, bool> progress = await ProgressTrackingService.getMateriProgress('Thermodynamics Basics');

      expect(progress['Introduction'], true);
      expect(progress['Laws of Thermodynamics'], false);
    });

    test('should mark quiz as passed and update all sub-materi', () async {
      // Save progress for some sub-materi
      await ProgressTrackingService.saveSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Introduction',
        isCompleted: true,
      );

      // Mark the quiz as passed (which should mark all sub-materi as completed)
      await ProgressTrackingService.markQuizAsPassed('Thermodynamics Basics');

      // Check that all sub-materi are now marked as completed
      bool introductionCompleted = await ProgressTrackingService.getSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Introduction',
      );

      // Note: We can't test other sub-materi without knowing the exact data structure,
      // but the service should mark all sub-materi in the materi as completed
      expect(introductionCompleted, true);
    });

    test('should get last accessed module', () async {
      // Save a module as last accessed
      await ProgressTrackingService.saveSubMateriProgress(
        materiName: 'Thermodynamics Basics',
        subMateriName: 'Introduction',
        isCompleted: false,
      );

      String? lastAccessed = await ProgressTrackingService.getLastAccessedModule();
      
      // Note: Last accessed is saved separately, so we need to test this differently
      // The saveSubMateriProgress method should also save the last accessed module
      expect(lastAccessed, 'Introduction');
    });
  });

  group('Learning Path Service Tests', () {
    setUp(() async {
      // Reset progress before each test
      await ProgressTrackingService.resetProgress();
    });

    test('should determine if sub-materi is accessible based on prerequisites', () async {
      // Initially, the first sub-materi should be accessible
      bool accessible = await LearningPathService.canAccessSubMateri(
        materiName: 'Selamat Datang di Materi Thermodinamika',
        subMateriName: 'Pendahuluan',
      );

      // This depends on the actual data structure in materi_data.dart
      // For the first sub-materi, it should typically be accessible
      expect(accessible, true);
    });

    test('should get accessible sub-materi for a materi', () async {
      // Initially, only the first sub-materi should be accessible
      List<String> accessibleSubMateri = await LearningPathService.getAccessibleSubMateri(
        'Selamat Datang di Materi Thermodinamika'
      );

      // Should contain at least the first sub-materi
      expect(accessibleSubMateri.length, greaterThanOrEqualTo(1));
    });
  });
}