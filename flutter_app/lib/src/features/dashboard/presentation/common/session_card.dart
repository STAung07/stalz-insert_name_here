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
    double opacity = 1.0;
    if (session.bookingStatus == 'Tentative') {
      opacity = 0.5; // Adjust as needed for desired transparency
    }

    return Opacity(
      opacity: opacity,
      child: Card(
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
            ); // Correct closing for showDialog
          } else {
            showDialog(
              context: context,
              builder: (context) => StudentSessionDetail(
                session: session,
                studentId: userId,
                onRefresh: onRefresh,
              ),
            ); // Correct closing for showDialog
          }
        },
        child: ListTile(
          leading: Builder(
            builder: (context) {
              IconData iconData;
              Color iconColor;
              switch (session.bookingStatus) {
                case 'Cancelled':
                  iconData = Icons.close;
                  iconColor = Colors.red;
                  break;
                case 'Tentative':
                  iconData = Icons.remove;
                  iconColor = Colors.grey;
                  break;
                case 'Booked':
                  iconData = Icons.check;
                  iconColor = Colors.green;
                  break;
                default:
                  iconData = Icons.sports;
                  iconColor = Theme.of(context).iconTheme.color ?? Colors.black; // Default color
              }
              return Icon(iconData, color: iconColor);
            },
          ),
          title: Text(session.title),
          subtitle: Text('${DateFormat.jm().format(session.startTime)} - ${DateFormat.jm().format(session.endTime) }'),
          trailing: Text('${session.startTime.day} ${DateFormat("MMMM").format(session.startTime)}'),
        ),
      ), // Closes InkWell
    ), // Closes Card
  ); // Closes Opacity
  }
}
