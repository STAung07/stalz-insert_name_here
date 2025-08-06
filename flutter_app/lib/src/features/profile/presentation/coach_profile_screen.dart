import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/academy_service.dart';

class CoachProfileScreen extends StatefulWidget {
  final String coachId;
  final String academyId;

  const CoachProfileScreen({super.key, required this.coachId, required this.academyId});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final academyService = AcademyService();
  String academyName = '';
  List<Map<String, dynamic>> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAcademyName();
    _fetchStudents();
  }

  Future<void> _fetchAcademyName() async {
    setState(() => loading = true);
    final response = await academyService.fetchAcademies();
    final academy = response.firstWhere(
      (a) => a['id'] == widget.academyId,
      orElse: () => {'name': 'Academy not found'},
    );
    setState(() {
      academyName = academy['name'] ?? 'Academy not found';
      loading = false;
    });
  }

  Future<void> _fetchStudents() async {
    final response = await academyService.fetchStudentsInAcademy(widget.academyId);
    print('Fetched students: $response');
    setState(() {
      students = response;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    academyName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // const SizedBox(height: 16),
                  // Text('Coach ID: ${widget.coachId}'),
                  // Text('Academy ID: ${widget.academyId}'),
                  const SizedBox(height: 32),
                  Text('Students in Academy:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...students.map((student) => Text(student['users']['full_name'] ?? 'No Name Entered')),
                ],
              ),
      ),
    );
  }
}