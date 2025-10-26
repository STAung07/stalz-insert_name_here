import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/auth_service.dart'; // Assuming you have an AuthService for handling authentication

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool hidePassword = true;
  void _togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }
  void _login() async {
    setState(() => loading = true);
    try {
      await auth.signIn(emailController.text, passwordController.text);
      final isVerified = await auth.isEmailVerified();
      if (!isVerified) {
        // If not verified, go to verify email screen
        context.go('/verify_email', extra: emailController.text);
        return;
      }
      context.go('/dashboard');
    } catch (e) {
      // TODO: Handle specific exceptions for better user feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to XXX!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Your One Stop Coaching Solution', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: passwordController, 
              decoration: 
                InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility
                  ),
                ), 
              obscureText: hidePassword
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: loading ? null : _login,
                child: Text(loading ? 'Signing In...' : 'Sign In'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () => context.go('/register'),
                child: const Text('Don\'t have an account? Register here!'),
              ),
            ),
            const SizedBox(height: 10),
            // SizedBox(
            //   width: double.maxFinite,
            //   child: ElevatedButton(
            //     onPressed: () => {}, // Implement forgot password functionality
            //     child: const Text('Forgot Password?'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}