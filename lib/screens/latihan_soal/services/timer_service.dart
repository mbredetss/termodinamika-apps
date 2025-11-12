import 'dart:async';

class TimerService {
  Timer? _timer;
  
  /// Starts a countdown timer with the given duration in seconds
  void startTimer({
    required int initialTime,
    required void Function(int remainingTime) onTick,
    required void Function() onTimeOver,
  }) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (initialTime > 0) {
        initialTime--;
        onTick(initialTime);
      } else {
        _timer?.cancel();
        onTimeOver();
      }
    });
  }

  /// Cancels the timer
  void cancelTimer() {
    _timer?.cancel();
  }

  /// Formats time in seconds to MM:SS format
  static String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}