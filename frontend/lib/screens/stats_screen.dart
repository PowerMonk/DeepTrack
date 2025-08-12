import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/usage_stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String currentPeriod = 'Daily'; // Daily, Weekly, Monthly
  Map<String, double> realSocialMediaData = {};
  List<String> installedSocialApps = [];
  bool hasPermission = false;
  bool isLoadingUsageData = true;

  // Mock data for statistics
  final Map<String, Map<String, double>> statsData = {
    'daily': {
      'work': 2.5,
      'study': 1.8,
      'exercise': 0.5,
      'social': 3.2,
      'rest': 6.0,
    },
    'weekly': {
      'work': 15.0,
      'study': 12.5,
      'exercise': 3.5,
      'social': 22.4,
      'rest': 42.0,
    },
    'monthly': {
      'work': 65.0,
      'study': 52.0,
      'exercise': 15.5,
      'social': 95.6,
      'rest': 180.0,
    },
  };

  final Map<String, double> dailyGoals = {
    'work': 8.0,
    'study': 4.0,
    'exercise': 1.0,
    'social': 2.0,
    'rest': 8.0,
  };

  final Map<String, double> weeklyGoals = {
    'work': 40.0,
    'study': 20.0,
    'exercise': 7.0,
    'social': 10.0,
    'rest': 56.0,
  };

  final Map<String, double> monthlyGoals = {
    'work': 160.0,
    'study': 80.0,
    'exercise': 30.0,
    'social': 40.0,
    'rest': 240.0,
  };

  @override
  void initState() {
    super.initState();
    _initializeUsageData();
  }

  Future<void> _initializeUsageData() async {
    try {
      hasPermission = await UsageStatsService.hasUsageStatsPermission();

      if (hasPermission) {
        installedSocialApps = await UsageStatsService.getInstalledSocialApps();
        realSocialMediaData = await UsageStatsService.getSocialMediaUsage();

        // Filter to only show installed apps or fallback to YouTube and Instagram
        if (realSocialMediaData.isEmpty) {
          realSocialMediaData = {'Instagram': 0.0, 'YouTube': 0.0};
        } else {
          // Keep only the apps that are actually installed
          realSocialMediaData = Map.fromEntries(
            realSocialMediaData.entries.where(
              (entry) =>
                  installedSocialApps.contains(entry.key) ||
                  ['Instagram', 'YouTube'].contains(entry.key),
            ),
          );
        }
      } else {
        // Use fallback data as requested
        realSocialMediaData = {'Instagram': 0.0, 'YouTube': 0.0};
        installedSocialApps = ['Instagram', 'YouTube'];
      }
    } catch (e) {
      print('Error initializing usage data: $e');
      realSocialMediaData = {'Instagram': 0.0, 'YouTube': 0.0};
      installedSocialApps = ['Instagram', 'YouTube'];
    } finally {
      setState(() {
        isLoadingUsageData = false;
      });
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Map<String, double> _getCurrentGoals() {
    switch (currentPeriod) {
      case 'Weekly':
        return weeklyGoals;
      case 'Monthly':
        return monthlyGoals;
      default:
        return dailyGoals;
    }
  }

  Map<String, double> _getCurrentData() {
    switch (currentPeriod) {
      case 'Weekly':
        return statsData['weekly']!;
      case 'Monthly':
        return statsData['monthly']!;
      default:
        return statsData['daily']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromARGB(255, 250, 250, 250);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Your Stats',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Permission warning if needed
            if (!hasPermission) _buildPermissionWarning(),
            // Bar Chart Card
            _buildBarChartCard(),
            const SizedBox(height: 24),
            // Social Media Pie Chart
            _buildSocialMediaCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        color: Colors.orange[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Usage stats permission needed for real social media data',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await UsageStatsService.requestUsageStatsPermission();
                  // Refresh data after user potentially grants permission
                  await Future.delayed(const Duration(seconds: 2));
                  await _initializeUsageData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildPeriodToggle(),
            const SizedBox(height: 24),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['Daily', 'Weekly', 'Monthly'].map((period) {
        final isSelected = currentPeriod == period;
        return GestureDetector(
          onTap: () => setState(() => currentPeriod = period),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              period,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarChart() {
    final currentData = _getCurrentData();
    final currentGoals = _getCurrentGoals();

    final activities = [
      {'name': 'Work', 'key': 'work', 'color': Colors.blue},
      {'name': 'Study', 'key': 'study', 'color': Colors.green},
      {'name': 'Exercise', 'key': 'exercise', 'color': Colors.orange},
      {'name': 'Social', 'key': 'social', 'color': Colors.purple},
      {'name': 'Rest', 'key': 'rest', 'color': Colors.black},
    ];

    final maxValue = currentGoals.values.reduce(math.max);

    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activities.map((activity) {
                final key = activity['key'] as String;
                final actualValue = currentData[key]!;
                final goalValue = currentGoals[key]!;
                final actualHeight = (actualValue / maxValue) * 250;
                final goalHeight = (goalValue / maxValue) * 250;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Goal bar (gray background)
                        Container(
                          height: goalHeight,
                          width: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Actual bar (colored)
                        Container(
                          height: actualHeight,
                          width: 24,
                          decoration: BoxDecoration(
                            color: activity['color'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Labels
          Row(
            children: activities.map((activity) {
              return Expanded(
                child: Text(
                  activity['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Goal',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Actual',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    if (isLoadingUsageData) {
      return Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalSocialTime = realSocialMediaData.values.isEmpty
        ? 0.0
        : realSocialMediaData.values.reduce((a, b) => a + b);
    final couldHaveBeenTimeMinutes =
        totalSocialTime * 60; // Convert hours to minutes

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Social Media Usage',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (hasPermission)
                  GestureDetector(
                    onTap: _initializeUsageData,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (totalSocialTime > 0) ...[
              Row(
                children: [
                  // Pie Chart
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: PieChartPainter(realSocialMediaData),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: realSocialMediaData.entries.map((entry) {
                        final percentage =
                            (entry.value / totalSocialTime * 100);
                        final colors = [
                          Colors.red,
                          Colors.blue,
                          Colors.purple,
                          Colors.orange,
                        ];
                        final colorIndex = realSocialMediaData.keys
                            .toList()
                            .indexOf(entry.key);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[colorIndex % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You could have spent ${couldHaveBeenTimeMinutes.round()} minutes on more productive activities instead of social media.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 48,
                        color: Colors.black54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No social media usage detected today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Great job staying focused!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final total = data.values.reduce((a, b) => a + b);

    final colors = [Colors.red, Colors.blue, Colors.purple, Colors.orange];

    double startAngle = -math.pi / 2;
    int colorIndex = 0;

    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
