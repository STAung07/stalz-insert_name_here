import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/dashboard/presentation/common/session_card.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/services/training_session_service.dart';

class SessionList extends StatefulWidget {
  final String userId;
  final String userRole;
  const SessionList({super.key, required this.userId,required this.userRole});

  @override
  SessionListState createState() => SessionListState();
}

class SessionListState extends State<SessionList> {
  late Future<List<TrainingSessionModel>> _futureSessions;

  @override
  void initState() {
    super.initState();
    _futureSessions = fetchSessions(widget.userId, widget.userRole);
  }

  Future<List<TrainingSessionModel>> fetchSessions(String userId, userRole) async {
    print("userId: $userId, userRole: $userRole");
    TrainingSessionService sessionService = TrainingSessionService();
    final sessionIdsResponse = await sessionService.getSessionsIdsByUserId(
      userId, userRole
    );
    final sessionsResponse = await sessionService.getSessionsBySessionIds(
      sessionIdsResponse,
      7,
    );
    print("sessions: $sessionsResponse");
    
    // Sort sessions by start time and date
    sessionsResponse.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sessionsResponse;
  }

  void refreshSessions() {
    setState(() {
      _futureSessions = fetchSessions(widget.userId, widget.userRole);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrainingSessionModel>>(
      future: _futureSessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No sessions available');
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: min(snapshot.data!.length, 5),
            itemBuilder: (context, index) {
              final session = snapshot.data![index];
              print("SESSION ID: ");
              print( session.sessionId);
              return SessionCard(
                session: session,
                userId: widget.userId,
                userRole: widget.userRole,
                onRefresh: refreshSessions, // 
              );
            },
          );
        }
      },
    );
  }
}
