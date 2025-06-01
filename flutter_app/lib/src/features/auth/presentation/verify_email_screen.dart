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
      await AuthService().resendVerificationEmail(widget.email!);
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
          children: [
            Text(
              'A verification link has been sent to:\n${widget.email}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isResending ? null : _resendEmail,
              child: _isResending
                  ? const CircularProgressIndicator()
                  : const Text('Resend Email'),
            ),
            const SizedBox(height: 12),
            if (_statusMessage.isNotEmpty)
              Text(_statusMessage, style: const TextStyle(color: Colors.green)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
