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
      context.go('/dashboard');
    } catch (e) {
      final errorMsg = e.toString();
      print('Exception during login: $errorMsg');
      if (errorMsg.contains('Email not confirmed')) {
        final parentContext = context;
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Email Not Verified'),
            content: const Text('Your email address has not been verified. Please check your inbox for a verification link or resend the verification email.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  setState(() => loading = true);
                  try {
                    await auth.resend(emailController.text);
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Verification email resent. Please check your inbox.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (err) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('Failed to resend verification email: $err')));
                  } finally {
                    setState(() => loading = false);
                  }
                },
                child: const Text(
                  'Resend Verification Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (errorMsg.contains('Invalid login credentials')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password. Please try again.')));
      } else if (errorMsg.contains('User not found')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user found with this email.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Rallin!',
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