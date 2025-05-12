import 'package:flutter/material.dart';

// Extended by coach and student screens; Main dashboard screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Welcome to CoachConnect Dashboard')),
    );
  }
}