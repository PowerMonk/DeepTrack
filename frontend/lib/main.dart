import 'package:flutter/material.dart';
import 'widgets/navbar.dart';

void main() {
  runApp(const DeepTrackApp());
}

class DeepTrackApp extends StatelessWidget {
  const DeepTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
