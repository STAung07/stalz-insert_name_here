import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { coach, student }

class AuthService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Need to create user table in Supabase with corresponding columns
  // and set up RLS policies to allow only the user to access their own data
  Future<AuthResponse> register({
  required String email,
  required String password,
  required String fullName,
  required UserRole role,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name, // Store role in user_metadata
      },
    );

    final userId = response.user?.id;
    if (userId == null) throw Exception('No user ID returned');

    final table = role == UserRole.coach ? 'coaches' : 'students';

    await Supabase.instance.client.from(table).insert({
      'id': userId,
      'full_name': fullName,
    });

    return response;
  }


  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}
