import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import '../../dashboard/presentation/coach/coach_session_detail.dart';
import '../../dashboard/presentation/student/student_session_detail.dart';
import '../../../models/training_session_model.dart';
import '../../../services/training_session_service.dart';


class CalendarViewScreen extends StatefulWidget {
  final String userId;
  final String userRole;
  final String academyId;

  const CalendarViewScreen({
    super.key,
    required this.userId,
    required this.userRole,
    required this.academyId,
  });
 
   @override
   State<CalendarViewScreen> createState() => _CalendarViewScreenState();
 }
 
 class _CalendarViewScreenState extends State<CalendarViewScreen> {
   void _showGenericEventDialog(BuildContext context, CalendarEventData event) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text(event.title),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Description: ${event.description ?? 'N/A'}'),
             Text('Start: ${event.date?.toLocal().toString().split(' ')[0]} ${event.startTime != null ? DateFormat('hh:mm a').format(event.startTime!) : 'N/A'}'),
             Text('End: ${event.date?.toLocal().toString().split(' ')[0]} ${event.endTime != null ? DateFormat('hh:mm a').format(event.endTime!) : 'N/A'}'),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('OK'),
           ),
         ],
       ),
     );
   }
  final EventController _eventController = EventController();
  late Future<List<TrainingSessionModel>> _futureSessions;

  @override
  void initState() {
    super.initState();
    _futureSessions = _fetchAndPopulateSessions();
    print('CalendarViewScreen userId: ${widget.userId}');
    print('CalendarViewScreen userRole: ${widget.userRole}');
    print('CalendarViewScreen academyId: ${widget.academyId}');
  }

  Future<List<TrainingSessionModel>> _fetchAndPopulateSessions() async {
    final sessions = await TrainingSessionService().getAllTrainingSessionsByUserId(widget.userId, widget.userRole);
    _eventController.removeAll(_eventController.events.toList()); // Clear existing events to prevent duplicates
    _eventController.addAll(sessions.map((session) {
      return CalendarEventData<TrainingSessionModel>(
        date: session.startTime,
        title: session.title,
        description: session.trainingPlan,
        startTime: session.startTime,
        endTime: session.endTime,
        event: session,
      );
    }).toList());
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Sessions')),
      body: FutureBuilder<List<TrainingSessionModel>>(
        future: _futureSessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return MonthView(
              // showLiveTimeLineInAllDays: false,
              controller: _eventController,
               onEventTap: (event, date) {
                 // Find the TrainingSessionModel corresponding to the tapped event
                 final CalendarEventData<Object?>? foundEvent = _eventController.events.firstWhere(
                   (e) => e.date == event.date && e.title == event.title && e.description == event.description,
                   orElse: () => CalendarEventData(title: '', date: DateTime.now(), event: null),
                 );
                 final TrainingSessionModel? session = foundEvent?.event as TrainingSessionModel?;

                 if (session != null) {
                   if (widget.userRole == 'coach') {
                     showDialog(
                       context: context,
                       builder: (context) => CoachSessionDetail(
                         session: session,
                         coachId: widget.userId,
                         onRefresh: () {
                           // Refresh the calendar after editing/deleting a session
                           setState(() {
                             _futureSessions = _fetchAndPopulateSessions();
                           });
                         },
                       ),
                     );
                   } else if (widget.userRole == 'student') {
                     showDialog(
                       context: context,
                       builder: (context) => StudentSessionDetail(
                         session: session,
                         studentId: widget.userId,
                         onRefresh: () {
                           // Refresh the calendar after editing/deleting a session
                           setState(() {
                             _futureSessions = _fetchAndPopulateSessions();
                           });
                         },
                       ),
                     );
                   } else {
                     // Fallback to generic dialog if userRole is neither coach nor student
                     _showGenericEventDialog(context, event);
                   }
                 } else {
                   // Fallback to generic dialog if session not found
                   _showGenericEventDialog(context, event);
                 }
               },
              onCellTap: (events, date) {
                // You can pre-fill this date in the modal if needed
                print("Tapped on cell: $date");
              },
            );
          }
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
              context.go('/calendar', extra: {'userId': widget.userId, 'userRole': widget.userRole, 'academyId':widget.academyId});
            } else if (index == 2) {
              context.go('/coach_profile', extra: {
                'coachId': widget.userId,
                'userRole': widget.userRole,
                'academyId': widget.academyId,
              });
            }
          });
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => showModalBottomSheet(
      //     context: context,
      //     isScrollControlled: true,
      //     backgroundColor: Colors.transparent,
      //     builder: (_) => const CreateEventModal(),
      //   ),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
