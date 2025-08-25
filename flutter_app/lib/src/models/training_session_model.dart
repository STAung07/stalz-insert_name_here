class TrainingSessionModel {
  final String? sessionId;
  final String academyId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String bookingStatus;
  final String sessionType;
  final List<String> studentIds;
  final String trainingPlan;
  final String feedback;

  TrainingSessionModel({
    this.sessionId,
    required this.academyId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.bookingStatus,
    required this.sessionType,
    required this.studentIds,
    required this.trainingPlan,
    required this.feedback,
  });
  factory TrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return TrainingSessionModel(
      sessionId: map['id'] ?? '',
      academyId: map['academy_id'] ?? '',
      title: map['title'] ?? '',
      startTime: DateTime.parse(map['start_time'] ?? ''),
      endTime: DateTime.parse(map['end_time'] ?? ''),
      location: map['location'] ?? '',
      bookingStatus: map['booking_status'] ?? '',
      sessionType: map['session_type'] ?? '',
      studentIds: List<String>.from(map['student_ids'] ?? []),
      trainingPlan: map['training_plan'] ?? '',
      feedback: map['feedback'] ?? '',
    );
  }

  Map<String, dynamic> toJsonMap(TrainingSessionModel session) {
    final Map<String, Object> data = {
      'title': session.title,
      'academy_id': session.academyId,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime.toIso8601String(),
      'location': session.location,
      'booking_status': session.bookingStatus,
      'session_type': session.sessionType,
      'student_ids': session.studentIds,
      'training_plan': session.trainingPlan,
      'feedback': session.feedback,
    };
    if (session.sessionId != null) {
      data['id'] = session.sessionId!;
    }
    return data;
  }
}
