import 'package:flutter/services.dart';

class UsageStatsService {
  static const MethodChannel _channel = MethodChannel('deeptrack/usage_stats');

  static Future<bool> hasUsageStatsPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod(
        'hasUsageStatsPermission',
      );
      return hasPermission;
    } catch (e) {
      print('Error checking usage stats permission: $e');
      return false;
    }
  }

  static Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } catch (e) {
      print('Error requesting usage stats permission: $e');
    }
  }

  static Future<Map<String, double>> getSocialMediaUsage() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'getSocialMediaUsage',
      );
      return result.map(
        (key, value) => MapEntry(key.toString(), value.toDouble()),
      );
    } catch (e) {
      print('Error getting social media usage: $e');
      // Return fallback data for YouTube and Instagram as requested
      return {'Instagram': 0.0, 'YouTube': 0.0};
    }
  }

  static Future<List<String>> getInstalledSocialApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getInstalledSocialApps',
      );
      return result.cast<String>();
    } catch (e) {
      print('Error getting installed social apps: $e');
      // Return fallback apps as requested
      return ['Instagram', 'YouTube'];
    }
  }
}
