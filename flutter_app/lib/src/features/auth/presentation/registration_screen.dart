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
  String? selectedAcademyId;
  bool loading = false;
  bool hidePassword = true;
  List<Map<String, dynamic>> academies = []; // List of academies, if needed
  
  @override
  void initState() {
    super.initState();
    // Optionally, fetch academies if needed
    _fetchAcademies();
  }

  Future<void> _fetchAcademies() async {
    final result = await academyService.fetchAcademies();
    print('Fetched academies: $result');
    setState(() {
      academies = result;
    });
  }

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

    // Must select an academy
    if (selectedAcademyId == null || selectedAcademyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an academy')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      UserRole role = selectedRole == 'coach' ? UserRole.coach : UserRole.student;
      final registeredUser = await auth.register(
        email: emailController.text,
        password: passwordController.text,
        fullName: fullNameController.text,
        role: role, // Pass the selected role
      );
      
      // // Check if userId is null, which means registration failed
      // if (registeredUser == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Registration failed. Please try again.')),
      //   );
      //   return;
      // }

      if (selectedAcademyId != null && selectedAcademyId!.isNotEmpty) {
        final userId = registeredUser.id;
        if (selectedRole == 'coach') {
          await academyService.addCoachToAcademy(selectedAcademyId!, userId!);
        } else if (selectedRole == 'student') {
          await academyService.addStudentToAcademy(selectedAcademyId!, userId!);
        }
      }
      // Registration successful, need to verfiy email; redirect to verify email screen
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Registration successful! Please verify your email address provided.')),
      // );
      // context.go('/verify_email', extra: registeredUser.email); // Redirect to verify email screen
      context.go('/dashboard');
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
            DropdownButtonFormField<String>(
              value: selectedAcademyId,
              items: academies.map((academy) => DropdownMenuItem(
                value: academy['id'] as String,
                child: Text(academy['name'] as String),
              )).toList(),
              onChanged: (value) => setState(() => selectedAcademyId = value),
              decoration: const InputDecoration(labelText: 'Select Academy'),
              validator: (value) => value == null || value.isEmpty ? 'Please select an academy' : null,
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
