import 'package:flutter_app/src/services/database_service.dart';

class AcademyService extends DatabaseService{
  AcademyService._internal() : super.internal();

  static final AcademyService _instance = AcademyService._internal();
  
  factory AcademyService() {
    return _instance;
   }


  Future<String?> getUserAcademy(String userId, String userRole) async {
    String tableName;
    String idColumnName;

    if (userRole == 'coach') {
      tableName = 'academy_coaches';
      idColumnName = 'coach_id';
    } else if (userRole == 'student') {
      tableName = 'academy_students';
      idColumnName = 'student_id';
    } else {
      return null; // Or throw an error for unsupported roles
    }

    final response = await supabase
        .from(tableName)
        .select('academy_id')
        .eq(idColumnName, userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['academy_id'] as String?;
  }


  Future<List<String>> getUsersFromSameAcademy(String academyId, String? userRole) async {
    List<String> userIds = [];

    if (userRole == 'coach' || userRole == null) {
      final coachesInSameAcademyResponse = await supabase
          .from('academy_coaches')
          .select('coach_id')
          .eq('academy_id', academyId);

      final List<String> coachIds = (coachesInSameAcademyResponse as List)
          .map((e) => e['coach_id'] as String)
          .toList();
      userIds.addAll(coachIds);
    }

    if (userRole == 'student' || userRole == null) {
      final studentsInSameAcademyResponse = await supabase
          .from('academy_students') // Corrected table name
          .select('student_id')
          .eq('academy_id', academyId);

      final List<String> studentIds = (studentsInSameAcademyResponse as List)
          .map((e) => e['student_id'] as String)
          .toList();
      userIds.addAll(studentIds);
    }

    return userIds;
  }

}