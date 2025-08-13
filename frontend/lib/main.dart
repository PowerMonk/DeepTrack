import 'package:flutter/material.dart';
import 'widgets/navbar.dart';
import 'services/background_service.dart';
import 'services/workmanager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize workmanager for daily SQLite uploads
  await WorkManagerService.initialize();

  runApp(const DeepTrackApp());

  // Start background service for daily data transfers
  BackgroundService.start();
}

class DeepTrackApp extends StatelessWidget {
  const DeepTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
