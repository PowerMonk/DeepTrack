import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GoalsService {
  static const String _dailyGoalsKey = 'daily_goals';
  static const String _weeklyGoalsKey = 'weekly_goals';
  static const String _goalsUnitKey = 'goals_unit'; // 'hours' or 'minutes'

  // Default goals in minutes
  static const Map<String, int> _defaultDailyGoalsMinutes = {
    'work': 480, // 8 hours
    'study': 240, // 4 hours
    'exercise': 60, // 1 hour
    'social': 120, // 2 hours
    'rest': 480, // 8 hours
  };

  static const Map<String, int> _defaultWeeklyGoalsMinutes = {
    'work': 2400, // 40 hours
    'study': 1200, // 20 hours
    'exercise': 300, // 5 hours
    'social': 600, // 10 hours
    'rest': 3360, // 56 hours
  };

  // Get current unit preference (hours or minutes)
  static Future<String> getGoalsUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_goalsUnitKey) ?? 'hours';
  }

  // Set unit preference
  static Future<void> setGoalsUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsUnitKey, unit);
  }

  // Get daily goals in minutes
  static Future<Map<String, int>> getDailyGoalsMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_dailyGoalsKey);

    if (goalsJson != null) {
      final goals = json.decode(goalsJson);
      return Map<String, int>.from(goals);
    }

    return Map<String, int>.from(_defaultDailyGoalsMinutes);
  }

  // Get weekly goals in minutes
  static Future<Map<String, int>> getWeeklyGoalsMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_weeklyGoalsKey);

    if (goalsJson != null) {
      final goals = json.decode(goalsJson);
      return Map<String, int>.from(goals);
    }

    return Map<String, int>.from(_defaultWeeklyGoalsMinutes);
  }

  // Get daily goals in hours
  static Future<Map<String, double>> getDailyGoalsHours() async {
    final goalsMinutes = await getDailyGoalsMinutes();
    return goalsMinutes.map((key, value) => MapEntry(key, value / 60.0));
  }

  // Get weekly goals in hours
  static Future<Map<String, double>> getWeeklyGoalsHours() async {
    final goalsMinutes = await getWeeklyGoalsMinutes();
    return goalsMinutes.map((key, value) => MapEntry(key, value / 60.0));
  }

  // Save daily goals (input in minutes)
  static Future<void> saveDailyGoalsMinutes(Map<String, int> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyGoalsKey, json.encode(goals));
  }

  // Save weekly goals (input in minutes)
  static Future<void> saveWeeklyGoalsMinutes(Map<String, int> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weeklyGoalsKey, json.encode(goals));
  }

  // Save daily goals (input in hours)
  static Future<void> saveDailyGoalsHours(Map<String, double> goals) async {
    final goalsMinutes = goals.map(
      (key, value) => MapEntry(key, (value * 60).round()),
    );
    await saveDailyGoalsMinutes(goalsMinutes);
  }

  // Save weekly goals (input in hours)
  static Future<void> saveWeeklyGoalsHours(Map<String, double> goals) async {
    final goalsMinutes = goals.map(
      (key, value) => MapEntry(key, (value * 60).round()),
    );
    await saveWeeklyGoalsMinutes(goalsMinutes);
  }

  // Convert minutes to hours
  static double minutesToHours(int minutes) {
    return minutes / 60.0;
  }

  // Convert hours to minutes
  static int hoursToMinutes(double hours) {
    return (hours * 60).round();
  }

  // Format time for display
  static String formatTime(double value, String unit) {
    if (unit == 'minutes') {
      int minutes = value.round();
      if (minutes >= 60) {
        int hours = minutes ~/ 60;
        int remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          return '${hours}h';
        } else {
          return '${hours}h ${remainingMinutes}m';
        }
      } else {
        return '${minutes}m';
      }
    } else {
      // Hours
      if (value == value.toInt()) {
        return '${value.toInt()}h';
      } else {
        return '${value.toStringAsFixed(1)}h';
      }
    }
  }

  // Get goal value in the preferred unit
  static double getGoalValueInUnit(int goalMinutes, String unit) {
    if (unit == 'minutes') {
      return goalMinutes.toDouble();
    } else {
      return goalMinutes / 60.0;
    }
  }

  // Set goal value from the preferred unit
  static int setGoalValueFromUnit(double value, String unit) {
    if (unit == 'minutes') {
      return value.round();
    } else {
      return (value * 60).round();
    }
  }
}
