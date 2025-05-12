import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      ],
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) return '/login';
        return null;
      },
    );

    return MaterialApp.router(
      title: 'CoachConnect',
      routerConfig: router,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}