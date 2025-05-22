import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { coach, student }

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw Exception('User not found');
    }

    final role = user.userMetadata?['role'] as String?;
    if (role == null) throw Exception('No role found for user');
    return role;
  }

  // Need to create user table in Supabase with corresponding columns
  // and set up RLS policies to allow only the user to access their own data
  Future<AuthResponse> register({
  required String email,
  required String password,
  required String fullName,
  required UserRole role,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name, // Store role in user_metadata
      },
    );

    final session = response.session;
    final userId = response.user?.id;
    print(session);
    print(userId);
    if (session == null) {
      throw Exception('User registration failed: No active session');
    }
    if (userId == null) {
      throw Exception('User registration failed: No user ID');
    }
    final insertResponse = await supabase.from('users').insert({
      'id': userId,
      'full_name': fullName,
      'role': role.name,
    });

    return insertResponse;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}
