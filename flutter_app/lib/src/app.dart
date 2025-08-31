import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/registration_screen.dart';
import 'features/auth/presentation/verify_email_screen.dart'; // Verify email screen
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/calendar/presentation/calendar_view_screen.dart';
import 'features/profile/presentation/coach_profile_screen.dart'; // Import coach profile screen
import 'features/auth/domain/app_user.dart';  // Add this import

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
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
        GoRoute(
          path: '/calendar',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final userId = extra?['userId'] as String?;
            final userRole = extra?['userRole'] as String?;
            final academyId = extra?['academyId'] as String?;

            if (userId == null || userRole == null || academyId == null) {
              return const Scaffold(body: Center(child: Text('Missing user ID or role or academyId')));
            }
            return CalendarViewScreen(userId: userId, userRole: userRole, academyId: academyId);
          },
        ),
        GoRoute(
          path: '/coach_profile',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?; // or your own type
            final coachId = extra?['coachId'] as String?;
            final academyId = extra?['academyId'] as String?;
            // Check if coachId and academyId are provided
            if (coachId == null || academyId == null) {
              return const Scaffold(body: Center(child: Text('Missing coach or academy ID')));
            }
            return CoachProfileScreen(coachId: coachId, academyId: academyId);
          },
        ),
      ],
      // redirect: (context, state) {
      //   final session = Supabase.instance.client.auth.currentSession;
      //   if (session == null) return '/register';
      //   return null;
      // },
    );

    return MaterialApp.router(
      title: 'Badminton App',
      routerConfig: router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCBD2FF),
          background: Colors.white,
          onBackground: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCBD2FF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFCBD2FF),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFCBD2FF),
            side: const BorderSide(color: Color(0xFFbcbfc0)),
          ),
        ),
      ),
    );
  }
}