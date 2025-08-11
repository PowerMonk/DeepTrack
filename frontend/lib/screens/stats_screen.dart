import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool isDaily = true;

  // Mock data for statistics
  final Map<String, Map<String, double>> statsData = {
    'daily': {
      'work': 2.5,
      'study': 1.8,
      'exercise': 0.5,
      'social': 1.2,
      'rest': 6.0,
    },
    'weekly': {
      'work': 15.0,
      'study': 12.5,
      'exercise': 3.5,
      'social': 8.0,
      'rest': 42.0,
    },
  };

  final Map<String, double> goals = {
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
                'Statistics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
            // Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 24),
            // Statistics Cards
            _buildStatsCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final currentData = statsData[isDaily ? 'daily' : 'weekly']!;
    final currentGoals = isDaily ? goals : weeklyGoals;
    final totalHours = currentData.values.reduce((a, b) => a + b);
    final totalGoalHours = currentGoals.values.reduce((a, b) => a + b);
    final completionPercentage = (totalHours / totalGoalHours * 100).clamp(
      0,
      100,
    );

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
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _buildToggleButton(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Hours',
                    '${totalHours.toStringAsFixed(1)}h',
                    Colors.blue,
                    Icons.access_time,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Completion',
                    '${completionPercentage.toStringAsFixed(0)}%',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => isDaily = !isDaily),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            ),
          );
        },
        child: Text(
          isDaily ? 'Daily' : 'Weekly',
          key: ValueKey<bool>(isDaily),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final currentData = statsData[isDaily ? 'daily' : 'weekly']!;
    final currentGoals = isDaily ? goals : weeklyGoals;

    final activities = [
      {
        'name': 'Work',
        'key': 'work',
        'icon': Icons.computer,
        'color': Colors.blue,
      },
      {
        'name': 'Study',
        'key': 'study',
        'icon': Icons.menu_book,
        'color': Colors.green,
      },
      {
        'name': 'Exercise',
        'key': 'exercise',
        'icon': Icons.fitness_center,
        'color': Colors.orange,
      },
      {
        'name': 'Social Time',
        'key': 'social',
        'icon': Icons.people,
        'color': Colors.purple,
      },
      {
        'name': 'Rest',
        'key': 'rest',
        'icon': Icons.bedtime,
        'color': Colors.indigo,
      },
    ];

    return Column(
      children: activities.map((activity) {
        final key = activity['key'] as String;
        final current = currentData[key]!;
        final goal = currentGoals[key]!;
        final percentage = (current / goal * 100).clamp(0, 100);
        final status = percentage >= 100
            ? 'Completed'
            : percentage >= 80
            ? 'Almost there'
            : percentage >= 50
            ? 'In progress'
            : 'Just started';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (activity['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          activity['icon'] as IconData,
                          color: activity['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 14,
                                color: percentage >= 80
                                    ? Colors.green
                                    : Colors.black54,
                                fontWeight: percentage >= 80
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${current.toStringAsFixed(1)}h',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'of ${goal.toStringAsFixed(0)}h',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      activity['color'] as Color,
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}% completed',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${(goal - current).toStringAsFixed(1)}h remaining',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
