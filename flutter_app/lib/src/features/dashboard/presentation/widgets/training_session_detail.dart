import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/features/dashboard/presentation/widgets/add_session_form.dart';
import 'package:intl/intl.dart';

class TrainingSessionDetail extends StatelessWidget {
  final TrainingSessionModel session;
  final String coachId;
  final VoidCallback? onRefresh;

  const TrainingSessionDetail({
    super.key,
    required this.session,
    required this.coachId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: SizedBox(
        width: screenSize.width * 0.95,
        height: screenSize.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                session.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Location & Time Info
              Row(
                children: [
                  Icon(Icons.place, size: 20),
                  const SizedBox(width: 8),
                  Text(session.location),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('MMM d, yyyy • h:mm a').format(session.startTime)}'
                    ' - ${DateFormat('h:mm a').format(session.endTime)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Booking Status & Type
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Text('${session.bookingStatus} • ${session.sessionType}'),
                ],
              ),

              const Divider(height: 24),

              // Training Plan & Feedback
              Text(
                'Training Plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(session.trainingPlan),
              const SizedBox(height: 12),
              Text('Feedback', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(session.feedback),

              const Divider(height: 24),

              // Students
              Text('Students', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    session.studentIds
                        .map(
                          (id) => Chip(label: Text(id)),
                        ) // Consider mapping IDs to names if possible
                        .toList(),
              ),

              const Spacer(),

              // Action Buttons
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch buttons horizontally
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Wait for dialog to close first
                      Navigator.of(context).pop();


                      print("tapped");

                      // Then show the Add/Edit Session form dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final screenSize = MediaQuery.of(context).size;
                          return AlertDialog(
                            title: Text('Add New Session'),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenSize.width * 0.9,
                                maxHeight: screenSize.height * 0.7,
                              ),
                              child: SingleChildScrollView(
                                // allows scrolling if content is too big
                                child: SizedBox(
                                  width:
                                      double
                                          .infinity, // expand to max width of ConstrainedBox
                                  child: AddSessionForm(
                                    sessionId: session.sessionId,
                                    coachId: coachId,
                                    initialSession: session, // for edit
                                    onSessionCreated: () async {
                                      await Future.delayed(
                                        Duration(milliseconds: 500),
                                      );
                                      onRefresh?.call();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Edit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // delete logic
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
