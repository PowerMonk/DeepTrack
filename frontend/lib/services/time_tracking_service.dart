import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'database_service.dart';
import 'goals_service.dart';

class TimeTrackingService {
  static const String _currentActivityKey = 'current_activity';
  static const String _startTimeKey = 'start_time';
  static const String _dailyDataKey = 'daily_data';
  static const String _lastSavedDateKey = 'last_saved_date';

  // Get current date in YYYY-MM-DD format
  static String getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Start tracking an activity
  static Future<void> startActivity(String activity) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Stop current activity if any
    await stopCurrentActivity();

    // Start new activity
    await prefs.setString(_currentActivityKey, activity);
    await prefs.setInt(_startTimeKey, now);

    print(
      'Started tracking: $activity at ${DateTime.fromMillisecondsSinceEpoch(now)}',
    );
  }

  // Stop current activity and save the time
  static Future<void> stopCurrentActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final currentActivity = prefs.getString(_currentActivityKey);
    final startTime = prefs.getInt(_startTimeKey);

    if (currentActivity != null && startTime != null) {
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final durationMinutes = ((endTime - startTime) / (1000 * 60)).round();

      // Save the session data
      await saveDailyMinutes(currentActivity, durationMinutes);

      print(
        'Stopped tracking: $currentActivity, Duration: ${durationMinutes} minutes',
      );

      // Clear current activity
      await prefs.remove(_currentActivityKey);
      await prefs.remove(_startTimeKey);
    }
  }

  // Check if there's a current active activity
  static Future<String?> getCurrentActivity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentActivityKey);
  }

  // Save minutes for a specific activity to daily data
  static Future<void> saveDailyMinutes(String activity, int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final date = getCurrentDate();

    // Get existing daily data
    final dailyDataJson = prefs.getString(_dailyDataKey);
    Map<String, dynamic> dailyData = {};

    if (dailyDataJson != null) {
      dailyData = json.decode(dailyDataJson);
    }

    // Initialize data for today if it doesn't exist
    if (!dailyData.containsKey(date)) {
      dailyData[date] = {
        'work': 0,
        'study': 0,
        'exercise': 0,
        'social': 0,
        'rest': 0,
      };
    }

    // Add minutes to the activity
    dailyData[date][activity] = (dailyData[date][activity] ?? 0) + minutes;

    // Save back to preferences
    await prefs.setString(_dailyDataKey, json.encode(dailyData));

    print('Saved $minutes minutes for $activity on $date');
  }

  // Get daily data for a specific date
  static Future<Map<String, int>> getDailyData([String? date]) async {
    final prefs = await SharedPreferences.getInstance();
    final targetDate = date ?? getCurrentDate();
    final dailyDataJson = prefs.getString(_dailyDataKey);

    if (dailyDataJson != null) {
      final Map<String, dynamic> allData = json.decode(dailyDataJson);
      if (allData.containsKey(targetDate)) {
        return Map<String, int>.from(allData[targetDate]);
      }
    }

    // Return empty data if nothing found
    return {'work': 0, 'study': 0, 'exercise': 0, 'social': 0, 'rest': 0};
  }

  // Convert minutes to hours (double)
  static double minutesToHours(int minutes) {
    return minutes / 60.0;
  }

  // Convert hours to minutes (int)
  static int hoursToMinutes(double hours) {
    return (hours * 60).round();
  }

  // Check if we need to save data to SQLite (at end of day)
  static Future<void> checkAndSaveToDatabaseIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSavedDate = prefs.getString(_lastSavedDateKey);
    final currentDate = getCurrentDate();

    // If it's a new day and we have previous day's data, save to SQLite
    if (lastSavedDate != null && lastSavedDate != currentDate) {
      await savePreviousDayToDatabase(lastSavedDate);
      await prefs.setString(_lastSavedDateKey, currentDate);
    } else if (lastSavedDate == null) {
      await prefs.setString(_lastSavedDateKey, currentDate);
    }
  }

  // Save previous day's data to SQLite database
  static Future<void> savePreviousDayToDatabase(String date) async {
    try {
      final dailyData = await getDailyData(date);

      // Get goals from GoalsService
      final goals = await getGoalsForDate(date);

      await DatabaseService.insertDailyStats(
        date: date,
        workHours: dailyData['work'] ?? 0,
        workGoal: goals['work'] ?? 480, // 8 hours in minutes
        studyHours: dailyData['study'] ?? 0,
        studyGoal: goals['study'] ?? 240, // 4 hours in minutes
        socialHours: dailyData['social'] ?? 0,
        socialGoal: goals['social'] ?? 120, // 2 hours in minutes
        exerciseHours: dailyData['exercise'] ?? 0,
        exerciseGoal: goals['exercise'] ?? 60, // 1 hour in minutes
        restHours: dailyData['rest'] ?? 0,
        restGoal: goals['rest'] ?? 480, // 8 hours in minutes
      );

      print('Saved data for $date to SQLite database');
    } catch (e) {
      print('Error saving to database: $e');
    }
  }

  // Get goals for a specific date using GoalsService
  static Future<Map<String, int>> getGoalsForDate(String date) async {
    return await GoalsService.getDailyGoalsMinutes();
  }

  // Clear all data (for testing purposes)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentActivityKey);
    await prefs.remove(_startTimeKey);
    await prefs.remove(_dailyDataKey);
    await prefs.remove(_lastSavedDateKey);
    print('Cleared all tracking data');
  }

  // Get all stored daily data
  static Future<Map<String, Map<String, int>>> getAllDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyDataJson = prefs.getString(_dailyDataKey);

    if (dailyDataJson != null) {
      final Map<String, dynamic> allData = json.decode(dailyDataJson);
      return allData.map(
        (date, data) => MapEntry(date, Map<String, int>.from(data)),
      );
    }

    return {};
  }
}
