import 'package:workmanager/workmanager.dart';
import 'time_tracking_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("WorkManager: Starting daily data upload task");

    try {
      // Check and save to database if needed
      await TimeTrackingService.checkAndSaveToDatabaseIfNeeded();
      print("WorkManager: Daily data upload completed successfully");
      return Future.value(true);
    } catch (e) {
      print("WorkManager: Error during daily data upload: $e");
      return Future.value(false);
    }
  });
}

class WorkManagerService {
  static const String dailyUploadTask = "dailyDataUpload";

  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

      // Cancel any existing tasks
      await Workmanager().cancelAll();

      // Schedule daily task at 11:59 PM
      await Workmanager().registerPeriodicTask(
        dailyUploadTask,
        dailyUploadTask,
        frequency: const Duration(hours: 24),
        initialDelay: _getInitialDelay(),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      print("WorkManager: Daily upload task scheduled successfully");
    } catch (e) {
      print("WorkManager: Error initializing: $e");
    }
  }

  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, 23, 59);

    // If it's already past 11:59 PM today, schedule for tomorrow
    final nextExecution = targetTime.isBefore(now)
        ? targetTime.add(const Duration(days: 1))
        : targetTime;

    return nextExecution.difference(now);
  }

  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  static Future<void> rescheduleTask() async {
    await initialize();
  }
}
