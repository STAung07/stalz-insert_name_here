import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/dashboard/presentation/widgets/session_card.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/services/training_session_service.dart';


class SessionList extends StatefulWidget {
  final String coachId;
  const SessionList({super.key, required this.coachId});

  @override
  SessionListState createState() => SessionListState();
}
class SessionListState extends State<SessionList> {
  
  Future<List<TrainingSessionModel>> fetchSessions(String coachId) async {
    print("coachId: $coachId");
    TrainingSessionService sessionService = TrainingSessionService();
    final sessionIdsResponse = await sessionService.getSessionsIdsByCoachId(coachId);
    final sessionsResponse = await sessionService.getSessionsBySessionIds(sessionIdsResponse, 7);
    print("sessions: $sessionsResponse");
    return sessionsResponse;
}

  void refreshSessions() {
    setState(() {
      fetchSessions(widget.coachId);
    });
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
            itemCount: min(snapshot.data!.length, 5),
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





