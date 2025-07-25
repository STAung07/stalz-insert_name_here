class TrainingSessionModel  {
  final String? sessionId;
  final String academyId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;

  TrainingSessionModel({
    this.sessionId,
    required this.academyId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
  });
  factory TrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return TrainingSessionModel(
      sessionId: map['session_id']?? '',
      academyId: map['academy_id']?? '',
      title: map['title']?? '',
      startTime: DateTime.parse(map['start_time'] ?? ''),
      endTime: DateTime.parse(map['end_time'] ?? ''),
      location: map['location']?? '',
    );
  }

  Map<String, dynamic> toJsonMap(TrainingSessionModel session) {
    return {
      // 'academy_id': session.academyId,
      'title': session.title,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime.toIso8601String(),
      'location': session.location,
    };
  }
}