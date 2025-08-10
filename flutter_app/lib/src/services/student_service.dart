import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/services/database_service.dart';

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
      final response = await supabase
          .from('users')
          .select('*')
          .eq('role', 'student');
      
      return List<UserModel>.from(
        List<dynamic>.from(response).map((user) => UserModel.fromMap(user))
      );
    } catch (e) {
      print('Error getting all students: $e');
      throw Exception('Error getting all students: $e');
    }
  }

  /// Search for students by name
  /// Returns a list of maps with 'id' and 'name' keys
  Future<List<Map<String, dynamic>>> searchStudentsByName(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    try {
      final response = await supabase
          .from('users')
          .select('id, full_name')
          .eq('role', 'student')
          .ilike('full_name', '%$query%')
          .limit(10);
      
      // Explicitly cast each item to Map<String, dynamic> before mapping
      return List<Map<String, dynamic>>.from(
        response.map((dynamic user) => {
          'id': user['id'],
          'name': user['full_name'],
        })
      );
    } catch (e) {
      print('Error searching students: $e');
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
      print('Error getting students by IDs: $e');
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
      print('Error loading student names: $e');
      throw Exception('Error loading student names: $e');
    }
  }
}