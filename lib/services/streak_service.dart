import 'package:intl/intl.dart';
import 'storage_service.dart';

class StreakService {
  static const String _streakKey = 'streak_hari_berturut';
  static const String _lastVisitKey = 'tanggal_kunjungan_terakhir';
  static const String _achievementReceivedKey = 'sudah_dapat_achievement';

  /// Get today's date in YYYY-MM-DD format
  static String _getToday() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Get yesterday's date in YYYY-MM-DD format
  static String _getYesterday() {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }

  /// Get current streak count
  static Future<int> getCurrentStreak() async {
    String? streakStr = await getStorageService().getItem(_streakKey);
    if (streakStr != null) {
      try {
        return int.parse(streakStr);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// Update streak based on current visit
  static Future<void> updateStreak() async {
    String today = _getToday();
    String yesterday = _getYesterday();
    
    // Get stored data
    String? lastVisitDate = await getStorageService().getItem(_lastVisitKey);
    String? streakStr = await getStorageService().getItem(_streakKey);
    String? achievementReceivedStr = await getStorageService().getItem(_achievementReceivedKey);
    
    int currentStreak = 0;
    if (streakStr != null) {
      try {
        currentStreak = int.parse(streakStr);
      } catch (e) {
        currentStreak = 0;
      }
    }
    
    bool achievementReceived = false;
    if (achievementReceivedStr != null) {
      achievementReceived = achievementReceivedStr == 'true';
    }
    
    // Case A: User already opened the app today
    if (lastVisitDate == today) {
      // Don't do anything, streak doesn't increase if opening the app multiple times in a day
      return;
    }
    
    // Case B: User last visited yesterday (streak continues)
    if (lastVisitDate == yesterday) {
      // Streak continues!
      currentStreak = currentStreak + 1;
    } 
    // Case C: User last visited more than 1 day ago (streak breaks)
    else if (lastVisitDate != null && lastVisitDate != yesterday) {
      // Streak breaks, reset to 1 (today counts as first day of new streak)
      currentStreak = 1;
    } 
    // If it's the first time visiting (lastVisitDate is null)
    else if (lastVisitDate == null) {
      // Set streak to 1 for first visit
      currentStreak = 1;
    }
    
    // Update the last visit date to today
    await getStorageService().setItem(_lastVisitKey, today);
    // Update the streak count
    await getStorageService().setItem(_streakKey, currentStreak.toString());
    
    // Check if we should award an achievement
    if (currentStreak >= 5 && !achievementReceived) {
      await getStorageService().setItem(_achievementReceivedKey, 'true');
      // Note: The actual achievement notification would be handled elsewhere
    }
  }

  /// Check if the 5-day streak achievement has been received
  static Future<bool> isFiveDayAchievementReceived() async {
    String? achievementReceivedStr = await getStorageService().getItem(_achievementReceivedKey);
    if (achievementReceivedStr != null) {
      return achievementReceivedStr == 'true';
    }
    return false;
  }

  /// Reset streak (useful for testing, should generally not be called)
  static Future<void> resetStreak() async {
    await getStorageService().removeItem(_streakKey);
    await getStorageService().removeItem(_lastVisitKey);
    await getStorageService().removeItem(_achievementReceivedKey);
  }
}