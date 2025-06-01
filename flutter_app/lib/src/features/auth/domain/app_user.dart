import 'package:supabase_flutter/supabase_flutter.dart' show User;

// TODO: improve this/ change it 
class AppUser {
  final String id;
  final String role;
  final String email;

  AppUser({
    required this.id,
    required this.role,
    required this.email,
  });

  factory AppUser.fromSupabase(User user) {
    return AppUser(
      id: user.id,
      role: user.userMetadata?['role'] as String? ?? 'student',
      email: user.email ?? '',
    );
  }
}