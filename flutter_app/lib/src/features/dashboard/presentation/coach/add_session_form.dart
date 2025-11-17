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
  final Function(TrainingSessionModel, String, List<String>) onSave;

  const AddSessionForm({
    super.key,
    required this.coachId,
    this.academyId,
    this.onSessionCreated,
    this.initialSession,
    this.sessionId,
    required this.onSave,
  });

  @override
  AddSessionFormState createState() => AddSessionFormState();
}

class AddSessionFormState extends State<AddSessionForm> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _trainingPlanController = TextEditingController();
  final _feedbackController = TextEditingController();
  final List<Map<String, String>> _selectedStudents = [];
  final Map<String, String> _studentNames = {}; // Map student IDs to names
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _bookingStatus = 'Tentative';
  String _sessionType = 'Private';

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    if (isStart) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            datePickerTheme: DatePickerThemeData(
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.lightGreen,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
          child: child!,
        ),
      );
      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            timePickerTheme: TimePickerThemeData(
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.lightGreen,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              dayPeriodTextColor: Colors.black,
              dayPeriodColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Color(0xFF768DFF).withOpacity(0.4)
                    : Color(0xFF768DFF).withOpacity(0.00),
              ),
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Color(0xFF768DFF).withOpacity(0.45)
                    : Color(0xFF768DFF).withOpacity(0.05),
              ),
            ),
          ),
          child: child!,
        ),
      );
      if (time == null) return;

      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      setState(() {
        _selectedStartDate = date;
        _startTime = time;

        // Enforce same-day session
        _selectedEndDate = date;

        // Ensure end time is at least 30 minutes after start
        if (_endTime == null) {
          final defaultEnd = startDateTime.add(const Duration(minutes: 30));
          _endTime = TimeOfDay(hour: defaultEnd.hour, minute: defaultEnd.minute);
        } else {
          final currentEndDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _endTime!.hour,
            _endTime!.minute,
          );
          final minEnd = startDateTime.add(const Duration(minutes: 30));
          if (currentEndDateTime.isBefore(minEnd)) {
            _endTime = TimeOfDay(hour: minEnd.hour, minute: minEnd.minute);
          }
        }
      });
    } else {
      if (_selectedStartDate == null || _startTime == null) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Missing start time'),
            content: const Text('Please select the start date and time first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.25),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
        return;
      }

      // Compute default initial end time as start + 30 minutes (or keep previously chosen end time)
      final startDateTimeForEnd = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final minEndForInitial = startDateTimeForEnd.add(const Duration(minutes: 30));
      final initialEndTime = _endTime ?? TimeOfDay(
        hour: minEndForInitial.hour,
        minute: minEndForInitial.minute,
      );
      final time = await showTimePicker(
        context: context,
        initialTime: initialEndTime,
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            timePickerTheme: TimePickerThemeData(
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.lightGreen,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              dayPeriodTextColor: Colors.black,
              dayPeriodColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Color(0xFF768DFF).withOpacity(0.4)
                    : Color(0xFF768DFF).withOpacity(0.00),
              ),
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Color(0xFF768DFF).withOpacity(0.45)
                    : Color(0xFF768DFF).withOpacity(0.05),
              ),
            ),
          ),
          child: child!,
        ),
      );
      if (time == null) return;

      final startDateTime = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endCandidate = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        time.hour,
        time.minute,
      );

      final minEnd = startDateTime.add(const Duration(minutes: 30));
      if (endCandidate.isBefore(minEnd)) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Invalid end time'),
            content: const Text('End time must be at least 30 minutes after start time.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.25),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        // Enforce end date equals start date
        _selectedEndDate = _selectedStartDate;
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
  
  Future<void> saveSession() async {
    // Validate text fields (title, location) first
    if (!_formKey.currentState!.validate()) return;

    // Simple popup warnings for missing start/end date/time
    if (_selectedStartDate == null || _startTime == null) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Missing start time'),
          content: const Text('Please select a start date and time.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.25),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
      return;
    }
    if (_selectedEndDate == null || _endTime == null) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Missing end time'),
          content: const Text('Please select an end date and time.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.25),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
      return;
    }

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
    widget.onSave(newSession, widget.coachId, studentIds);
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
