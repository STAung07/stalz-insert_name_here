import 'package:flutter_app/src/services/database_service.dart';

class AcademyService extends DatabaseService {
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
  
  Future<String> fetchAcademyIdsForCoach(String coachId) async {
    final response = await supabase
        .from('academy_coaches')
        .select('academy_id')
        .eq('coach_id', coachId)
        .limit(1)
        .single();

    // Return a list of academy IDs
    //return List<String>.from(response.map((row) => row['academy_id']));
    return response['academy_id'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchAcademies() async {
    final response = await supabase
        .from('academies')
        .select('id, name');
    // Optionally, validate response here using checkResponse if needed

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchStudentsInAcademy(String academyId) async {
    final response = await supabase
        .from('academy_students')
        .select('student_id, users(full_name, role)')
        .eq('academy_id', academyId);

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

  // Sub-Group: Academy Management CRUD
  Future<String> createSubgroup(String academyId, String name) async {
    final response = await supabase
        .from('academy_subgroups')
        .insert({'academy_id': academyId, 'name': name})
        .select('id')
        .single();
    return response['id'] as String;
  }

  Future<void> deleteSubgroup(String subgroupId) async {
    await supabase.from('academy_subgroups').delete().eq('id', subgroupId);
  }

  Future<void> addStudentsToSubgroup(String subgroupId, List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    final inserts = studentIds.map((id) => {
      'subgroup_id': subgroupId,
      'student_id': id,
    }).toList();
    await supabase.from('subgroup_students').insert(inserts);
  }

  Future<void> addStudentToSubgroup(String subgroupId, String studentId) async {
    await supabase.from('subgroup_students').insert({
      'subgroup_id': subgroupId,
      'student_id': studentId,
    });
  }

  Future<void> removeStudentFromSubgroup(String subgroupId, String studentId) async {
    await supabase.from('subgroup_students')
        .delete()
        .eq('subgroup_id', subgroupId)
        .eq('student_id', studentId);
  }

  Future<void> moveStudentToSubgroup(String? oldSubgroupId, String? newSubgroupId, String studentId) async {
    if (oldSubgroupId != null && oldSubgroupId.isNotEmpty) {
      await removeStudentFromSubgroup(oldSubgroupId, studentId);
    }
    if (newSubgroupId != null && newSubgroupId.isNotEmpty) {
      await addStudentToSubgroup(newSubgroupId, studentId);
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubgroupsFromAcademy(String academyId) async {
    final response = await supabase
        .from('academy_subgroups')
        .select('id, name')
        .eq('academy_id', academyId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchStudentsInSubgroup(String subgroupId) async {
    final response = await supabase
        .from('subgroup_students')
        .select('student_id, users(full_name, role)')
        .eq('subgroup_id', subgroupId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchUnassignedStudents(String academyId) async {
    // Get all students in academy
    final allStudents = await supabase
        .from('academy_students')
        .select('student_id, users(full_name, role)')
        .eq('academy_id', academyId);

    // Get all assigned students
    final assigned = await supabase
        .from('subgroup_students')
        .select('student_id');

    final assignedIds = assigned.map((s) => s['student_id']).toSet();
    final unassigned = allStudents.where((s) => !assignedIds.contains(s['student_id'])).toList();
    return List<Map<String, dynamic>>.from(unassigned);
  }
}