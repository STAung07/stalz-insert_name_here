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
  List<Map<String, dynamic>> subgroups = [];
  List<Map<String, dynamic>> unassignedStudents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => loading = true);
    // Fetch academy name
    final academyList = await academyService.fetchAcademies();
    final academy = academyList.firstWhere(
      (a) => a['id'] == widget.academyId,
      orElse: () => {'name': 'Academy not found'},
    );
    academyName = academy['name'] ?? 'Academy not found';

    // Fetch subgroups
    subgroups = await academyService.fetchSubgroupsFromAcademy(widget.academyId);

    // Fetch unassigned students
    unassignedStudents = await academyService.fetchUnassignedStudents(widget.academyId);

    setState(() => loading = false);
  }

  Future<void> _showCreateSubgroupDialog() async {
    final nameController = TextEditingController();
    List<String> selectedStudentIds = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Create Subgroup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Subgroup Name'),
                ),
                const SizedBox(height: 16),
                const Text('Add Unassigned Students:'),
                SizedBox(
                  height: 200,
                  width: 300,
                  child: ListView(
                    children: unassignedStudents.map((student) {
                      final id = student['student_id'];
                      final name = student['users']?['full_name'] ?? 'No Name';
                      return CheckboxListTile(
                        value: selectedStudentIds.contains(id),
                        title: Text(name),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedStudentIds.add(id);
                            } else {
                              selectedStudentIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final subgroupId = await academyService.createSubgroup(widget.academyId, name);
                    await academyService.addStudentsToSubgroup(subgroupId, selectedStudentIds);
                    Navigator.pop(context);
                    await _fetchAll();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubgroupTile(String name, Future<List<Map<String, dynamic>>> studentsFuture) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: studentsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }
                final students = snapshot.data!;
                if (students.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No students in this subgroup.'),
                  );
                }
                return Column(
                  children: students.map((student) =>
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(student['users']?['full_name'] ?? 'No Name'),
                      // subtitle: Text(student['student_id']),
                    )
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnassignedTile() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unassigned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            if (unassignedStudents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No unassigned students.'),
              )
            else
              Column(
                children: unassignedStudents.map((student) =>
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline),
                    //title: Text(student['student_id']),
                    title: Text(student['users']?['full_name'] ?? 'No Name'),
                  )
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    academyName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _showCreateSubgroupDialog,
                    child: const Text('Create Subgroup'),
                  ),
                  _buildUnassignedTile(),
                  ...subgroups.map((subgroup) =>
                    _buildSubgroupTile(
                      subgroup['name'],
                      academyService.fetchStudentsInSubgroup(subgroup['id']),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}