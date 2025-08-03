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

  Future<List<TrainingSessionModel>> getSessionsBySessionIds(List<String> sessionIds, int days) async {
    final DateTime queryEndDate = DateTime.now().add(Duration(days: days));
    if (sessionIds.isEmpty) {
      return [];
    }
    final response = await supabase
        .from('training_sessions')
        .select()
        .in_('id', sessionIds)
        .gte('start_time', DateTime.now().toIso8601String())
        .lte('start_time', queryEndDate.toIso8601String());
    List<TrainingSessionModel> sessions = response.map<TrainingSessionModel>((sessionData) => TrainingSessionModel.fromMap(sessionData)).toList();
    return sessions;
  }

  // TrainingSessionModel buildSessionModel (String title, String academyId, String description, DateTime startTime, DateTime endTime, String location) {
  //   return TrainingSessionModel(
  //     title: title,
  //     academyId: academyId,
  //     startTime: startTime,
  //     endTime: endTime,
  //     location: location,
  //   );
  // }

  Future<void> upsertSession(TrainingSessionModel session, String coachId) async {
    final sessionResponse = await supabase
      .from('training_sessions')
      .upsert(session.toJsonMap(session))
      .select()
      .single();
    // Insert coach-session relationship
    await supabase
      .from('session_coaches')
      .insert({
        'session_id': sessionResponse['id'],
        'coach_id': coachId
      });
  }
}