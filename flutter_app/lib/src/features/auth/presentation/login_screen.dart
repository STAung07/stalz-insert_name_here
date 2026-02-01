import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/auth_service.dart'; // Assuming you have an AuthService for handling authentication
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }


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
      // Save credentials if rememberMe is checked
      if (rememberMe) {
        await storage.write(key: 'email', value: emailController.text);
        await storage.write(key: 'password', value: passwordController.text);
        await storage.write(key: 'rememberMe', value: 'true');
        await storage.write(key: 'autoLogin', value: 'true');
      } else {
        await storage.delete(key: 'email');
        await storage.delete(key: 'password');
        await storage.delete(key: 'rememberMe');
        await storage.delete(key: 'autoLogin');
      }
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

  Future<void> _loadRememberedCredentials() async {
    final remembered = await storage.read(key: 'rememberMe');
    final autoLogin = await storage.read(key: 'autoLogin');
    if (remembered == 'true') {
      final email = await storage.read(key: 'email');
      final password = await storage.read(key: 'password');
      setState(() {
        rememberMe = true;
        emailController.text = email ?? '';
        passwordController.text = password ?? '';
      });
      // If autoLogin is true, trigger login automatically
      if (autoLogin == 'true' && (email?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false)) {
        // Wait for the widget to build before calling login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !loading) {
            _login();
          }
        });
      }
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
            CheckboxListTile(
              title: const Text('Remember Me'),
              value: rememberMe,
              onChanged: (value) {
                setState(() {
                  rememberMe = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
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
            SizedBox(
              width: double.maxFinite,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      final forgotEmailController = TextEditingController();
                      return AlertDialog(
                        title: const Text('Reset Password'),
                        content: TextField(
                          controller: forgotEmailController,
                          decoration: const InputDecoration(labelText: 'Enter your email'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              final email = forgotEmailController.text.trim();
                              Navigator.of(dialogContext).pop();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email.')));
                                return;
                              }
                              setState(() => loading = true);
                              try {
                                await auth.resetPassword(email);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent. Please check your inbox.'), backgroundColor: Colors.green));
                              } catch (err) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send reset email: $err')));
                              } finally {
                                setState(() => loading = false);
                              }
                            },
                            child: const Text('Send Reset Email'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}