import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/time_tracking_service.dart';

void main() {
  group('TimeTrackingService Tests', () {
    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('should start and stop activity tracking', () async {
      // Start tracking study
      await TimeTrackingService.startActivity('study');

      // Check current activity
      final currentActivity = await TimeTrackingService.getCurrentActivity();
      expect(currentActivity, equals('study'));

      // Wait a moment to simulate time passage
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop current activity
      await TimeTrackingService.stopCurrentActivity();

      // Check that no activity is current
      final noActivity = await TimeTrackingService.getCurrentActivity();
      expect(noActivity, isNull);

      // Check that daily data was saved
      final dailyData = await TimeTrackingService.getDailyData();
      expect(dailyData['study'], greaterThan(0));
    });

    test('should save and retrieve daily data', () async {
      // Save some test data
      await TimeTrackingService.saveDailyMinutes('work', 120);
      await TimeTrackingService.saveDailyMinutes('study', 60);

      // Retrieve daily data
      final dailyData = await TimeTrackingService.getDailyData();

      expect(dailyData['work'], equals(120));
      expect(dailyData['study'], equals(60));
      expect(dailyData['exercise'], equals(0));
    });

    test('should convert minutes to hours correctly', () {
      expect(TimeTrackingService.minutesToHours(60), equals(1.0));
      expect(TimeTrackingService.minutesToHours(90), equals(1.5));
      expect(TimeTrackingService.minutesToHours(0), equals(0.0));
    });

    test('should convert hours to minutes correctly', () {
      expect(TimeTrackingService.hoursToMinutes(1.0), equals(60));
      expect(TimeTrackingService.hoursToMinutes(1.5), equals(90));
      expect(TimeTrackingService.hoursToMinutes(0.0), equals(0));
    });

    test('should get current date in correct format', () {
      final date = TimeTrackingService.getCurrentDate();
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      expect(regex.hasMatch(date), isTrue);
    });

    tearDown(() async {
      // Clean up test data
      await TimeTrackingService.clearAllData();
    });
  });
}
