import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/models/student_group_model.dart';
import 'package:flutter_app/src/services/database_service.dart';
import 'package:flutter_app/src/services/academy_service.dart';

class StudentService extends DatabaseService {
  StudentService._internal() : super.internal();

  static final StudentService _instance = StudentService._internal();
  
  factory StudentService() {
    return _instance;
  }

  /// Get all students
  /// Returns a list of UserModel objects
  Future<List<UserModel>> getAllStudents() async {
    try {
      var response = await supabase
          .from('users')
          .select('*')
          .eq('role', 'student');
      
      return List<UserModel>.from(
        List<dynamic>.from(response).map((user) => UserModel.fromMap(user))
      );
    } catch (e) {
 
      throw Exception('Error getting all students: $e');
    }
  }

  /// Search for students by name
  /// Returns a list of maps with 'id' and 'name' keys
  Future<List<Map<String, dynamic>>> searchStudentsByName(String query, String? academyId) async {
    if (query.trim().isEmpty) {
      return [];
    }
    if (academyId == null || academyId.trim().isEmpty) {
      return [];
    }
    try {
      final response = await supabase
          .from('users')
          .select('id, full_name')
          .eq('role', 'student')
           .ilike('full_name', '%$query%')
           .in_('id', await AcademyService().getUsersFromSameAcademy(academyId, 'student'))
           .limit(10);
      
      // Explicitly cast each item to Map<String, dynamic> before mapping
      return List<Map<String, dynamic>>.from(
        response.map((dynamic user) => {
          'id': user['id'],
          'name': user['full_name'],
        })
      );
    } catch (e) {
 
      throw Exception('Error searching students: $e');
    }
  }

  /// Get students by IDs
  /// Returns a list of UserModel objects
  Future<List<UserModel>> getStudentsByIds(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .in_('id', studentIds);
      
      return List<UserModel>.from(
        List<dynamic>.from(response).map((user) => UserModel.fromMap(user))
      );
    } catch (e) {
 
      throw Exception('Error getting students by IDs: $e');
    }
  }

  /// Load student names for the given student IDs
  /// Returns a map of student IDs to names
  Future<Map<String, String>> loadStudentNames(List<String> studentIds) async {
    if (studentIds.isEmpty) return {};
    
    try {
      final response = await supabase
          .from('users')
          .select('id, full_name')
          .in_('id', studentIds);
          
      
      final Map<String, String> studentNames = {};
      for (var user in List<dynamic>.from(response)) {
        studentNames[user['id']] = user['full_name'];
      }
      
      return studentNames;
    } catch (e) {
 
      throw Exception('Error loading student names: $e');
    }
  }

  Future<List<StudentGroupModel>> getStudentGroups(String academyId) async {
    final response = await supabase
        .from('student_groups')
        .select()
        .eq('academy_id', academyId);

    return (response as List)
        .map((e) => StudentGroupModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }




  Future<List<StudentGroupModel>> searchStudentGroupsByName(String query, String academyId) async {
    if (query.trim().isEmpty) {
      return [];
    }
    if (academyId == null || academyId.trim().isEmpty) {
      return [];
    }
    try {
      final response = await supabase
          .from('academy_subgroups')
          .select()
          .eq('academy_id', academyId)
          .ilike('name', '%$query%')
          .limit(10);

      if (response == null) {
        return [];
      }
      return (response as List)
          .map((e) => StudentGroupModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
 
      throw Exception('Error searching student groups: $e');
    }
  }


  Future<String?> getAttendanceStatus(String sessionId, String studentId) async {
    try {
      final response = await supabase
          .from('session_attendance')
          .select('status')
          .eq('session_id', sessionId)
          .eq('student_id', studentId)
          .single();
      return response['status'] as String?;
    } catch (e) {
      print('Error getting attendance status: $e');
      return null;
    }
  }

  Future<void> updateAttendanceStatus(String sessionId, String studentId, String status) async {
    await supabase.from('session_attendance').upsert(
      {
        'session_id': sessionId,
        'student_id': studentId,
        'status': status,
      }
    );
  }

  Future<List<String>> getStudentIdsFromGroupName(List<String> groupIds) async {
 if (groupIds.isEmpty) return [];
    
    try {
      final response = await supabase
          .from('subgroup_students')
          .select('student_id')
          .in_('subgroup_id', groupIds);
          
      
      final List<String> studentIds = [];
      for (var userId in List<dynamic>.from(response)) {
        studentIds.add(userId['student_id']);
      }
      
      return studentIds;
    } catch (e) {
 
      throw Exception('Error loading student names: $e');
    }
  }
}