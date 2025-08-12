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
    'exercise': 5.0,
    'social': 10.0,
    'rest': 56.0,
  };

  bool isEditMode = false;

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
    return '${hours.toStringAsFixed(hours == hours.toInt() ? 0 : 1)} hours';
  }

  void _adjustGoal(String key, bool isDaily, bool increase) {
    setState(() {
      double increment = 0.5;

      if (isDaily) {
        if (increase) {
          dailyGoals[key] = dailyGoals[key]! + increment;
        } else if (dailyGoals[key]! > increment) {
          dailyGoals[key] = dailyGoals[key]! - increment;
        }
      } else {
        double weeklyIncrement = 1.0;
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
          child: Row(
            children: [
              // Add bat icon to the app bar
              Image.asset('assets/images/baticon.png', height: 32, width: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'DeepTrack',
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
            const SizedBox(height: 24),
            // Goals cards
            _buildGoalsCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
                      color: Colors.black,
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
                      color: Colors.black,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCards() {
    final activities = [
      {
        'name': 'Study',
        'key': 'study',
        'icon': Icons.book_outlined,
        'color': Colors.green,
      },
      {
        'name': 'Work',
        'key': 'work',
        'icon': Icons.computer_outlined,
        'color': Colors.blue,
      },
      {
        'name': 'Exercise',
        'key': 'exercise',
        'icon': Icons.fitness_center_outlined,
        'color': Colors.orange,
      },
      {
        'name': 'Rest',
        'key': 'rest',
        'icon': Icons.hotel_outlined,
        'color': Colors.black,
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
                      Icon(
                        activity['icon'] as IconData,
                        color: activity['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activity['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                if (isEditMode) const SizedBox(width: 8),
                                Text(
                                  _formatTime(dailyGoal),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (isEditMode) const SizedBox(width: 8),
                                if (isEditMode)
                                  GestureDetector(
                                    onTap: () => _adjustGoal(key, true, true),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                if (isEditMode) const SizedBox(width: 8),
                                Text(
                                  _formatTime(weeklyGoal),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (isEditMode) const SizedBox(width: 8),
                                if (isEditMode)
                                  GestureDetector(
                                    onTap: () => _adjustGoal(key, false, true),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.black,
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
}
