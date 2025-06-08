class TrainingSessionModel  {
  final String sessionId;
  final String academyId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;

  TrainingSessionModel({
    required this.sessionId,
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
}