import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/src/features/dashboard/presentation/common/session_list.dart';
import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/services/academy_service.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'coach/add_session_form.dart';
import 'common/action_button.dart';
import 'common/session_card.dart';
import 'common/stats_overview.dart';

class StudentDashboardScreen extends StatefulWidget {
  final UserModel user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  StudentDashboardScreenState createState() => StudentDashboardScreenState();
}

class StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GlobalKey<SessionListState> _sessionListKey =
      GlobalKey<SessionListState>();
  final GlobalKey<StatsOverviewState> _statsOverviewKey = GlobalKey<StatsOverviewState>();
  final auth =
      AuthService(); // Assuming you have an AuthService for handling authentication

  bool loading = false;


  void _signOut(BuildContext context) async {
    setState(() {
      loading = true;
    });
    // Set autoLogin to false in secure storage
  final storage = FlutterSecureStorage();
  await storage.write(key: 'autoLogin', value: 'false');
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
                    SessionList(
                      key: _sessionListKey,
                      userId: widget.user.id,
                      userRole: widget.user.role,
                    ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Stats Overview',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Refresh stats',
                          onPressed: () {
                            _statsOverviewKey.currentState?.fetchSessionStats();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Add your stats widgets here
                    StatsOverview(key: _statsOverviewKey, user: widget.user),
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
          if (index == 0) {
            context.go('/dashboard');
          } else if (index == 1) {
            context.go(
              '/calendar',
              extra: {
                'userId': widget.user.id,
                'userRole': widget.user.role,
                'academyId': widget.user.academy,
              },
            );
          } else if (index == 2) {
            context.go(
              '/profile',
              extra: {
                'userId': widget.user.id,
              },
            );
          }
        },
      ),
    );
  }
}
