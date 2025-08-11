import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDaily = true;
  String? activeActivity;
  DateTime? startTime;

  // Mock data for progress
  final Map<String, Map<String, double>> progressData = {
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

  void _toggleActivity(String activity) {
    setState(() {
      if (activeActivity == activity) {
        // Stop recording
        activeActivity = null;
        startTime = null;
      } else {
        // Start recording
        activeActivity = activity;
        startTime = DateTime.now();
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
            // Progress Card
            _buildProgressCard(),
            const SizedBox(height: 24),
            // Activity Cards
            _buildActivityCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
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
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                _buildToggleButton(),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBars(),
          ],
        ),
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
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    final currentData = progressData[isDaily ? 'daily' : 'weekly']!;
    final currentGoals = isDaily ? goals : weeklyGoals;

    return Column(
      children: [
        _buildProgressBar(
          'Work',
          currentData['work']!,
          currentGoals['work']!,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildProgressBar(
          'Study',
          currentData['study']!,
          currentGoals['study']!,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildProgressBar(
          'Exercise',
          currentData['exercise']!,
          currentGoals['exercise']!,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildProgressBar(
          'Social Time',
          currentData['social']!,
          currentGoals['social']!,
          Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildProgressBar(
          'Rest',
          currentData['rest']!,
          currentGoals['rest']!,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    String label,
    double current,
    double goal,
    Color color,
  ) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)}h / ${goal.toStringAsFixed(0)}h',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildActivityCards() {
    final activities = [
      {'name': 'Study', 'icon': Icons.menu_book, 'color': Colors.green},
      {'name': 'Work', 'icon': Icons.computer, 'color': Colors.blue},
      {
        'name': 'Exercise',
        'icon': Icons.fitness_center,
        'color': Colors.orange,
      },
      {'name': 'Social Time', 'icon': Icons.people, 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final activityName = activity['name'] as String;
        final isActive =
            activeActivity == activityName.toLowerCase().replaceAll(' ', '');

        return GestureDetector(
          onTap: () =>
              _toggleActivity(activityName.toLowerCase().replaceAll(' ', '')),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(isActive ? 1.05 : 1.0),
            child: Card(
              elevation: isActive ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isActive ? activity['color'] as Color : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      activity['icon'] as IconData,
                      size: 48,
                      color: isActive
                          ? Colors.white
                          : activity['color'] as Color,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activityName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Recording...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
