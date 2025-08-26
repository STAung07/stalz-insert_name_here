import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/services/user_service.dart';
import 'coach_profile_screen.dart';
import 'student_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

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
              // You may need to fetch academyId for coach here if not in user
              // return CoachProfileScreen(coachId: user.id, academyId: user.academy);
              return CoachProfileScreen(user: user);
            case 'student':
              // You may need to fetch academyId for student here if not in user
              //return StudentProfileScreen(studentId: user.id);
              return StudentProfileScreen(user: user);
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