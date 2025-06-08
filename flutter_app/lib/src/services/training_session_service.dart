import 'package:flutter_app/src/models/session_coach_model.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/services/database_service.dart';

class TrainingSessionService extends DatabaseService{
  TrainingSessionService._internal() : super.internal();

  static final TrainingSessionService _instance = TrainingSessionService._internal();
  
  factory TrainingSessionService() {
    return _instance;
  }
  Future<List<String>> getSessionsIdsByCoachId(String coachId) async {
    final response = await supabase
    .from('session_coaches')
    .select('session_id')
    .eq('coach_id', coachId);

  // todo: might need to validate response -> await check response
    List<String> sessionIds = response.map<String>((e) => e['session_id'].toString()).toList();
    print(sessionIds); // Print the response to check its contents

    return sessionIds;
  }

  Future<List<TrainingSessionModel>> getSessionsBySessionIds(List<String> sessionIds) async {
    final response = await supabase
        .from('training_sessions')
        .select()
        .in_('id', sessionIds);
    List<TrainingSessionModel> sessions = response.map<TrainingSessionModel>((sessionData) => TrainingSessionModel.fromMap(sessionData)).toList();
    return sessions;
  }

  // Add other user-specific operations
}