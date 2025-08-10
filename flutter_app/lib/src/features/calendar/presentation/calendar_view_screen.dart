import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
// import 'create_event_modal.dart';
import 'package:go_router/go_router.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => CalendarViewScreenState();
}

class CalendarViewScreenState extends State<CalendarViewScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Sessions')),
      body: MonthView(
        // showLiveTimeLineInAllDays: false,
        controller: EventController(),
        onEventTap: (events, date) {
          // Handle session tap
        },
        onCellTap: (events, date) {
          // You can pre-fill this date in the modal if needed
          print("Tapped on cell: $date");
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
              context.go('/calendar');
            } else if (index == 2) {
              // context.go('/profile');
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
