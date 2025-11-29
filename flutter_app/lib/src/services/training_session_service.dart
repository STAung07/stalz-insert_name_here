import 'package:flutter_app/src/models/training_session_model.dart';

import 'package:flutter_app/src/services/database_service.dart';

class TrainingSessionService extends DatabaseService{
  TrainingSessionService._internal() : super.internal();

  static final TrainingSessionService _instance = TrainingSessionService._internal();
  
  factory TrainingSessionService() {
    return _instance;
  }
  Future<List<String>> getSessionsIdsByUserId(String userId, String userRole) async {
    dynamic response;

    if (userRole == 'coach') {
      response = await supabase
      .from('session_coaches')
      .select('session_id')
      .eq('coach_id', userId);
    } else {
      response = await supabase
      .from('session_attendance')
      .select('session_id')
      .eq('student_id', userId);
    }

  // todo: might need to validate response -> await check response
    List<String> sessionIds = response.map<String>((e) => e['session_id'].toString()).toList();

    return sessionIds;
  }

  Future<List<TrainingSessionModel>> getSessionsBySessionIdsAndDays(List<String> sessionIds, int days) async {
    final DateTime queryEndDate = DateTime.now().add(Duration(days: days));
    if (sessionIds.isEmpty) {
      return [];
    }
    final response = await supabase
        .from('training_sessions')
        .select()
        .in_('id', sessionIds)
        .gte('end_time', DateTime.now().toIso8601String())
        .lte('start_time', queryEndDate.toIso8601String());
    List<TrainingSessionModel> sessions = response.map<TrainingSessionModel>((sessionData) => TrainingSessionModel.fromMap(sessionData)).toList();
    return sessions;
  }

  Future<List<TrainingSessionModel>> getAllTrainingSessionsByUserId(String userId, String userRole) async {
    TrainingSessionService sessionService = TrainingSessionService();
    final sessionIds = await sessionService.getSessionsIdsByUserId(
      userId, userRole
    );
    if (sessionIds.isEmpty) {
      return [];
    }

    final response = await supabase
        .from('training_sessions')
        .select()
        .in_('id', sessionIds);
    List<TrainingSessionModel> sessions = response.map<TrainingSessionModel>((sessionData) => TrainingSessionModel.fromMap(sessionData)).toList();
    return sessions;
  }

  Future<List<TrainingSessionModel>> getSessionsByUserIdAndDateRange(String userId, String userRole, DateTime startDate, DateTime endDate) async {
    final sessionIds = await getSessionsIdsByUserId(userId, userRole);
    if (sessionIds.isEmpty) {
      return [];
    }

    final response = await supabase
        .from('training_sessions')
        .select()
        .in_('id', sessionIds)
        .gte('start_time', startDate.toIso8601String())
        .lte('start_time', endDate.toIso8601String());

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
  // 

  // Create a training session after saving add session form
  Future<void> createTrainingSession(TrainingSessionModel session, String coachId, List<String> studentIds) async {      
      final trainingSessionResponse = await upsertTrainingSession(session);
      if (trainingSessionResponse == null) return;
      final sessionId = trainingSessionResponse['id'];
      // final academyId = await AcademyService().getUserAcademy(coachId, 'coach');
      // List<String> coachIds = [];
      // if (academyId == null) {
      //   coachIds = [coachId];
      // } else {
      //   coachIds = await AcademyService().getUsersFromSameAcademy(academyId, 'coach');
      // }
      print(studentIds);
      await upsertUserSession(sessionId, coachId, 'coach');
      // await batchUpsertUserSession(sessionId, coachIds, 'coach');
      await batchUpsertUserSession(sessionId, studentIds, 'student');
  }

  Future<dynamic> upsertTrainingSession(TrainingSessionModel session) async {
    final sessionResponse = await supabase
      .from('training_sessions')
      .upsert(session.toJsonMap(session))
      .select()
      .single();
    return sessionResponse;
  }
//sessionResponse['id']

  Future<void> upsertUserSession(String sessionId, String userId, String userRole) async {
    // dynamic response;
    if (userRole == 'coach') {
      await supabase
      .from('session_coaches')
      .upsert({
        'session_id': sessionId,
        'coach_id': userId
      });
    } else {
      await supabase
      .from('session_attendance')
      .upsert({
        'session_id': sessionId,
        'student_id': userId
      });
    }
  }

    Future<void> batchUpsertUserSession(String sessionId, List<String> userIds, String userRole) async {
      if (userIds.isEmpty) return;
      
      if (userRole == 'coach') {
        // Create a list of records to insert
        final List<Map<String, dynamic>> records = userIds.map((userId) => {
          'session_id': sessionId,
          'coach_id': userId
        }).toList();
        
        await supabase
          .from('session_coaches')
          .upsert(records);
      } else {
        // Create a list of records to insert for students
        final List<Map<String, dynamic>> records = userIds.map((userId) => {
          'session_id': sessionId,
          'student_id': userId
        }).toList();
        
        await supabase
          .from('session_attendance')
          .upsert(records);
      }
    }

    Future<void> deleteTrainingSession(String sessionId) async {
      await supabase
        .from('training_sessions')
        .delete()
        .eq('id', sessionId);

      await supabase
        .from('session_coaches')
        .delete()
        .eq('session_id', sessionId);

      await supabase
        .from('session_attendance')
        .delete()
        .eq('session_id', sessionId);
    }

    Future<void> updateAttendanceCount(String sessionId) async {
      final response = await supabase
          .from('session_attendance')
          .select('student_id')
          .eq('session_id', sessionId)
          .eq('status', 'Yes');

      final attendanceCount = response.length;

      await supabase
          .from('training_sessions')
          .update({'attendance_count': attendanceCount})
          .eq('id', sessionId);
    }
}