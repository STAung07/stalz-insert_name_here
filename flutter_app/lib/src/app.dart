import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/registration_screen.dart';
import 'features/auth/presentation/verify_email_screen.dart'; // Verify email screen
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/auth/domain/app_user.dart';  // Add this import

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),
        GoRoute(path: '/verify_email', builder: (context, state) => VerifyEmailScreen(email: state.extra as String?)), // Verify email screen
        GoRoute(
                path: '/dashboard', 
                builder: (_, __) {
                  final currentUser = Supabase.instance.client.auth.currentUser;
                  if (currentUser == null) return const LoginScreen();
                  return DashboardScreen(userId: AppUser.fromSupabase(currentUser).id);
                }
              ),
      ],
      // redirect: (context, state) {
      //   final session = Supabase.instance.client.auth.currentSession;
      //   if (session == null) return '/register';
      //   return null;
      // },
    );

    return MaterialApp.router(
      title: 'CoachConnect',
      routerConfig: router,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}