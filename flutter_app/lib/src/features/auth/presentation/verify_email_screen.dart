import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? email;

  const VerifyEmailScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final auth = AuthService();
  bool _isResending = false;
  String _statusMessage = '';

  // TODO: Possible workarounds to handle email verification
  // 1. Use a custom email verification flow; Backend endpoint that uses Supabase's auth API to send verification emails
  // 2. Register them again, but need to either prompt user to re-enter email or store it in a state management solution
  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
      _statusMessage = '';
    });

    try {
      print(widget.email);
      // Ensure email type is suitable for the resend operation
      print(auth.currentUser?.email);
      await auth.resend(widget.email!);
      setState(() {
        _statusMessage = 'Verification email sent!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to resend email. Error: $e';
      });
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'A verification link has been sent to:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              widget.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Did not receive the email? Check your spam folder or click the button below to go back to the registration screen and re-register.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: _isResending ? null : () => context.go('/register'),
                child: _isResending
                    ? const CircularProgressIndicator()
                    : const Text('Resend Email'),
              ),
            ),
            const SizedBox(height: 10),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Continue to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}