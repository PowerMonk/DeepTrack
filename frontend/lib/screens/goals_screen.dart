import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Default goals in hours
  Map<String, double> dailyGoals = {
    'work': 8.0,
    'study': 4.0,
    'exercise': 1.0,
    'social': 2.0,
    'rest': 8.0,
  };

  Map<String, double> weeklyGoals = {
    'work': 40.0,
    'study': 20.0,
    'exercise': 7.0,
    'social': 10.0,
    'rest': 56.0,
  };

  bool isEditMode = false;
  bool isHours = true; // true for hours, false for minutes

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

  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  String _formatTime(double hours) {
    if (isHours) {
      return '${hours.toStringAsFixed(hours == hours.toInt() ? 0 : 1)}h';
    } else {
      int minutes = (hours * 60).round();
      return '${minutes}m';
    }
  }

  void _adjustGoal(String key, bool isDaily, bool increase) {
    setState(() {
      double increment = isHours ? 0.5 : 15.0 / 60; // 15 minutes in hours

      if (isDaily) {
        if (increase) {
          dailyGoals[key] = dailyGoals[key]! + increment;
        } else if (dailyGoals[key]! > increment) {
          dailyGoals[key] = dailyGoals[key]! - increment;
        }
      } else {
        double weeklyIncrement = isHours
            ? 1.0
            : 30.0 / 60; // 30 minutes in hours
        if (increase) {
          weeklyGoals[key] = weeklyGoals[key]! + weeklyIncrement;
        } else if (weeklyGoals[key]! > weeklyIncrement) {
          weeklyGoals[key] = weeklyGoals[key]! - weeklyIncrement;
        }
      }
    });
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
                'DeepTrack',
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
            // Header with title and edit button
            _buildHeader(),
            const SizedBox(height: 16),
            // Time unit toggle
            _buildTimeUnitToggle(),
            const SizedBox(height: 24),
            // Goals cards
            _buildGoalsCards(),
            const SizedBox(height: 24),
            // Tips card
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Goals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: _toggleEditMode,
          child: isEditMode
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTimeUnitToggle() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Time Unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => isHours = !isHours),
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
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  isHours ? 'Hours' : 'Minutes',
                  key: ValueKey<bool>(isHours),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCards() {
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
        final dailyGoal = dailyGoals[key]!;
        final weeklyGoal = weeklyGoals[key]!;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (activity['color'] as Color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          activity['icon'] as IconData,
                          color: activity['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activity['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Daily Goal Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Goal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isEditMode)
                                  GestureDetector(
                                    onTap: () => _adjustGoal(key, true, false),
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                if (isEditMode) const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatTime(dailyGoal),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isEditMode) const SizedBox(width: 4),
                                if (isEditMode)
                                  GestureDetector(
                                    onTap: () => _adjustGoal(key, true, true),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Weekly Goal Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weekly Goal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isEditMode)
                                  GestureDetector(
                                    onTap: () => _adjustGoal(key, false, false),
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                if (isEditMode) const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatTime(weeklyGoal),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isEditMode) const SizedBox(width: 4),
                                if (isEditMode)
                                  GestureDetector(
                                    onTap: () => _adjustGoal(key, false, true),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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

  Widget _buildTipsCard() {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '• Start with small, achievable goals and gradually increase them\n'
              '• Be consistent with your tracking for better insights\n'
              '• Adjust your goals based on your lifestyle and commitments\n'
              '• Remember that rest is just as important as productivity\n'
              '• Review and update your goals weekly for optimal results',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
