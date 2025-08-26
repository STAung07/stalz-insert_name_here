import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/services/academy_service.dart';
import 'package:go_router/go_router.dart';

class CoachProfileScreen extends StatefulWidget {
  // final String coachId;
  // final String academyId;
  final UserModel user;

  const CoachProfileScreen({super.key, required this.user});

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
      (a) => a['id'] == widget.user.academy,
      orElse: () => {'name': 'Academy not found'},
    );
    academyName = academy['name'] ?? 'Academy not found';

    // Fetch subgroups
    subgroups = await academyService.fetchSubgroupsFromAcademy(widget.user.academy);

    // Fetch unassigned students
    unassignedStudents = await academyService.fetchUnassignedStudents(widget.user.academy);

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
                    final subgroupId = await academyService.createSubgroup(widget.user.academy, name);
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

  Future<void> _showEditSubgroupDialog(String subgroupId, String subgroupName) async {
    // Fetch all students in academy and all students in this subgroup
    final allStudents = await academyService.fetchStudentsInAcademy(widget.user.academy);
    final subgroupStudents = await academyService.fetchStudentsInSubgroup(subgroupId);
    final subgroupStudentIds = subgroupStudents.map((s) => s['student_id']).toSet();

    List<dynamic> selectedStudentIds = subgroupStudentIds.toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Edit $subgroupName'),
            content: SizedBox(
              width: 300,
              height: 300,
              child: ListView(
                children: allStudents.map((student) {
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Remove students not in selectedStudentIds
                  for (final student in subgroupStudents) {
                    if (!selectedStudentIds.contains(student['student_id'])) {
                      await academyService.removeStudentFromSubgroup(subgroupId, student['student_id']);
                    }
                  }
                  // Add students newly selected
                  for (final id in selectedStudentIds) {
                    if (!subgroupStudentIds.contains(id)) {
                      await academyService.addStudentToSubgroup(subgroupId, id);
                    }
                  }
                  Navigator.pop(context);
                  await _fetchAll();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMoveStudentDialog(String currentSubgroupId, String studentId) async {
    // Get all subgroups
    final allSubgroups = [
      {'id': null, 'name': 'Unassigned'},
      ...subgroups
    ];
    String? selectedSubgroupId = currentSubgroupId == '' ? null : currentSubgroupId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move Student'),
          content: DropdownButton<String?>(
            value: selectedSubgroupId,
            isExpanded: true,
            items: allSubgroups.map((sg) {
              return DropdownMenuItem<String?>(
                value: sg['id'],
                child: Text(sg['name']),
              );
            }).toList(),
            onChanged: (value) {
              selectedSubgroupId = value;
              (context as Element).markNeedsBuild();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedSubgroupId != currentSubgroupId) {
                  await academyService.moveStudentToSubgroup(
                    currentSubgroupId == '' ? null : currentSubgroupId,
                    selectedSubgroupId,
                    studentId,
                  );
                  Navigator.pop(context);
                  await _fetchAll();
                }
              },
              child: const Text('Move'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubgroupTile(String name, String subgroupId, Future<List<Map<String, dynamic>>> studentsFuture) {
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
            Row(
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditSubgroupDialog(subgroupId, name),
                  tooltip: 'Edit Subgroup',
                ),
              ],
            ),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        tooltip: 'Move Student',
                        onPressed: () => _showMoveStudentDialog(subgroupId, student['student_id']),
                      ),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: 'Assign to Subgroup',
                      onPressed: () => _showMoveStudentDialog('', student['student_id']),
                    ),
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
          : SafeArea(
              child: SingleChildScrollView(
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
                        subgroup['id'],
                        academyService.fetchStudentsInSubgroup(subgroup['id']),
                      ),
                    ),
                  ],
                ),
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