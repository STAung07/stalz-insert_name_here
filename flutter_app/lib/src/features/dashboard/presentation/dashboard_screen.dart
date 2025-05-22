import 'package:flutter/material.dart';

import '../../auth/data/auth_service.dart'; // Assuming you have an AuthService for handling authentication
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final auth = AuthService(); // Assuming you have an AuthService for handling authentication
  bool loading = false;

  void _signOut(BuildContext context) async {
    setState(() {
      loading = true;
    });
    // Simulate a delay for sign-out process
    Future.delayed(const Duration(seconds: 1), () async {

      setState(() {
        loading = false;
      });
      await auth.signOut();
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          Text('Welcome to CoachConnect Dashboard'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: loading ? null : () => _signOut(context),
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}

