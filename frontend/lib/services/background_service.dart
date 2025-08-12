import 'dart:async';
import 'time_tracking_service.dart';

class BackgroundService {
  static Timer? _dailyTimer;
  static Timer? _periodicTimer;

  // Start the background service
  static void start() {
    // Check for daily data transfer every hour
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await TimeTrackingService.checkAndSaveToDatabaseIfNeeded();
    });

    // Schedule daily data transfer at 11:59 PM
    _scheduleDailyTransfer();

    print('Background service started');
  }

  // Stop the background service
  static void stop() {
    _dailyTimer?.cancel();
    _periodicTimer?.cancel();
    _dailyTimer = null;
    _periodicTimer = null;
    print('Background service stopped');
  }

  // Schedule data transfer at 11:59 PM every day
  static void _scheduleDailyTransfer() {
    final now = DateTime.now();

    // Calculate next 11:59 PM
    DateTime next1159PM = DateTime(now.year, now.month, now.day, 23, 59);

    // If it's already past 11:59 PM today, schedule for tomorrow
    if (now.isAfter(next1159PM)) {
      next1159PM = next1159PM.add(const Duration(days: 1));
    }

    final duration = next1159PM.difference(now);

    _dailyTimer = Timer(duration, () async {
      print('Performing daily data transfer at ${DateTime.now()}');

      // Force save current day's data
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      await TimeTrackingService.savePreviousDayToDatabase(yesterdayString);

      // Schedule next day's transfer
      _scheduleDailyTransfer();
    });

    print('Next daily transfer scheduled for: $next1159PM');
  }

  // Manual trigger for testing
  static Future<void> triggerDailyTransfer() async {
    print('Manual daily transfer triggered');
    await TimeTrackingService.checkAndSaveToDatabaseIfNeeded();
  }
}
