import '../services/progress_tracking_service.dart';
import '../screens/materi/components/materi_data.dart';

class LearningPathService {
  /// Determines if a user can access a specific sub-materi based on their progress
  static Future<bool> canAccessSubMateri({
    required String materiName,
    required String subMateriName,
  }) async {
    // Get all progress for this materi
    Map<String, bool> progress = await ProgressTrackingService.getMateriProgress(materiName);
    
    // Find the index of the requested sub-materi in the materi
    int targetIndex = -1;
    for (int i = 0; i < dataMateri.length; i++) {
      if (dataMateri[i]['namaMateri'] == materiName) {
        List subMateriList = dataMateri[i]['subMateri'];
        for (int j = 0; j < subMateriList.length; j++) {
          if (subMateriList[j]['nama'] == subMateriName) {
            targetIndex = j;
            break;
          }
        }
        break;
      }
    }
    
    // If we couldn't find the sub-materi, deny access
    if (targetIndex == -1) {
      return false;
    }
    
    // Get the sub-materi list for this materi
    List? subMateriList;
    for (var materi in dataMateri) {
      if (materi['namaMateri'] == materiName) {
        subMateriList = materi['subMateri'];
        break;
      }
    }
    
    if (subMateriList == null) {
      return false;
    }
    
    // Check if all previous sub-materi are completed
    for (int i = 0; i < targetIndex; i++) {
      String prevSubMateriName = subMateriList[i]['nama'];
      bool isCompleted = progress[prevSubMateriName] ?? false;
      
      // If any previous sub-materi is not completed, deny access
      if (!isCompleted) {
        return false;
      }
    }
    
    // If all previous sub-materi are completed, allow access
    return true;
  }

  /// Gets the list of accessible sub-materi for a given materi
  static Future<List<String>> getAccessibleSubMateri(String materiName) async {
    List<String> accessibleSubMateri = [];
    
    // Get all progress for this materi
    Map<String, bool> progress = await ProgressTrackingService.getMateriProgress(materiName);
    
    // Find the materi in the data
    List? subMateriList;
    for (var materi in dataMateri) {
      if (materi['namaMateri'] == materiName) {
        subMateriList = materi['subMateri'];
        break;
      }
    }
    
    if (subMateriList == null) {
      return accessibleSubMateri;
    }
    
    // Find the first incomplete sub-materi
    int firstIncompleteIndex = -1;
    for (int i = 0; i < subMateriList.length; i++) {
      String subMateriName = subMateriList[i]['nama'];
      bool isCompleted = progress[subMateriName] ?? false;
      
      if (!isCompleted) {
        firstIncompleteIndex = i;
        break;
      }
    }
    
    // If all sub-materi are completed, user can access all
    if (firstIncompleteIndex == -1) {
      for (var subMateri in subMateriList) {
        accessibleSubMateri.add(subMateri['nama']);
      }
    } else {
      // User can access all completed sub-materi plus the next one
      for (int i = 0; i <= firstIncompleteIndex; i++) {
        accessibleSubMateri.add(subMateriList[i]['nama']);
      }
    }
    
    return accessibleSubMateri;
  }

  /// Gets the next sub-materi that the user should access
  static Future<Map<String?, String?>?> getNextSubMateri() async {
    // First, check if there's a last accessed module
    String? lastAccessedModule = await ProgressTrackingService.getLastAccessedModule();
    
    if (lastAccessedModule != null) {
      // Find which materi and sub-materi this belongs to
      for (var materi in dataMateri) {
        List subMateriList = materi['subMateri'];
        for (var subMateri in subMateriList) {
          if (subMateri['nama'] == lastAccessedModule) {
            String materiName = materi['namaMateri'];
            bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
              materiName: materiName,
              subMateriName: lastAccessedModule,
            );
            
            // If the last accessed module is completed, find the next incomplete one
            if (isCompleted) {
              String? nextIncomplete = await ProgressTrackingService.getNextIncompleteModule(materiName);
              if (nextIncomplete != null) {
                return {'materiName': materiName, 'subMateriName': nextIncomplete};
              }
            } else {
              // If not completed, return the last accessed one to continue
              return {'materiName': materiName, 'subMateriName': lastAccessedModule};
            }
          }
        }
      }
    }
    
    // If no last accessed module or we couldn't find it, get the first incomplete module
    return await ProgressTrackingService.getFirstIncompleteModule();
  }
}