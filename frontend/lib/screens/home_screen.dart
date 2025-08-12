import 'package:flutter/material.dart';
import '../widgets/progressbar.dart';
import '../services/time_tracking_service.dart';
import '../services/goals_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDaily = true;
  String? activeActivity;
  DateTime? startTime;
  Map<String, int> dailyData = {
    'work': 0,
    'study': 0,
    'exercise': 0,
    'social': 0,
    'rest': 0,
  };
  Map<String, double> dailyGoals = {};
  Map<String, double> weeklyGoals = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentActivity();
    _loadDailyData();
    _loadGoals();
    TimeTrackingService.checkAndSaveToDatabaseIfNeeded();
  }

  Future<void> _loadGoals() async {
    final daily = await GoalsService.getDailyGoalsHours();
    final weekly = await GoalsService.getWeeklyGoalsHours();
    if (mounted) {
      setState(() {
        dailyGoals = daily;
        weeklyGoals = weekly;
      });
    }
  }

  Future<void> _debugPrintData() async {
    final data = await TimeTrackingService.getDailyData();
    final current = await TimeTrackingService.getCurrentActivity();
    print('=== DEBUG INFO ===');
    print('Current Activity: $current');
    print('Daily Data: $data');
    print('Daily Hours: $dailyHours');
    print('=================');
  }

  Future<void> _loadCurrentActivity() async {
    final current = await TimeTrackingService.getCurrentActivity();
    if (mounted) {
      setState(() {
        activeActivity = current;
      });
    }
    print('Loaded current activity: $current');
  }

  Future<void> _loadDailyData() async {
    final data = await TimeTrackingService.getDailyData();
    if (mounted) {
      setState(() {
        dailyData = data;
      });
    }
    print('Loaded daily data: $data');
  }

  // Convert minutes to hours for display
  Map<String, double> get dailyHours {
    return dailyData.map(
      (key, value) => MapEntry(key, TimeTrackingService.minutesToHours(value)),
    );
  }

  // Weekly data (multiply daily by 7 for now - you can implement proper weekly tracking later)
  Map<String, double> get weeklyHours {
    return dailyHours.map((key, value) => MapEntry(key, value * 7));
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

  Future<void> _toggleActivity(String activity) async {
    print('=== BUTTON PRESSED: $activity ===');

    if (activeActivity == activity) {
      // Stop current activity
      print('Stopping current activity: $activity');
      await TimeTrackingService.stopCurrentActivity();
      setState(() {
        activeActivity = null;
        startTime = null;
      });
      print('Activity stopped successfully');
    } else {
      // Start new activity (this will stop any current activity first)
      print('Starting new activity: $activity');
      await TimeTrackingService.startActivity(activity);
      setState(() {
        activeActivity = activity;
        startTime = DateTime.now();
      });
      print('Activity started at: ${DateTime.now()}');
    }

    // Reload daily data to show updated progress
    await _loadDailyData();
    await _debugPrintData();
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
            // Debug info card (remove this later)
            if (activeActivity != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'DEBUG: Currently tracking $activeActivity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Started at: ${startTime?.toString() ?? "Unknown"}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Minutes tracked today: ${dailyData.values.reduce((a, b) => a + b)}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
    final currentData = isDaily ? dailyHours : weeklyHours;
    final currentGoals = isDaily ? dailyGoals : weeklyGoals;

    return Column(
      children: [
        CustomProgressBar(
          label: 'Work',
          current: currentData['work'] ?? 0.0,
          goal: currentGoals['work'] ?? 8.0,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Study',
          current: currentData['study'] ?? 0.0,
          goal: currentGoals['study'] ?? 4.0,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Exercise',
          current: currentData['exercise'] ?? 0.0,
          goal: currentGoals['exercise'] ?? 1.0,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Social Time',
          current: currentData['social'] ?? 0.0,
          goal: currentGoals['social'] ?? 2.0,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        CustomProgressBar(
          label: 'Rest',
          current: currentData['rest'] ?? 0.0,
          goal: currentGoals['rest'] ?? 8.0,
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
      {'name': 'Rest', 'icon': Icons.hotel_outlined, 'color': Colors.black},
    ];

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final activityName = activity['name'] as String;
          final isActive =
              activeActivity == activityName.toLowerCase().replaceAll(' ', '');

          return GestureDetector(
            onTap: () async => await _toggleActivity(
              activityName.toLowerCase().replaceAll(' ', ''),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isActive ? 1.03 : 1.0),
              child: Card(
                elevation: isActive ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isActive ? activity['color'] as Color : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        activity['icon'] as IconData,
                        size: 40,
                        color: isActive
                            ? Colors.white
                            : activity['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activityName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Recording...',
                          style: TextStyle(
                            fontSize: 11,
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
