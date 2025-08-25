import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/services/student_service.dart';
import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:flutter_app/src/features/dashboard/presentation/coach/student_search_widget.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSessionForm extends StatefulWidget {
  final String? sessionId;
  final String coachId;
  final String? academyId;
  final VoidCallback? onSessionCreated;
  final TrainingSessionModel? initialSession;

  const AddSessionForm({
    super.key,
    required this.coachId,
    this.academyId,
    this.onSessionCreated,
    this.initialSession,
    this.sessionId
  });

  @override
  State<AddSessionForm> createState() => _AddSessionFormState();
}

class _AddSessionFormState extends State<AddSessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _trainingPlanController = TextEditingController();
  final _feedbackController = TextEditingController();
  final List<Map<String, String>> _selectedStudents = [];
  final Map<String, String> _studentNames = {}; // Map student IDs to names

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _bookingStatus = 'Tentative';
  String _sessionType = 'Private';

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (isStart) {
      setState(() {
        _selectedStartDate = date;
        _startTime = time;
      });
    } else {
      // Validate that end time is after start time
      if (_selectedStartDate != null && _startTime != null) {
        final startDateTime = DateTime(
          _selectedStartDate!.year,
          _selectedStartDate!.month,
          _selectedStartDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        );
        if (selectedDateTime.isBefore(startDateTime)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End date and time must be after start date and time.'),
            ),
          );
          return; // Do not update state if validation fails
        }
      }
      setState(() {
        _selectedEndDate = date;
        _endTime = time;
      });
    }
    if (!mounted) return;
  }
  @override
  @override
  void initState() {
    super.initState();
    _initializeSessionData();
  }

  Future<void> _initializeSessionData() async {
    final session = widget.initialSession;
    print('academy id: ${widget.academyId}');
    if (session != null) {
      _titleController.text = session.title;
      _locationController.text = session.location;
      _trainingPlanController.text = session.trainingPlan;
      _feedbackController.text = session.feedback;
      // Load student names for the selected student IDs first and await its completion
      await _loadStudentNames(session.studentIds);

      // Then populate _selectedStudents using the now-available names
      if (mounted) {
        setState(() {
          _selectedStudents.addAll(session.studentIds.map((id) => {'id': id, 'name': _studentNames[id] ?? '', 'type': 'student'}));
        });
      }

      _selectedStartDate = session.startTime;
      _selectedEndDate = session.endTime;
      _startTime = TimeOfDay.fromDateTime(session.startTime);
      _endTime = TimeOfDay.fromDateTime(session.endTime);

      _bookingStatus = session.bookingStatus;
      _sessionType = session.sessionType;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Location
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            // Start & End Time
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedStartDate == null || _startTime == null
                            ? 'Starts'
                            : 'Starts: \n${DateFormat.yMMMd().format(_selectedStartDate!)} ${_startTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDateTime(context, true),
                    ),
                    const Divider(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedEndDate == null || _endTime == null
                            ? 'Ends'
                            : 'Ends: \n${DateFormat.yMMMd().format(_selectedEndDate!)} ${_endTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDateTime(context, false),
                    ),
                  ],
                ),
              ),
            ),

            // Booking Status
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Booking Status
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Booking Status'),
                      subtitle: Text(_bookingStatus),
                      trailing: Icon(Icons.import_export),
                      onTap:
                          () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Allows more height
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder:
                                (ctx) => SafeArea(
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.4, // Adjust height as needed
                                    child: Column(
                                      children:
                                          ['Tentative', 'Booked', 'Cancelled']
                                              .map(
                                                (status) => ListTile(
                                                  title: Text(status),
                                                  onTap: () {
                                                    setState(
                                                      () =>
                                                          _bookingStatus =
                                                              status,
                                                    );
                                                    FocusScope.of(context).unfocus();
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                          ),
                    ),
                    const Divider(height: 20),

                    // Session Type
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Session Type'),
                      subtitle: Text(_sessionType),
                      trailing: Icon(Icons.import_export),
                      onTap:
                          () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Allows more height
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder:
                                (ctx) => SafeArea(
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.4, // Adjust height as needed
                                    child: Column(
                                      children:
                                          ['Private', 'Group']
                                              .map(
                                                (type) => ListTile(
                                                  title: Text(type),
                                                  onTap: () {
                                                    setState(
                                                      () => _sessionType = type,
                                                    );
                                                    FocusScope.of(context).unfocus();
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Students search widget
            StudentSearchWidget(
              selectedStudents: _selectedStudents,
              studentNames: _studentNames,
              academyId: widget.academyId,
              onStudentSelected: (selectedItem) {
                setState(() {
                  _selectedStudents.add(selectedItem);
                  _studentNames[selectedItem['id']!] = selectedItem['name']!;
                });
              },
              onStudentRemoved: (id) {
                setState(() {
                  _selectedStudents.removeWhere((item) => item['id'] == id);
                  _studentNames.remove(id);
                });
              },
            ),

            // Training Plan & Feedback
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Training Plan Field
                    TextFormField(
                      controller: _trainingPlanController,
                      decoration: InputDecoration(labelText: 'Training Plan'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),

                    // Training Feedback Field
                    TextFormField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: 'Training Feedback',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Save Session Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final studentIds = await _getFlattenedStudentIds();
                    final newSession = TrainingSessionModel(
                      sessionId: widget.sessionId,
                      academyId: widget.academyId ?? '',
                      title: _titleController.text,
                      startTime: DateTime(
                        _selectedStartDate!.year,
                        _selectedStartDate!.month,
                        _selectedStartDate!.day,
                        _startTime!.hour,
                        _startTime!.minute,
                      ),
                      endTime: DateTime(
                        _selectedEndDate!.year,
                        _selectedEndDate!.month,
                        _selectedEndDate!.day,
                        _endTime!.hour,
                        _endTime!.minute,
                      ),
                      location: _locationController.text,
                      bookingStatus: _bookingStatus,
                      sessionType: _sessionType,
                      studentIds: studentIds,
                      trainingPlan: _trainingPlanController.text,
                      feedback: _feedbackController.text,
                      attendanceCount: 0,
                    );

                    TrainingSessionService().createTrainingSession(
                      newSession,
                      widget.coachId, 
                      studentIds,
                    );
                    if (widget.onSessionCreated != null)
                      widget.onSessionCreated!();
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<List<String>> _getFlattenedStudentIds() async {
    final List<String> flattenedIds = [];
    final List<String> groupIds = [];

    for (var item in _selectedStudents) {
      if (item['type'] == 'student') {
        flattenedIds.add(item['id']!);
      } else if (item['type'] == 'group') {
        groupIds.add(item['id']!);
      }
    }

    if (groupIds.isNotEmpty) {
      final studentService = StudentService();
      final studentsFromGroups = await studentService.getStudentIdsFromGroupName(groupIds);
      flattenedIds.addAll(studentsFromGroups);
    }

    return flattenedIds.toSet().toList(); // Return unique IDs
  }


  // Load student names for the given student IDs
  Future<void> _loadStudentNames(List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    
    try {
      final studentService = StudentService();
      final studentNames = await studentService.loadStudentNames(studentIds);
      
      if (mounted) {
        setState(() {
          _studentNames.addAll(studentNames);
        });
      } else {
        return;
      }
    } catch (e) {
      print('Error loading student names: $e');
    }
  }



  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _trainingPlanController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
}
