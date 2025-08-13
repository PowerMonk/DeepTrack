import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';

class ExportService {
  // Export SQLite data to CSV
  static Future<String> exportToCSV() async {
    try {
      // Get all data from SQLite
      final data = await DatabaseService.getAllDailyStats();

      // Create CSV content
      StringBuffer csvContent = StringBuffer();

      // Add header
      csvContent.writeln(
        'Date,Work Hours,Work Goal,Study Hours,Study Goal,Exercise Hours,Exercise Goal,Social Hours,Social Goal,Rest Hours,Rest Goal',
      );

      // Add data rows
      for (final row in data) {
        csvContent.writeln(
          '${row['date']},'
          '${(row['work_hours'] / 60.0).toStringAsFixed(2)},'
          '${(row['work_goal'] / 60.0).toStringAsFixed(2)},'
          '${(row['study_hours'] / 60.0).toStringAsFixed(2)},'
          '${(row['study_goal'] / 60.0).toStringAsFixed(2)},'
          '${(row['exercise_hours'] / 60.0).toStringAsFixed(2)},'
          '${(row['exercise_goal'] / 60.0).toStringAsFixed(2)},'
          '${(row['social_hours'] / 60.0).toStringAsFixed(2)},'
          '${(row['social_goal'] / 60.0).toStringAsFixed(2)},'
          '${(row['rest_hours'] / 60.0).toStringAsFixed(2)},'
          '${(row['rest_goal'] / 60.0).toStringAsFixed(2)}',
        );
      }

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'deeptrack_export_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csvContent.toString());

      // Copy file path to clipboard
      await Clipboard.setData(ClipboardData(text: filePath));

      print('CSV exported to: $filePath');
      print('File path copied to clipboard');

      return filePath;
    } catch (e) {
      print('Error exporting CSV: $e');
      rethrow;
    }
  }

  // Get the database file path
  static Future<String> getDatabasePath() async {
    final path = await DatabaseService.getDatabasePath();
    return path;
  }

  // Get summary of data for display
  static Future<Map<String, dynamic>> getDataSummary() async {
    try {
      final data = await DatabaseService.getAllDailyStats();

      if (data.isEmpty) {
        return {
          'totalEntries': 0,
          'dateRange': 'No data',
          'totalWorkHours': 0.0,
          'totalStudyHours': 0.0,
        };
      }

      // Sort data by date
      data.sort((a, b) => a['date'].compareTo(b['date']));

      final firstDate = data.first['date'];
      final lastDate = data.last['date'];

      double totalWorkHours = 0;
      double totalStudyHours = 0;
      double totalExerciseHours = 0;
      double totalSocialHours = 0;
      double totalRestHours = 0;

      for (final row in data) {
        totalWorkHours += (row['work_hours'] / 60.0);
        totalStudyHours += (row['study_hours'] / 60.0);
        totalExerciseHours += (row['exercise_hours'] / 60.0);
        totalSocialHours += (row['social_hours'] / 60.0);
        totalRestHours += (row['rest_hours'] / 60.0);
      }

      return {
        'totalEntries': data.length,
        'dateRange': '$firstDate to $lastDate',
        'totalWorkHours': totalWorkHours,
        'totalStudyHours': totalStudyHours,
        'totalExerciseHours': totalExerciseHours,
        'totalSocialHours': totalSocialHours,
        'totalRestHours': totalRestHours,
      };
    } catch (e) {
      print('Error getting data summary: $e');
      return {
        'totalEntries': 0,
        'dateRange': 'Error loading data',
        'totalWorkHours': 0.0,
        'totalStudyHours': 0.0,
      };
    }
  }
}
