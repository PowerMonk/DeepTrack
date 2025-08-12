import 'package:flutter/material.dart';
import '../widgets/progressbar.dart';

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
            color: Colors.blueAccent,
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
        CustomProgressBar(
          label: 'Work',
          current: currentData['work']!,
          goal: currentGoals['work']!,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Study',
          current: currentData['study']!,
          goal: currentGoals['study']!,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Exercise',
          current: currentData['exercise']!,
          goal: currentGoals['exercise']!,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Social Time',
          current: currentData['social']!,
          goal: currentGoals['social']!,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Rest',
          current: currentData['rest']!,
          goal: currentGoals['rest']!,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _buildActivityCards() {
    final activities = [
      {'name': 'Study', 'icon': Icons.book_outlined, 'color': Colors.green},
      {'name': 'Work', 'icon': Icons.computer_outlined, 'color': Colors.blue},
      {
        'name': 'Exercise',
        'icon': Icons.fitness_center_outlined,
        'color': Colors.orange,
      },
      {
        'name': 'Social Time',
        'icon': Icons.people_alt_outlined,
        'color': Colors.purple,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16.0), // Increased margin
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2, // Slightly increased aspect ratio
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
              transform: Matrix4.identity()
                ..scale(isActive ? 1.03 : 1.0), // Reduced scale
              child: Card(
                elevation: isActive ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isActive ? activity['color'] as Color : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // Reduced padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        activity['icon'] as IconData,
                        size: 40, // Slightly smaller icon
                        color: isActive
                            ? Colors.white
                            : activity['color'] as Color,
                      ),
                      const SizedBox(height: 8), // Reduced spacing
                      Text(
                        activityName,
                        style: TextStyle(
                          fontSize: 14, // Smaller font
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4), // Reduced spacing
                        const Text(
                          'Recording...',
                          style: TextStyle(
                            fontSize: 11, // Smaller font
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
      ),
    );
  }
}
