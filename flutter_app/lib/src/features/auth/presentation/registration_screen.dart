import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/auth_service.dart'; // Assuming you have an AuthService for handling authentication
import '../../../services/academy_service.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final auth = AuthService();
  final academyService = AcademyService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  String? selectedRole; // Holds the selected role
  String? accessCode; // Holds the inputted access code
  bool loading = false;
  bool hidePassword = true;
  
  @override
  void initState() {
  super.initState();
  // No need to fetch academies for access code joining
  }

  // _fetchAcademies removed (no longer needed)

  // TODO: Move out to shared utils
  void _togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  Future<void> _register() async {
    // Must select a role
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    // Must enter an access code
    if (accessCode == null || accessCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an academy access code')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // Validate access code and get academyId
      final result = await academyService.supabase
        .from('academies')
        .select('id')
        .eq('access_code', accessCode)
        .maybeSingle();
      final academyId = result?['id'] as String?;
      if (academyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid academy access code')),
        );
        setState(() => loading = false);
        return;
      }

      UserRole role = selectedRole == 'coach' ? UserRole.coach : UserRole.student;
      final registeredUser = await auth.register(
        email: emailController.text,
        password: passwordController.text,
        fullName: fullNameController.text,
        role: role,
      );

      final userId = registeredUser.id;
      if (selectedRole == 'coach') {
        await academyService.addCoachToAcademy(academyId, userId!);
      } else if (selectedRole == 'student') {
        await academyService.addStudentToAcademy(academyId, userId!);
      }

      // After registration, go to verify email screen
      context.go('/verify_email', extra: emailController.text);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error here: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register to get started!'
        , style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: fullNameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password', suffixIcon: IconButton(onPressed: _togglePasswordVisibility, icon: hidePassword ? Icon(Icons.visibility) : Icon(Icons.visibility_off))), obscureText: hidePassword),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'coach', child: Text('Coach')),
              ],
              onChanged: (value) => setState(() => selectedRole = value),
              decoration: const InputDecoration(labelText: 'Select Role'),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Academy Access Code'),
              onChanged: (value) => setState(() => accessCode = value.trim()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: loading ? null : _register,
                child: Text(loading ? 'Registering...' : 'Register'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Log in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
