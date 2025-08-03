import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/auth/data/auth_service.dart';
import 'package:flutter_app/src/features/dashboard/presentation/widgets/session_list.dart';
import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'widgets/add_session_form.dart';
import 'widgets/action_button.dart';
import 'widgets/session_card.dart';
import 'widgets/stats_overview.dart';

class CoachDashboardScreen extends StatefulWidget {
  final UserModel user;

  const CoachDashboardScreen({super.key, required this.user});

  @override
  CoachDashboardScreenState createState() => CoachDashboardScreenState();
}

class CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final GlobalKey<SessionListState> _sessionListKey =
      GlobalKey<SessionListState>();
  final auth =
      AuthService(); // Assuming you have an AuthService for handling authentication
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Hi, ${widget.user.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  icon: Icons.add_chart,
                  label: 'Create Session',
                  onTap: () {
                    // Navigate to create session
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final screenSize = MediaQuery.of(context).size;
                        return AlertDialog(
                          title: Text('Add New Session'),
                          content: SizedBox(
                            width: screenSize.width, // 80% of screen width
                            height:
                                screenSize.height * 0.7, // 70% of screen height
                            child: AddSessionForm(
                              onSessionCreated: () async {
                                await Future.delayed(
                                  Duration(milliseconds: 500),
                                );
                                _sessionListKey.currentState?.refreshSessions();
                              },
                              coachId: widget.user.id,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.bar_chart,
                  label: 'View Stats',
                  onTap: () {
                    // Navigate to stats
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upcoming Sessions Card
            // TODO: sort the sessions in ascending order
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Upcoming Sessions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Refresh sessions',
                          onPressed: () {
                            final currentState = _sessionListKey.currentState;
                            if (currentState is SessionListState) {
                              currentState.refreshSessions();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SessionList(key: _sessionListKey, coachId: widget.user.id),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stats Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    // Add your stats widgets here
                    const StatsOverview(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: loading ? null : () => _signOut(context),
                child:
                    loading
                        ? const CircularProgressIndicator()
                        : const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
