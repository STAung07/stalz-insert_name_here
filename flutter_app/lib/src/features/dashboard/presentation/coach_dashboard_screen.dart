import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/auth/data/auth_service.dart';
import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';



class CoachDashboardScreen extends StatefulWidget {
  final UserModel user;

  const CoachDashboardScreen({super.key, required this.user});

  @override
  CoachDashboardScreenState createState() => CoachDashboardScreenState();

}

class CoachDashboardScreenState extends State<CoachDashboardScreen> {
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

            // Upcoming Sessions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Sessions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    SessionList(coachId: widget.user.id,),
                  ],
                ),
              ),
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
                  label: 'Create Plan',
                  onTap: () {
                    // Navigate to create plan
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}


class SessionList extends StatefulWidget {
  final String coachId;
  const SessionList({super.key, required this.coachId});

  @override
  _SessionListState createState() => _SessionListState();
}
class _SessionListState extends State<SessionList> {
  Future<List<TrainingSessionModel>> fetchSessions(String coachId) async {
    print("coachId: $coachId");
    TrainingSessionService sessionService = TrainingSessionService();
    final sessionIdsResponse = await sessionService.getSessionsIdsByCoachId(coachId);
    final sessionsResponse = await sessionService.getSessionsBySessionIds(sessionIdsResponse);
    print("sessions: $sessionsResponse");
    return sessionsResponse;
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrainingSessionModel>>(
      future: fetchSessions(widget.coachId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: $snapshot');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No sessions available');
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: min(snapshot.data!.length, 3),
            itemBuilder: (context, index) {
              final session = snapshot.data![index];
              return SessionCard(session: session);
            },
          );
        }
      },
    );
  }
}


class SessionCard extends StatelessWidget {
  final TrainingSessionModel session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          print("tapped");
        },
        child: ListTile(
          leading: const Icon(Icons.sports),
          title: Text(session.title),
          subtitle: Text('${DateFormat.jm().format(session.startTime)} - ${DateFormat.jm().format(session.endTime) }'),
          trailing: Text('${session.startTime.day} ${DateFormat("MMMM").format(session.startTime)}'),
        ),
      ),
      );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatTile('Active Students', '24'),
        _buildStatTile('Sessions Today', '5'),
        _buildStatTile('This Week', '28'),
      ],
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}



