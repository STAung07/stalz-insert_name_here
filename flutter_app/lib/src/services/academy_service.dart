import 'package:flutter_app/src/services/database_service.dart';

class AcademyService extends DatabaseService {
  AcademyService._internal() : super.internal();

  static final AcademyService _instance = AcademyService._internal();

  factory AcademyService() {
    return _instance;
  }

  Future<List<Map<String, dynamic>>> fetchAcademies() async {
    final response = await supabase
        .from('academies')
        .select('id, name');
    // Optionally, validate response here using checkResponse if needed
    print('Fetched academies from Service: $response');
    return List<Map<String, dynamic>>.from(response);
  }
  Future<void> addCoachToAcademy(String academyId, String coachId) async {
    final response = await supabase
        .from('academy_coaches')
        .insert({'academy_id': academyId, 'coach_id': coachId});
    await checkResponse(response);
  }

  Future<void> addStudentToAcademy(String academyId, String studentId) async {
    final response = await supabase
        .from('academy_students')
        .insert({'academy_id': academyId, 'student_id': studentId});
    await checkResponse(response);
  }
  // Add other academy-specific operations here
}