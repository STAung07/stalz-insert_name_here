import 'package:flutter/material.dart';


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
