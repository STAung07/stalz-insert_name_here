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
  final VoidCallback? onSessionCreated;
  final TrainingSessionModel? initialSession;

  const AddSessionForm({
    super.key,
    required this.coachId,
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
  final List<String> _selectedStudents = [];
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

    if (!mounted) return;
    setState(() {
      if (isStart) {
        _selectedStartDate = date;
        _startTime = time;
      } else {
        _selectedEndDate = date;
        _endTime = time;
      }
    });
  }
  @override
  void initState() {
    super.initState();

    final session = widget.initialSession;
    if (session != null) {
      _titleController.text = session.title;
      _locationController.text = session.location;
      _trainingPlanController.text = session.trainingPlan;
      _feedbackController.text = session.feedback;
      _selectedStudents.addAll(session.studentIds);
      
      // Load student names for the selected student IDs
      _loadStudentNames(session.studentIds);

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
              onStudentSelected: (id, name) {
                setState(() {
                  _selectedStudents.add(id);
                  _studentNames[id] = name;
                });
              },
              onStudentRemoved: (id) {
                setState(() {
                  _selectedStudents.remove(id);
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSession = TrainingSessionModel(
                      sessionId: widget.sessionId,
                      academyId: '',
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
                      studentIds: _selectedStudents, // Now contains student IDs instead of names
                      trainingPlan: _trainingPlanController.text,
                      feedback: _feedbackController.text,
                    );

                    print('SessionId: ${newSession.sessionId}');
                    TrainingSessionService().createTrainingSession(
                      newSession,
                      widget.coachId, // TODO: replace this by querying all academy coaches
                      _selectedStudents,
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
