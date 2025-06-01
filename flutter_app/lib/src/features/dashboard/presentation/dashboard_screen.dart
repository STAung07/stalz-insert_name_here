import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/services/user_service.dart';
import 'coach_dashboard_screen.dart';
import 'student_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;

  const DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserService().getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
           return Scaffold(
            body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          switch (user.role) {
            case 'coach':
              return CoachDashboardScreen(user: user);
            case 'student':
              return StudentDashboardScreen(user: user);
            default:
              return const Scaffold(
                body: Center(child: Text('Unknown role')),
              );
          }
        } else {
          return const Scaffold(
            body: Center(child: Text('No user data available')),
          );
        }
      },
    );
  }
}