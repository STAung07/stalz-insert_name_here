import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/src/features/dashboard/presentation/coach/coach_session_detail.dart';
import 'package:flutter_app/src/features/dashboard/presentation/student/student_session_detail.dart';


class SessionCard extends StatelessWidget {
  final TrainingSessionModel session;
  final String userId;
  final String userRole;
  final VoidCallback? onRefresh;

  const SessionCard({
    super.key,
    required this.session,
    required this.userId,
    required this.userRole,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          if (userRole == 'coach') {
            showDialog(
              context: context,
              builder: (context) => CoachSessionDetail(
                session: session,
                coachId: userId,
                onRefresh: onRefresh,
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => StudentSessionDetail(
                session: session,
                studentId: userId,
                onRefresh: onRefresh,
              ),
            );
          }
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
