import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user_model.dart';

class StudentDashboardScreen extends StatelessWidget {
  final UserModel user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Column(
        children: [
          Text('Welcome, ${user.email}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to enrolled academies
            },
            child: const Text('My Academies'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to schedule
            },
            child: const Text('Training Schedule'),
          ),
        ],
      ),
    );
  }
}