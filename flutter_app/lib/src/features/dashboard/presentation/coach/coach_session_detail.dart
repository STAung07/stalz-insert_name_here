import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/features/dashboard/presentation/coach/add_session_form.dart';
import 'package:flutter_app/src/services/student_service.dart';
import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:intl/intl.dart';

class CoachSessionDetail extends StatefulWidget {
  final TrainingSessionModel session;
  final String coachId;
  final VoidCallback? onRefresh;

  const CoachSessionDetail({
    super.key,
    required this.session,
    required this.coachId,
    this.onRefresh,
  });

  @override
  State<CoachSessionDetail> createState() => _CoachSessionDetailState();
}

class _CoachSessionDetailState extends State<CoachSessionDetail> {
  final Map<String, String> _studentNames = {};
  final Map<String, String> _studentAttendanceStatus = {};
  bool _isLoading = true;
  final GlobalKey<AddSessionFormState> _editFormKey = GlobalKey<AddSessionFormState>();

  @override
  void initState() {
    super.initState();
    _loadStudentNames();
    _loadStudentAttendanceStatus();
  }

  Future<void> _loadStudentNames() async {
    if (widget.session.studentIds.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final studentService = StudentService();
      final studentNames = await studentService.loadStudentNames(widget.session.studentIds);

      setState(() {
        _studentNames.addAll(studentNames);
        // Keep _isLoading true until both names and statuses are loaded
      });
    } catch (e) {
      print('Error loading student names: $e');
      print('Student names loaded: $_studentNames');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudentAttendanceStatus() async {
    if (widget.session.sessionId == null || widget.session.studentIds.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final studentService = StudentService();
      final attendanceStatuses = await studentService.getAttendanceStatusesForSession(
        widget.session.sessionId!,
        widget.session.studentIds,
      );

      setState(() {
        _studentAttendanceStatus.addAll(attendanceStatuses);
        _isLoading = false; // Set to false after both are loaded
      });
    } catch (e) {
      print('Error loading student attendance statuses: $e');
      print('Student attendance statuses loaded: $_studentAttendanceStatus');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Stack(
        children: [
          SizedBox(
            width: screenSize.width * 0.95,
            height: screenSize.height * 0.75,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.session.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Location & Time Info
              Row(
                children: [
                  Icon(Icons.place, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.session.location),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('MMM d, yyyy • h:mm a').format(widget.session.startTime)}'
                    ' - ${DateFormat('h:mm a').format(widget.session.endTime)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Booking Status & Type
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Text('${widget.session.bookingStatus} • ${widget.session.sessionType}'),
                ],
              ),

              const Divider(height: 24),

              // Training Plan & Feedback
              Text(
                'Training Plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(widget.session.trainingPlan),
              const SizedBox(height: 12),
              Text('Feedback', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(widget.session.feedback),

              const Divider(height: 24),

              // Students
              Text('Students', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text('Attendance: ${widget.session.attendanceCount ?? 0} students'),
              const SizedBox(height: 8),
              _isLoading
                ? Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.session.studentIds.map((id) {
                      final status = _studentAttendanceStatus[id];
                      double opacity = 1.0;
                      if (status == 'No' || status == 'Maybe') {
                        opacity = 0.4;
                      }
                      return Opacity(
                        opacity: opacity,
                        child: Chip(label: Text((_studentNames[id] ?? id).toString())),
                      );
                    }).toList(),
                  ),

              const SizedBox(height: 80), // Space for the fixed buttons
            ],
          ),
        ),
      ),
      Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final screenSize = MediaQuery.of(context).size;
                          return AlertDialog(
                            title: Text('Edit Session'),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenSize.width * 0.9,
                                maxHeight: screenSize.height * 0.7,
                              ),
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: AddSessionForm(
                                    key: _editFormKey,
                                    sessionId: widget.session.sessionId,
                                    coachId: widget.coachId,
                                    academyId: widget.session.academyId,
                                    initialSession: widget.session,
                                    onSave: (newSession, coachId, studentIds) async {
                                      // Use createTrainingSession which internally uses upsertTrainingSession
                                      await TrainingSessionService().createTrainingSession(
                                        newSession,
                                        coachId,
                                        studentIds,
                                      );
                                      widget.onRefresh?.call();
                                    },
                                    onSessionCreated: () async {
                                      await Future.delayed(Duration(milliseconds: 500));
                                      widget.onRefresh?.call();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _editFormKey.currentState?.saveSession();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                          ],
                          );
                        },
                        
                      );
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this session?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        try {
                          final trainingSessionService = TrainingSessionService();
                          await trainingSessionService.deleteTrainingSession(widget.session.sessionId!);
                          Navigator.of(context).pop(); // Close detail dialog
                          widget.onRefresh?.call();
                        } catch (e) {
                          print('Error deleting session: $e');
                          // Optionally show an error message to the user
                        }
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ]
      )
    );
  }
}
