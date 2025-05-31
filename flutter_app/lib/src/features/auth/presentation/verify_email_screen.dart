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

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
      _statusMessage = '';
    });

    try {
      await auth.resendVerificationEmail(widget.email!);
      setState(() {
        _statusMessage = 'Verification email sent!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to resend email.';
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
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: _isResending ? null : _resendEmail,
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
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}