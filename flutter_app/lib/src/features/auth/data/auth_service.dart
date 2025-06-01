import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { coach, student }

class RegisteredUser {
  final String? id;
  final String fullName;
  final UserRole role;
  final String? email;

  RegisteredUser({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
  });
}

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw Exception('User not found');
    }

    final userId = user.id;
    final userRole = user.userMetadata?['role'] as String?;
    final userFullName = user.userMetadata?['full_name'] as String?;

    await supabase.from('users').insert({
      'id': userId,
      'full_name': userFullName,
      'role': userRole,
    });

    final insertResponse = await supabase.
      from('users').
      select('id')
      .eq('id', userId)
      .single();
    print("Insert Response:");

    print(insertResponse);

    return userRole;
  }

  // Need to create user table in Supabase with corresponding columns
  // and set up RLS policies to allow only the user to access their own data
  Future<RegisteredUser> register({
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
    // Will currently return null if user does not verify their email
    final session = response.session;
    final userId = response.user?.id;

    print("Session:");
    print(session);
    print("User ID:");
    print(userId);
    
    return RegisteredUser(id: userId, fullName: fullName, role: role, email: email);


  }


  Future<bool> isEmailVerified() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    // Refresh the user to get the latest email verification status
    await supabase.auth.refreshSession();
    return user.emailConfirmedAt != null; // Check if email is verified
  }

  Future<void> resend(String email) async {
    await supabase.auth.resend(
      email: email,
      type: OtpType.email,
    );
}


  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}
