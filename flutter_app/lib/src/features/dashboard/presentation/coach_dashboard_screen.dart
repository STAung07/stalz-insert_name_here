import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user_model.dart';

class CoachDashboardScreen extends StatelessWidget {
  final UserModel user;

  const CoachDashboardScreen({super.key, required this.user});

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
              'Hi, ${user.name}',
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
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: 3, // todo: Replace with actual sessions count
                      itemBuilder: (context, index) => const SessionCard(),
                    ),
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

// Helper Widgets
class SessionCard extends StatelessWidget {
  const SessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const Icon(Icons.sports),
        title: const Text('Training Session'),
        subtitle: const Text('10:00 AM - 11:00 AM'),
        trailing: const Text('Today'),
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