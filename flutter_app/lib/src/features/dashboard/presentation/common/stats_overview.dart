import 'package:flutter/material.dart';


import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:flutter_app/src/models/user_model.dart';

class StatsOverview extends StatefulWidget {
  final UserModel user;
  const StatsOverview({super.key, required this.user});

  @override
  State<StatsOverview> createState() => StatsOverviewState();
}

class StatsOverviewState extends State<StatsOverview> {
  int _sessionsToday = 0;
  int _sessionsThisWeek = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSessionStats();
  }

  Future<void> fetchSessionStats() async {
    setState(() {
      _isLoading = true;
    });

    final trainingSessionService = TrainingSessionService();
    final now = DateTime.now();

    // Sessions Today
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final sessionsToday = await trainingSessionService.getSessionsByUserIdAndDateRange(
      widget.user.id,
      widget.user.role,
      startOfDay,
      endOfDay,
    );

    // Sessions This Week (Monday to Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    final sessionsThisWeek = await trainingSessionService.getSessionsByUserIdAndDateRange(
      widget.user.id,
      widget.user.role,
      startOfWeek,
      endOfWeek,
    );

    setState(() {
      _sessionsToday = sessionsToday.length;
      _sessionsThisWeek = sessionsThisWeek.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatTile('Sessions Today', _sessionsToday.toString()),
              _buildStatTile('This Week', _sessionsThisWeek.toString()),
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
