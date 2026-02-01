import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/services/academy_service.dart';
import 'package:flutter_app/src/services/user_service.dart';
import 'package:flutter_app/src/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class StudentProfileScreen extends StatefulWidget {
  // final String studentId;
  final UserModel user;

  const StudentProfileScreen({super.key, required this.user});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final academyService = AcademyService();
  String academyName = '';
  String subgroupName = '';
  bool loading = true;
  bool deleting = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => loading = true);

    // 1. Get academyId for this student
    final academyId = await academyService.getUserAcademy(widget.user.id, 'student');

    // 2. Get academy name
    if (academyId != null) {
      final academies = await academyService.fetchAcademies();
      final academy = academies.firstWhere(
        (a) => a['id'] == academyId,
        orElse: () => {'name': 'Academy not found'},
      );
      academyName = academy['name'] ?? 'Academy not found';
    } else {
      academyName = 'Academy not found';
    }

    // 3. Get subgroup (if any)
    final subgroupResponse = await academyService.supabase
        .from('subgroup_students')
        .select('subgroup_id, academy_subgroups(name)')
        .eq('student_id', widget.user.id)
        .maybeSingle();

    if (subgroupResponse != null && subgroupResponse['academy_subgroups'] != null) {
      subgroupName = subgroupResponse['academy_subgroups']['name'] ?? 'No subgroup';
    } else {
      subgroupName = 'No subgroup';
    }

    setState(() => loading = false);
  }

  Future<void> _confirmDeleteProfile() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Profile'),
          content: const Text('This will permanently delete your profile. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: deleting
                  ? null
                  : () async {
                      setState(() => deleting = true);
                      try {
                        await UserService().deleteUserProfile(widget.user.id, widget.user.role);
                        await AuthService().signOut();
                        if (mounted) {
                          context.go('/login');
                        }
                      } finally {
                        if (mounted) setState(() => deleting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Academy:', style: Theme.of(context).textTheme.titleMedium),
                  Text(academyName, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 32),
                  Text('Subgroup:', style: Theme.of(context).textTheme.titleMedium),
                  Text(subgroupName, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: deleting ? null : _confirmDeleteProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: Text(deleting ? 'Deleting...' : 'Delete Profile'),
                  ),
                ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation
          setState(() {
            if (index == 0) {
              context.go('/dashboard');
            } else if (index == 1) {
              context.go('/calendar', extra: {'userId': widget.user.id, 'userRole': widget.user.role, 'academyId': widget.user.academy});
            } else {
              context.go('/profile', extra: {'userId': widget.user.id});
            }
          });
        },
      ),
    );
  }
}
